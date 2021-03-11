//
// Copyright (c) 2018 Muukii <muukii.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import CoreImage
import UIKit
import Verge

/**
 A stateful object that manages current editing status from original image.
 And supports rendering a result image.
 
 - Attension: Source text
 Please make sure of EditingStack is started state before editing in UI with calling `start()`.

 */
open class EditingStack: Equatable, StoreComponentType {
  
  public static func == (lhs: EditingStack, rhs: EditingStack) -> Bool {
    lhs === rhs
  }
    
  public struct State: Equatable {
        
    /**
     A Boolean value that indicates whether the image is currently loading for editing.
     */
    public fileprivate(set) var isLoading = true
        
    public var imageSize: CGSize {
      initialEditing.imageSize
    }
            
    private let initialEditing: Edit
        
    public fileprivate(set) var hasStartedEditing = false
    
    public fileprivate(set) var history: [Edit] = []
    
    public fileprivate(set) var currentEdit: Edit
    
    fileprivate(set) var previewImageProvider: CGImageSource?
    fileprivate(set) var editableImageProvider: CGImageSource?
    
    public fileprivate(set) var thumbnailImage: CIImage?
    
    /**
     An image for placeholder, not editable.
     Uses in waiting for loading an editable image.
     */
    public fileprivate(set) var placeholderImage: CIImage?
    
    /**
     An original image
     Can be used in cropping
     */
    public fileprivate(set) var editingSourceImage: CIImage?
        
    /**
     An image that cropped but not effected.
     */
    public fileprivate(set) var editingCroppedImage: CIImage?
    
    /**
     An image that applied editing and optimized for previewing.
     */
    public fileprivate(set) var editingCroppedPreviewImage: CIImage?
        
    public fileprivate(set) var previewColorCubeFilters: [PreviewFilterColorCube] = []
    
    public var canUndo: Bool {
      return history.count > 0
    }
        
    public var isDirty: Bool {
      return currentEdit != initialEditing
    }
    
    init(initialEdit: Edit) {
      self.initialEditing = initialEdit
      self.currentEdit = initialEdit
    }
        
    static func makeVersion(ref: InoutRef<Self>) {
      ref.history.append(ref.currentEdit)
    }
    
    static func revertCurrentEditing(ref: InoutRef<Self>) {
      ref.currentEdit = ref.history.last ?? ref.initialEditing
    }
        
    static func undoEditing(ref: InoutRef<Self>) {
      ref.currentEdit = ref.history.popLast() ?? ref.initialEditing
    }
    
  }

  // MARK: - Stored Properties
  
  public let store: DefaultStore

  public let imageProvider: ImageProvider

  public let previewMaxPixelSize: CGFloat
  
  private let colorCubeFilters: [FilterColorCube]
          
  private let queue = DispatchQueue(
    label: "me.muukii.PixelEngine",
    qos: .default,
    attributes: []
  )
  
  private var subscriptions = Set<VergeAnyCancellable>()
  private var imageProviderSubscription: VergeAnyCancellable?
  
  private let modifyCrop: (CIImage?, inout EditingCrop) -> Void
  
  private let imageMaxLengthInEditing: CGFloat = 2560

  // MARK: - Initializers
  
  /// Creates an instance
  /// - Parameters:
  ///   - source:
  ///   - previewSize:
  ///   - colorCubeStorage:
  ///   - modifyCrop: A chance to modify cropping. It runs in background-thread. CIImage is not original image.
  public init(
    imageProvider: ImageProvider,
    previewMaxPixelSize: CGFloat,
    colorCubeStorage: ColorCubeStorage = .default,
    modifyCrop: @escaping (CIImage?, inout EditingCrop) -> Void = { _, _ in }
    ) {
    
    let initialCrop = EditingCrop(
      imageSize: imageProvider.state.imageSize
    )
        
    self.modifyCrop = modifyCrop
    self.store = .init(
      initialState: .init(
        initialEdit: Edit(crop: initialCrop)
      )
    )
    
    self.colorCubeFilters = colorCubeStorage.filters
    self.imageProvider = imageProvider
    self.previewMaxPixelSize = previewMaxPixelSize
        
    applyIfChanged { (s) in

    }
  }
  
