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

import UIKit

#if !COCOAPODS
import BrightroomEngine
#endif
import Verge

open class ClassicImageEditEditMenuControlBase: ClassicImageEditControlBase {
override public required init(viewModel: ClassicImageEditViewModel) {
    super.init(viewModel: viewModel)
}
}
struct EditOptions {
    var name : String = ""
    var image : UIImage? = nil
    var type : Int = 0
    
    init(name : String,image:UIImage,type:Int) {
        self.name = name
        self.image = image
        self.type = type
    }
}

public enum ClassicImageEditEditMenu: CaseIterable {
// case adjustment
// case mask
case exposure
case contrast
// case clarity
case temperature
case saturation
// case fade
// case highlights
// case shadows
case vignette
//  case sharpen
//  case gaussianBlur

open class EditMenuControl: ClassicImageEditEditMenuControlBase, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
//    public let contentView = UIView()
//    public let itemsView = UIStackView()
//    public let scrollView = UIScrollView()
    public var itemsView: [ButtonView] = []
    let flowLayout = ZoomAndSnapFlowLayout()
    var indexPathArray: [IndexPath] = []
    var editOptionsArray : [EditOptions] = []

    public var collectionView = UICollectionView(frame: .zero, collectionViewLayout: ZoomAndSnapFlowLayout())

    public lazy var adjustmentButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editAdjustment,
            image: UIImage(named: "adjustment", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(adjustment), for: .touchUpInside)
        return button
    }()

    public lazy var maskButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editMask,
            image: UIImage(named: "mask", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(masking), for: .touchUpInside)
        return button
    }()

    public lazy var exposureButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editBrightness,
            image: UIImage(named: "brightness", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(brightness), for: .touchUpInside)
        return button
    }()

    public lazy var gaussianBlurButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editBlur,
            image: UIImage(named: "blur", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(blur), for: .touchUpInside)
        return button
    }()

    public lazy var contrastButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editContrast,
            image: UIImage(named: "contrast", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(contrast), for: .touchUpInside)
        return button
    }()

    public lazy var temperatureButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editTemperature,
            image: UIImage(named: "temperature", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(warmth), for: .touchUpInside)
        return button
    }()

    public lazy var saturationButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editSaturation,
            image: UIImage(named: "saturation", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(saturation), for: .touchUpInside)
        return button
    }()

    public lazy var highlightsButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editHighlights,
            image: UIImage(named: "highlights", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(highlights), for: .touchUpInside)
        return button
    }()

    public lazy var shadowsButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editShadows,
            image: UIImage(named: "shadows", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(shadows), for: .touchUpInside)
        return button
    }()

    public lazy var vignetteButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editVignette,
            image: UIImage(named: "vignette", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(vignette), for: .touchUpInside)
        return button
    }()

    public lazy var fadeButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editFade,
            image: UIImage(named: "fade", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(fade), for: .touchUpInside)
        return button
    }()

    public lazy var sharpenButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editSharpen,
            image: UIImage(named: "sharpen", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(sharpen), for: .touchUpInside)
        return button
    }()

    public lazy var clarityButton: ButtonView = {
        let button = ButtonView(
            name: viewModel.localizedStrings.editClarity,
            image: UIImage(named: "structure", in: bundle, compatibleWith: nil)!
        )
        button.addTarget(self, action: #selector(clarity), for: .touchUpInside)
        return button
    }()
    var isFirstime = true

    func loadEditOptions(){
        editOptionsArray.append(EditOptions(name: "Brightness", image: UIImage(named: "ic_brightness_sm")!, type: 0))
        editOptionsArray.append(EditOptions(name: "Warmth", image: UIImage(named: "ic_temp_sm")!, type: 1))
        editOptionsArray.append(EditOptions(name: "Contrast", image: UIImage(named: "ic_contrast_sm")!, type: 2))
        editOptionsArray.append(EditOptions(name: "Hue", image: UIImage(named: "ic_hue_sm")!, type: 3))
        editOptionsArray.append(EditOptions(name: "Saturation", image: UIImage(named: "ic_saturation_sm")!, type: 4))
        editOptionsArray.append(EditOptions(name: "Vignette", image: UIImage(named: "ic_vignette_sm")!, type: 5))
    }

    override open func setup() {
        super.setup()
  
        backgroundColor = ClassicImageEditStyle.default.control.backgroundColor
        loadEditOptions()
        layout: do {
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            collectionView.backgroundColor = .white
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.collectionViewLayout = flowLayout
            collectionView.contentInsetAdjustmentBehavior = .always
            collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
            }
            collectionView.contentInset.right = 36
            collectionView.contentInset.left = 36
            addSubview(collectionView)
            collectionView.allowsSelection = true
            collectionView.translatesAutoresizingMaskIntoConstraints = false
    
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: collectionView.superview!.topAnchor),
                collectionView.rightAnchor.constraint(equalTo: collectionView.superview!.rightAnchor),
                collectionView.leftAnchor.constraint(equalTo: collectionView.superview!.leftAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: 120),
            ])
            for s in 0..<collectionView.numberOfSections {
                for i in 0..<collectionView.numberOfItems(inSection: s) {
                    indexPathArray.append(IndexPath(item: i, section: s))
                }
            }
