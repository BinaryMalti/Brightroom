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

open class ClassicImageEditClarityControlBase : ClassicImageEditFilterControlBase {
  
  public required init(viewModel: ClassicImageEditViewModel) {
    super.init(viewModel: viewModel)
  }
}

open class ClassicImageEditClarityControl : ClassicImageEditClarityControlBase,HorizontalDialDelegate {
  
  open override var title: String {
    return viewModel.localizedStrings.editClarity
  }
  
    private lazy var navigationView = ClassicImageEditNavigationView(saveText: viewModel.localizedStrings.done, cancelText: viewModel.localizedStrings.cancel)
  
    public var ruler = HorizontalDial(frame: .zero)
    public var valueLabel = UILabel()
  
  open override func setup() {
    super.setup()
    
    backgroundColor = ClassicImageEditStyle.default.control.backgroundColor
    backgroundColor = .white
    SliderCode.layout(label: valueLabel, ruler: ruler, in: self, forVignette: false)
    ruler.delegate = self
    navigationView.didTapCancelButton = { [weak self] in
      
      guard let self = self else { return }
      
      self.viewModel.editingStack.revertEdit()
      self.pop(animated: true)
    }
    
    navigationView.didTapDoneButton = { [weak self] in
      
      guard let self = self else { return }
      
      self.viewModel.editingStack.takeSnapshot()
      self.pop(animated: true)
    }
  }
    public func horizontalDialDidValueChanged(_ horizontalDial: HorizontalDial) {
        let degrees = horizontalDial.value
        let radians = Int(degrees)
        valueChanged(value: radians)
    }
    
    public func horizontalDialDidEndScroll(_ horizontalDial: HorizontalDial) {

    }
    
  
  open override func didReceiveCurrentEdit(state: Changes<ClassicImageEditViewModel.State>) {
    
    state.ifChanged(\.editingState.loadedState?.currentEdit.filters.unsharpMask) { value in
        ruler.value = Double(value?.intensity ?? 0)
        valueLabel.text = "\(Int(ruler.value))"
    //  slider.set(value: value?.intensity ?? 0, in: FilterUnsharpMask.Params.intensity)
    }
    
  }
  
  @objc
    private func valueChanged(value:Int) {
    
  //  let value = slider.transition(in: FilterUnsharpMask.Params.intensity)
    
    guard value != 0 else {
      viewModel.editingStack.set(filters: {
        $0.unsharpMask = nil
      })
      return
    }
    
    viewModel.editingStack.set(filters: {
      var f = FilterUnsharpMask()
        f.intensity = Double(value)
      f.radius = 0.12
      $0.unsharpMask = f
    })
  }
  
}
