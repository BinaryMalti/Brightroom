//
// Copyright (c) 2021 Muukii <muukii.app@gmail.com>
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

import Verge
import PixelEngine

public final class PixelEditViewModel: Equatable, StoreComponentType {
  
  public static func == (lhs: PixelEditViewModel, rhs: PixelEditViewModel) -> Bool {
    lhs === rhs
  }
  
  public enum Mode {
    
    case adjustment
    case masking
    case editing
    case preview
  }
    
  public struct State: Equatable {
    public var editingState: Changes<EditingStack.State>
            
    public fileprivate(set) var title: String = ""
    public fileprivate(set) var mode: Mode = .preview
    
    // TODO: tantative
    public fileprivate(set) var brush: OvalBrush = .init(
      color: .white,
      width: 30
    )
    
    // TODO: Rename
    fileprivate var drawnPaths: [DrawnPathInRect] = []
  }
  
  public let options: Options
  
  public let store: DefaultStore
  
  public let editingStack: EditingStack
  
  private var subscriptions: Set<VergeAnyCancellable> = .init()
  
  public let doneButtonTitle: String

  public init(
    editingStack: EditingStack,
    doneButtonTitle: String = L10n.done,
    options: Options = .default
  ) {
    
    self.doneButtonTitle = doneButtonTitle
    self.options = options
    self.editingStack = editingStack
    self.store = .init(initialState: .init(editingState: editingStack.state))
    
    editingStack.assign(to: assignee(\.editingState)).store(in: &subscriptions)
  }
  
  public func set(title: String) {
    commit {
      $0.title = title
    }
  }
  
  public func set(mode: Mode) {
    commit {
      $0.mode = mode
      
      switch mode {
      case .adjustment:
        $0.title = L10n.editAdjustment
      case .masking:
        $0.title = L10n.editMask
      case .editing:
        break
      case .preview:
        $0.title = ""
      }
    }
  }
  
  public func endMasking(save: Bool) {
    if save {
      editingStack.set(blurringMaskPaths: state.drawnPaths)
      editingStack.takeSnapshot()
    } else {
      // TODO:
    }
  }
  
  public func set(brush: OvalBrush) {
    commit {
      $0.brush = brush
    }
  }
  
  public func set(brushSize: CGFloat) {
    commit {
      var _brush = $0.brush
      _brush.width = brushSize
      $0.brush = _brush
    }
  }
  
  public func set(drawnPaths: [DrawnPathInRect]) {
    commit {
      $0.drawnPaths = drawnPaths
    }
  }
}
