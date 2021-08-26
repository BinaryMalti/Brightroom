//
//  ColorShadowsControl.swift
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

open class ColorShadowsControlBase : ClassicImageEditFilterControlBase {
      public required init(viewModel: ClassicImageEditViewModel) {
      super.init(viewModel: viewModel)
    }
}

open class ColorShadowsControl : ColorShadowsControlBase {

  open override var title: String {
    return "Shadows"
  }
  
  public let colorButtons = ColorSelectButtons(frame: .zero)
  private let colors = [UIColor.clear] +
    FilterHighlightShadowTint.HighlightTintColors.allCases.map { UIColor(hex: $0.rawValue) }

  open override func setup() {
    super.setup()

    backgroundColor = .white

    layout: do {
      addSubview(colorButtons)
      colorButtons.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        colorButtons.rightAnchor.constraint(equalTo: colorButtons.superview!.rightAnchor),
        colorButtons.leftAnchor.constraint(equalTo: colorButtons.superview!.leftAnchor),
        colorButtons.topAnchor.constraint(equalTo: colorButtons.superview!.topAnchor),
        colorButtons.heightAnchor.constraint(equalToConstant: 100)
      ])

      colorButtons.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    body: do {
      colorButtons.colors = colors
    }
  }

    open override func didReceiveCurrentEdit(state: Changes<ClassicImageEditViewModel.State>) {
        let valueOptional = colors.map {CIColor(color: $0)}.firstIndex(where: { $0 ==
                                                                    state.editingState.loadedState?.currentEdit.filters.color?.shadowColor })

        if let value = valueOptional, value != colorButtons.step {
          colorButtons.set(value: value)
        }
    }
        
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
        return
      }
      var f = FilterHighlightShadowTint()
      f.highlightColor = CIColor(color: colors[value])
      viewModel.editingStack.set(filters: {$0.color = f})

    }
}
public extension UIColor {
  convenience init(hex: UInt32) {
    let rgbaValue = hex
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0
    
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