  /**
   EditingStack awakes from cold state.
   */
  public func start() {
    
    _pixelengine_ensureMainThread()
    
    guard state.hasStartedEditing == false else {
      return
    }
    
    commit {
      $0.hasStartedEditing = true
    }
          
    store.add(middleware: .unifiedMutation({ (ref) in
      // TODO:
    }))
    
    sinkState(queue: .asyncSerialBackground) { [weak self] (state) in
      
      guard let self = self else { return }
      
      state.ifChanged(\.thumbnailImage) { image in
        
        guard let image = image else { return }

        self.commit {
          $0.previewColorCubeFilters = self.colorCubeFilters.concurrentMap {
            let r = PreviewFilterColorCube(sourceImage: image, filter: $0)
            return r
          }
        }
        
      }
      
      state.ifChanged(\.currentEdit, \.editingCroppedImage) { currentEdit, croppedTargetImage in
        if let croppedTargetImage = croppedTargetImage {
          self.updatePreviewImage(from: currentEdit, image: croppedTargetImage)
        }
      }
      
      state.ifChanged(\.currentEdit.crop, \.editingSourceImage) { _cropRect, targetImage in
        
        if let targetImage = targetImage {
                   
          let croppedImage = targetImage
            .cropped(to: _cropRect.scaled(maxPixelSize: self.imageMaxLengthInEditing))
                    
          let targetSize = croppedImage.extent.size.scaled(maxPixelSize: self.previewMaxPixelSize)

          let scaled = croppedImage.transformed(
            by: .init(
              scaleX: targetSize.width / croppedImage.extent.width,
              y: targetSize.height / croppedImage.extent.height
            )
          )

          let translated = scaled
            .transformed(by: .init(translationX: scaled.extent.origin.x, y: scaled.extent.origin.y))
            .insertingIntermediate(cache: true)

          self.commit {
            $0.editingCroppedImage = translated
          }
        }
        
      }
      
    }
    .store(in: &subscriptions)
    
    
    /**
     Start downloading image
     */
    imageProvider.start()
    imageProviderSubscription = imageProvider.sinkState(queue: .asyncSerialBackground) { [weak self] (state) in
      
      guard let self = self else { return }
      
      state.ifChanged(\.loadedImage) { image in
         
        guard let image = image else {
          self.commit {
            self._commit_adjustCropExtent(image: nil, ref: $0)
          }
          return
        }
        self.commit { s in
          
          switch image {
          case .preview(let image):
            s.isLoading = true
            s.previewImageProvider = image
            s.placeholderImage = ImageTool.loadThumbnailCGImage(from: image, maxPixelSize: 1280).flatMap { CIImage(cgImage: $0) }
            
          case .editable(let image):
            s.isLoading = false
            s.editableImageProvider = image
            
            let editingImage = ImageTool.loadThumbnailCGImage(
              from: image,
              maxPixelSize: self.imageMaxLengthInEditing
            )
            .flatMap { CIImage(cgImage: $0) }
            
            s.editingSourceImage = editingImage
            
            s.thumbnailImage = ImageTool.loadThumbnailCGImage(
              from: image,
              maxPixelSize: 180
            )
            .flatMap { CIImage(cgImage: $0) }
            
            do {
              self._commit_adjustCropExtent(image: editingImage, ref: s)
            }
            
            self.imageProviderSubscription?.cancel()
          }
                                       
        }
      }
      
    }

          
  }
  
  // MARK: - Functions
  
  func _commit_adjustCropExtent(image: CIImage?, ref: InoutRef<State>) {
    
    let imageSize = ref.imageSize
    var crop = EditingCrop(imageSize: ref.imageSize)
          
    let zoomedImage = image.map { image -> CIImage in
      let scaled = image.transformed(
        by: .init(
          scaleX: image.extent.width < imageSize.width ? imageSize.width / image.extent.width : 1,
          y: image.extent.height < imageSize.width ? imageSize.height / image.extent.height : 1
        )
      )
      
      let translated = scaled.transformed(by: .init(translationX: scaled.extent.origin.x, y: scaled.extent.origin.y))
      
      return translated
    }
    
    modifyCrop(zoomedImage, &crop)
    
    ref.currentEdit.crop = crop
    
    ref.withType { (type, ref) -> Void in
      type.makeVersion(ref: ref)
    }
  }

  /**
   Adds a new snapshot as a history.
   */
  public func takeSnapshot() {
        
    commit {
      $0.withType { (type, ref) -> Void in
        type.makeVersion(ref: ref)
      }
    }
  }

  /**
   Reverts the current editing.
   */
  public func revertEdit() {
    
    _pixelengine_ensureMainThread()
    
    commit {
      $0.withType { (type, ref) -> Void in
        type.revertCurrentEditing(ref: ref)
      }
    }
    
  }

  /**
   Undo editing, pulling the latest history back into the current edit.
   */
  public func undoEdit() {
    
    _pixelengine_ensureMainThread()
        
    commit {
      $0.withType { (type, ref) -> Void in
        type.undoEditing(ref: ref)
      }
    }
    
  }

  /**
   Purges the all of the history
   */
  public func removeAllEditsHistory() {
    
    _pixelengine_ensureMainThread()
    
    commit {
      $0.history = []
    }
  }

  public func set(filters: (inout Edit.Filters) -> Void) {
    
    _pixelengine_ensureMainThread()
    
    applyIfChanged {
      filters(&$0.filters)
    }
  }