//        scrollView.addSubview(contentView)
//
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//          contentView.widthAnchor.constraint(
//            greaterThanOrEqualTo: contentView.superview!.widthAnchor,
//            constant: -(scrollView.contentInset.right + scrollView.contentInset.left)
//          ),
//          contentView.heightAnchor.constraint(equalTo: contentView.superview!.heightAnchor),
//          contentView.topAnchor.constraint(equalTo: contentView.superview!.topAnchor),
//          contentView.rightAnchor.constraint(equalTo: contentView.superview!.rightAnchor),
//          contentView.leftAnchor.constraint(equalTo: contentView.superview!.leftAnchor),
//          contentView.bottomAnchor.constraint(equalTo: contentView.superview!.bottomAnchor),
//        ])
//
//        contentView.addSubview(itemsView)
//
//        itemsView.axis = .horizontal
//        itemsView.alignment = .center
//        itemsView.distribution = .fillEqually
//        itemsView.spacing = 16
//
//        itemsView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//          itemsView.heightAnchor.constraint(equalTo: itemsView.superview!.heightAnchor),
//          itemsView.topAnchor.constraint(equalTo: itemsView.superview!.topAnchor),
//          itemsView.rightAnchor.constraint(lessThanOrEqualTo: itemsView.superview!.rightAnchor),
//          itemsView.leftAnchor.constraint(greaterThanOrEqualTo: itemsView.superview!.leftAnchor),
//          itemsView.bottomAnchor.constraint(equalTo: itemsView.superview!.bottomAnchor),
//          itemsView.centerXAnchor.constraint(equalTo: itemsView.superview!.centerXAnchor),
//        ])
        }
    
        item: do {
            let ignoredEditMenu: [ClassicImageEditEditMenu] = viewModel.options.classes.control.ignoredEditMenu
            let displayedMenu = ClassicImageEditEditMenu.allCases.filter { ignoredEditMenu.contains($0) == false }
    
            var buttons: [ButtonView] = []
    
            for editMenu in displayedMenu {
                switch editMenu {
//          case .adjustment:
//            buttons.append(adjustmentButton)
//          case .mask:
//            buttons.append(maskButton)
                case .exposure:
                    buttons.append(exposureButton)
//          case .gaussianBlur:
//            buttons.append(gaussianBlurButton)
                case .contrast:
                    buttons.append(contrastButton)
                case .temperature:
                    buttons.append(temperatureButton)
                case .saturation:
                    buttons.append(saturationButton)
//          case .highlights:
//            buttons.append(highlightsButton)
//          case .shadows:
//            buttons.append(shadowsButton)
                case .vignette:
                    buttons.append(vignetteButton)
//          case .fade:
//            buttons.append(fadeButton)
//          case .sharpen:
//            buttons.append(sharpenButton)
//          case .clarity:
//            buttons.append(clarityButton)
                }
            }
    
            for button in buttons {
                itemsView.append(button)
            }
    
            /*
     
             color: do {
             let button = ButtonView(name: TODOL10n("Color"), image: .init())
             button.addTarget(self, action: #selector(color), for: .touchUpInside)
             itemsView.addArrangedSubview(button)
             }
     
             */
            hls: do {
                // http://flexmonkey.blogspot.com/2016/03/creating-selective-hsl-adjustment.html
            }
        }
    }

    override open func didReceiveCurrentEdit(state: Changes<ClassicImageEditViewModel.State>) {
        if let edit = state.editingState.loadedState?.currentEdit {
            maskButton.hasChanges = !edit.drawings.blurredMaskPaths.isEmpty
    
            contrastButton.hasChanges = edit.filters.contrast != nil
            exposureButton.hasChanges = edit.filters.exposure != nil
            temperatureButton.hasChanges = edit.filters.temperature != nil
            saturationButton.hasChanges = edit.filters.saturation != nil
            highlightsButton.hasChanges = edit.filters.highlights != nil
            shadowsButton.hasChanges = edit.filters.shadows != nil
            vignetteButton.hasChanges = edit.filters.vignette != nil
            gaussianBlurButton.hasChanges = edit.filters.gaussianBlur != nil
            fadeButton.hasChanges = edit.filters.fade != nil
            sharpenButton.hasChanges = edit.filters.sharpen != nil
            clarityButton.hasChanges = edit.filters.unsharpMask != nil
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editOptionsArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        if indexPath.row == 0, isFirstime {
            isFirstime = false
            selectedCell = cell
            cell.imageView.image = UIImage(named: "ic_brightness_sm")
            cell.nameLabel.text = editOptionsArray[indexPath.row].name
            brightness()
        } else {
            cell.imageView.image = editOptionsArray[indexPath.row].image
            cell.nameLabel.text = ""
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else  {return}
        let centrePoint = CGPoint(x: self.collectionView.frame.size.width/2 +
                                    scrollView.contentOffset.x,
                                  y: self.collectionView.frame.size.height/2 +
                                    scrollView.contentOffset.y)
                if let indexPathh = collectionView.indexPathForItem(at: centrePoint) {
                    for index in indexPathArray {
                        if let cell: CollectionViewCell = collectionView.cellForItem(at: index) as? CollectionViewCell
                        {
                            if indexPathh == index {
                                isIndex(type: editOptionsArray[index.row].type, cell: cell, index: index.row)
                            }else{
                                cell.imageView.image = editOptionsArray[index.row].image
                                cell.nameLabel.text = ""
                            }
                        }
                    }
                }
    }
    
    var selectedCell : CollectionViewCell?
    func isIndex(type:Int,cell:CollectionViewCell,index:Int){
        selectedCell = cell
       // horizontal.animateWithValueUpdate(0, duration: 2)
        switch type {
        case 0: //brightness
            cell.imageView.image = UIImage(named: "ic_brightness_lg")
            cell.nameLabel.text = editOptionsArray[index].name
            brightness()
        case 1://warmth
            cell.imageView.image = UIImage(named: "ic_temp_lg")
            cell.nameLabel.text = editOptionsArray[index].name
            warmth()
        case 2://contrast
            cell.imageView.image = UIImage(named: "ic_contrast_lg")
            cell.nameLabel.text = editOptionsArray[index].name
            contrast()
        case 3://hue
            cell.imageView.image = UIImage(named: "ic_hue_lg")
            cell.nameLabel.text = editOptionsArray[index].name
        case 4://saturation
            cell.imageView.image = UIImage(named: "ic_saturation_lg")
            cell.nameLabel.text = editOptionsArray[index].name
            saturation()
        case 5://vignette
            cell.imageView.image = UIImage(named: "ic_vignette_lg")
            cell.nameLabel.text = editOptionsArray[index].name
            vignette()
        default:
            break
        }
    }

    @objc
    private func adjustment() {
        push(ClassicImageEditCropControl(viewModel: viewModel), animated: false, isSlider: true)
    }

    @objc
    private func masking() {
        push(ClassicImageEditMaskControl(viewModel: viewModel), animated: false, isSlider: true)
    }

    @objc
    private func doodle() {
        push(ClassicImageEditDoodleControl(viewModel: viewModel), animated: false, isSlider: true)
    }

    @objc
    private func brightness() {
        push(
            viewModel.options.classes.control.exposureControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func blur() {
        push(
            viewModel.options.classes.control.gaussianBlurControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func contrast() {
        push(
            viewModel.options.classes.control.contrastControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func clarity() {
        push(
            viewModel.options.classes.control.clarityControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func warmth() {
        push(
            viewModel.options.classes.control.temperatureControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func saturation() {
        push(
            viewModel.options.classes.control.saturationControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func color() {}

    @objc
    private func fade() {
        push(viewModel.options.classes.control.fadeControl.init(viewModel: viewModel), animated: false, isSlider: true)
    }

    @objc
    private func highlights() {
        push(
            viewModel.options.classes.control.highlightsControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func shadows() {
        push(
            viewModel.options.classes.control.shadowsControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func vignette() {
        push(
            viewModel.options.classes.control.vignetteControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    @objc
    private func sharpen() {
        push(
            viewModel.options.classes.control.sharpenControl.init(viewModel: viewModel),
            animated: false, isSlider: true
        )
    }

    open class ButtonView: UIControl {
        public let nameLabel = UILabel()
  
        public let imageView = UIImageView()
  
        public let changesMarkView = UIView()
  
        private let feedbackGenerator = UISelectionFeedbackGenerator()
  
        public var hasChanges: Bool = false {
            didSet {
                guard oldValue != hasChanges else { return }
                changesMarkView.isHidden = !hasChanges
            }
        }
  
        public init(name: String, image: UIImage) {
            super.init(frame: .zero)
    
            layout: do {
                addSubview(nameLabel)
                addSubview(imageView)
                addSubview(changesMarkView)
      
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                imageView.translatesAutoresizingMaskIntoConstraints = false
                changesMarkView.translatesAutoresizingMaskIntoConstraints = false
      
                NSLayoutConstraint.activate([
                    changesMarkView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                    changesMarkView.centerXAnchor.constraint(equalTo: centerXAnchor),
                    changesMarkView.widthAnchor.constraint(equalToConstant: 4),
                    changesMarkView.heightAnchor.constraint(equalToConstant: 4),
                    
                    imageView.topAnchor.constraint(equalTo: changesMarkView.bottomAnchor, constant: 8),
                    imageView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -4),
                    imageView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 4),
                    imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 20),
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                    
                    nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
                    nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
                    nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
                    nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        
                ])
            }
    
            style: do {
                imageView.contentMode = .center
                imageView.tintColor = ClassicImageEditStyle.default.black
                nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                nameLabel.textColor = ClassicImageEditStyle.default.black
                nameLabel.textAlignment = .center
      
                changesMarkView.layer.cornerRadius = 2
                changesMarkView.backgroundColor = ClassicImageEditStyle.default.black
                changesMarkView.isHidden = true
            }
    
            body: do {
                imageView.image = image
                nameLabel.text = name
            }
    
            addTarget(self, action: #selector(didTapSelf), for: .touchUpInside)
        }
  
        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
  
        override open var isHighlighted: Bool {
            didSet {
                UIView.animate(
                    withDuration: 0.16,
                    delay: 0,
                    options: [.beginFromCurrentState],
                    animations: {
                        if self.isHighlighted {
                            self.alpha = 0.6
                        } else {
                            self.alpha = 1
                        }
                    },
                    completion: nil
                )
            }
        }
  
        @objc private func didTapSelf() {
            feedbackGenerator.selectionChanged()
        }
    }
}
}

class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {
let activeDistance: CGFloat = 100
let zoomFactor: CGFloat = 0

override init() {
    super.init()
    scrollDirection = .horizontal
    minimumLineSpacing = 20
    itemSize = CGSize(width: 70, height: 58)
}

@available(*, unavailable)
required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

override func prepare() {
    guard let collectionView = collectionView else { fatalError() }
    let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
    let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
    sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)

    super.prepare()
}

override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView = collectionView else { return nil }
    let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
    let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

    // Make the cells be zoomed when they reach the center of the screen
    for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
        let distance = visibleRect.midX - attributes.center.x
        let normalizedDistance = distance / activeDistance

        if distance.magnitude < activeDistance {
            let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
            attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
            attributes.zIndex = Int(zoom.rounded())
        }
    }

    return rectAttributes
}

override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else { return .zero }

    // Add some snapping behaviour so that the zoomed cell is always centered
    let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
    guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

    var offsetAdjustment = CGFloat.greatestFiniteMagnitude
    let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

    for layoutAttributes in rectAttributes {
        let itemHorizontalCenter = layoutAttributes.center.x
        if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter
        }
    }

    return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
}

override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
    return true
}

override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
    let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
    context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
    return context
}
}

class CollectionViewCell: UICollectionViewCell {
    public let nameLabel = UILabel()

    public let imageView = UIImageView()

    public let changesMarkView = UIView()

    public var hasChanges: Bool = false {
        didSet {
            guard oldValue != hasChanges else { return }
            changesMarkView.isHidden = !hasChanges
        }
    }

override init(frame: CGRect) {
    super.init(frame: frame)

        layout: do {
            contentView.addSubview(nameLabel)
            contentView.addSubview(imageView)
            contentView.addSubview(changesMarkView)

            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            changesMarkView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                changesMarkView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                changesMarkView.centerXAnchor.constraint(equalTo: centerXAnchor),
                changesMarkView.widthAnchor.constraint(equalToConstant: 4),
                changesMarkView.heightAnchor.constraint(equalToConstant: 4),

                imageView.topAnchor.constraint(equalTo: changesMarkView.bottomAnchor, constant: 8),
                imageView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -4),
                imageView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 4),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 20),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
                nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
                nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
                nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            ])
        }

        style: do {
            imageView.contentMode = .center
            imageView.tintColor = .black
            nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            nameLabel.textColor = .black
            nameLabel.textAlignment = .center

            changesMarkView.layer.cornerRadius = 2
            changesMarkView.backgroundColor = .black
            changesMarkView.isHidden = true
        }

        body: do {
            imageView.image = UIImage(named: "ic_brightness_sm")
            nameLabel.text = ""
        }
}

@available(*, unavailable)
required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}
}
