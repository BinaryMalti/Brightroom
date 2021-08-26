//
//  ColorHighlightsControl.swift
//  PixelEngine
//
//  Created by Danny on 19.11.18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation


#if !COCOAPODS
import BrightroomEngine
#endif
import Verge

open class ColorHighlightsControlBase : ClassicImageEditFilterControlBase {
  
    public required init(viewModel: ClassicImageEditViewModel) {
    super.init(viewModel: viewModel)
  }
}

open class ColorHighlightsControl : ColorHighlightsControlBase {
  
  open override var title: String {
    return "Highlight"
  }
  
  public let colorButtons = ColorSelectButtons(frame: .zero)
  private let colors = [UIColor.clear] + FilterHighlightShadowTint.HighlightTintColors.allCases.map { UIColor(hex: $0.rawValue) }
  
  open override func setup() {
    super.setup()
        
    layout: do {
      addSubview(colorButtons)
      
      colorButtons.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        colorButtons.rightAnchor.constraint(equalTo: colorButtons.superview!.rightAnchor),
        colorButtons.leftAnchor.constraint(equalTo: colorButtons.superview!.leftAnchor),
        colorButtons.centerYAnchor.constraint(equalTo: colorButtons.superview!.centerYAnchor),
        colorButtons.heightAnchor.constraint(equalToConstant: 100)
        ])
      
      colorButtons.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    body: do {
      colorButtons.colors = colors
    }
  }
    
    
    open override func didReceiveCurrentEdit(state: Changes<ClassicImageEditViewModel.State>) {
      
      //state.ifChanged(\.editingState.loadedState?.currentEdit.filters.sharpen) { value in
      //  slider.set(value: value?.sharpness ?? 0, in: FilterSharpen.Params.sharpness)
     // }
        let valueOptional = colors.map {CIColor(color: $0)}.firstIndex(where: { $0 ==
                                                                    state.editingState.loadedState?.currentEdit.filters.color?.highlightColor })
        
        if let value = valueOptional, value != colorButtons.step {
            colorButtons.set(value: value)
        }
      //  let valueOptional = colors.map { CIColor(color: $0) }.index(where: { $0 == state.filters.color?.highlightColor })
        
//        if let value = valueOptional, value != colorButtons.step {
//          colorButtons.set(value: value)
//        }
    }
//  open override func didReceiveCurrentEdit(_ edit: EditingStack.Edit) {
//    let valueOptional = colors.map { CIColor(color: $0) }.index(where: { $0 == edit.filters.color?.highlightColor })
//
//    if let value = valueOptional, value != colorButtons.step {
//      colorButtons.set(value: value)
//    }
//  }
//
  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    if superview != nil {
      valueChanged()
    }
  }
  
  @objc
  private func valueChanged() {
    let value = colorButtons.step
    
    guard value != 0 else {
        viewModel.editingStack.set(filters: {$0.color = nil})
       // viewModel.editingStack.setFilter({ $0.color = nil })
      return
    }
    var f = FilterHighlightShadowTint()
    f.highlightColor = CIColor(color: colors[value])
    viewModel.editingStack.set(filters: {$0.color = f})

  }
}