  public func crop(_ value: EditingCrop) {
     
    applyIfChanged {
      $0.crop = value
    }
    
  }

  public func set(blurringMaskPaths: [DrawnPathInRect]) {
    
    _pixelengine_ensureMainThread()

    applyIfChanged {
      $0.drawings.blurredMaskPaths = blurringMaskPaths
    }
  }

  public func makeRenderer() -> ImageRenderer {
    
    _pixelengine_ensureMainThread()
        
    guard let imageSource = state.editableImageProvider else {
      preconditionFailure("Image not loaded. You want to catch this error, please file an issue in GitHub.")
    }
        
    let renderer = ImageRenderer(source: imageSource)

    // TODO: Clean up ImageRenderer.Edit
    
    let edit = state.currentEdit

    renderer.edit.croppingRect = edit.crop
    renderer.edit.drawer = [
      BlurredMask(paths: edit.drawings.blurredMaskPaths)
    ]

    renderer.edit.modifiers = edit.makeFilters()

    return renderer
  }

  private func applyIfChanged(_ perform: (inout InoutRef<Edit>) -> Void) {
    
    commit {
      $0.map(keyPath: \.currentEdit, perform: perform)
    }
  
  }

  private func updatePreviewImage(from edit: Edit, image: CIImage) {
    
    let filters = edit
      .makeFilters()
    
    let result = filters.reduce(image) { (image, filter) -> CIImage in
      filter.apply(to: image, sourceImage: image)
    }
    
    commit {
      $0.editingCroppedPreviewImage = result
    }

    // TODO: Ignore vignette and blur (convolutions)
//    adjustmentImage = filters.reduce(source.image) { (image, filter) -> CIImage in
//      filter.apply(to: image, sourceImage: source.image).insertingIntermediateIfCanUse()
//    }

  }

}

extension EditingStack {

  // TODO: Consider more effective shape
  public struct Edit : Equatable {
    
    func makeFilters() -> [Filtering] {
      return filters.makeFilters()
    }
  
    public var imageSize: CGSize {
      crop.imageSize
    }
        
    public var crop: EditingCrop
    public var filters: Filters = .init()
    public var drawings: Drawings = .init()
          
    init(crop: EditingCrop) {
      self.crop = crop
    }
    
    public struct Drawings: Equatable {
      // TODO: Remove Rect from DrawnPath
      public var blurredMaskPaths: [DrawnPathInRect] = []
    }
    
//
//    public struct Light {
//
//    }
//
//    public struct Color {
//
//    }
//
//    public struct Effects {
//
//    }
//
//    public struct Detail {
//
//    }
            
    public struct Filters : Equatable {
      
      public var colorCube: FilterColorCube?
      
      public var brightness: FilterBrightness?
      public var contrast: FilterContrast?
      public var saturation: FilterSaturation?
      public var exposure: FilterExposure?
      
      public var highlights: FilterHighlights?
      public var shadows: FilterShadows?
      
      public var temperature: FilterTemperature?
      
      public var sharpen: FilterSharpen?
      public var gaussianBlur: FilterGaussianBlur?
      public var unsharpMask: FilterUnsharpMask?
      
      public var vignette: FilterVignette?
      public var fade: FilterFade?
      
      func makeFilters() -> [Filtering] {
        return ([
          
          // Before
          exposure,
          brightness,
          temperature,
          highlights,
          shadows,
          saturation,
          contrast,
          colorCube,
          
          // After
          sharpen,
          unsharpMask,
          gaussianBlur,
          fade,
          vignette,
        ] as [Optional<Filtering>])
        .compactMap { $0 }
      }
    }
    
  }

}

extension CIImage {
  
  func cropped(to _cropRect: EditingCrop) -> CIImage {
        
    let targetImage = self
    var cropRect = _cropRect.cropExtent
        
    cropRect.origin.y = targetImage.extent.height - cropRect.minY - cropRect.height
    
    let croppedImage = targetImage
      .cropped(to: cropRect)
    
    return croppedImage
  }
  
}

extension Array {
  
  fileprivate func concurrentMap<U>(_ transform: (Element) -> U) -> [U] {
    
    var buffer = [U?].init(repeating: nil, count: count)
    
    buffer.withUnsafeMutableBufferPointer { (targetBuffer) -> Void in
      
      self.withUnsafeBufferPointer { (sourceBuffer) -> Void in
        
        DispatchQueue.concurrentPerform(iterations: count) { i in
          let sourcePointer = sourceBuffer.baseAddress!.advanced(by: i)
          let r = transform(sourcePointer.pointee)
          let targetPointer = targetBuffer.baseAddress!.advanced(by: i)
          targetPointer.pointee = r
        }
        
      }
    }
    
    return buffer.compactMap { $0 }
  }
}
