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

enum TempCode {
  
  static func layout(navigationView: ClassicImageEditNavigationView, slider: ClassicImageEditStepSlider, in view: UIView) {
    
    let containerGuide = UILayoutGuide()
    view.addLayoutGuide(containerGuide)
    view.addSubview(slider)
  //  view.addSubview(navigationView)
    view.backgroundColor = .white
    slider.translatesAutoresizingMaskIntoConstraints = false
    
   // navigationView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      
      containerGuide.topAnchor.constraint(equalTo: slider.superview!.topAnchor,constant: 40),
      containerGuide.rightAnchor.constraint(equalTo: slider.superview!.rightAnchor, constant: -44),
      containerGuide.leftAnchor.constraint(equalTo: slider.superview!.leftAnchor, constant: 44),
      
      slider.topAnchor.constraint(greaterThanOrEqualTo: containerGuide.topAnchor),
      slider.rightAnchor.constraint(equalTo: containerGuide.rightAnchor),
      slider.leftAnchor.constraint(equalTo: containerGuide.leftAnchor),
      slider.bottomAnchor.constraint(lessThanOrEqualTo: containerGuide.bottomAnchor),
      slider.centerYAnchor.constraint(equalTo: containerGuide.centerYAnchor),
      
//      navigationView.topAnchor.constraint(equalTo: containerGuide.bottomAnchor),
//      navigationView.rightAnchor.constraint(equalTo: navigationView.superview!.rightAnchor),
//      navigationView.leftAnchor.constraint(equalTo: navigationView.superview!.leftAnchor),
//      navigationView.bottomAnchor.constraint(equalTo: navigationView.superview!.bottomAnchor),
      ])

  }
}

enum SliderCode {
  
    static func layout(label:UILabel,ruler: HorizontalDial, in view: UIView) {
    
    let containerGuide = UILayoutGuide()
    view.addLayoutGuide(containerGuide)
    view.addSubview(label)
    view.addSubview(ruler)
    view.backgroundColor = .white
        ruler.enableRange = true
        ruler.minimumValue = -100
        ruler.maximumValue = 100
        ruler.tick = 10
        ruler.centerMarkColor = .black
        ruler.centerMarkWidth = 3
        ruler.centerMarkHeightRatio = 0.8
        ruler.markWidth = 1
        ruler.markColor = .gray
        label.text = "0"
        label.sizeToFit()
        ruler.markCount = 20
        ruler.padding = 20
        label.textAlignment = .center
        ruler.verticalAlign = "center"
        ruler.animateOption = .easeInQuad
        ruler.translatesAutoresizingMaskIntoConstraints = false
        ruler.backgroundColor = .white
    ruler.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      
      containerGuide.topAnchor.constraint(equalTo: ruler.superview!.topAnchor,constant: 0),
      containerGuide.rightAnchor.constraint(equalTo: ruler.superview!.rightAnchor, constant: -44),
      containerGuide.leftAnchor.constraint(equalTo: ruler.superview!.leftAnchor, constant: 44),
        
        label.rightAnchor.constraint(equalTo: view.rightAnchor),
        label.leftAnchor.constraint(equalTo: view.leftAnchor),
        label.topAnchor.constraint(equalTo: containerGuide.topAnchor,constant: 2),
        label.bottomAnchor.constraint(equalTo: ruler.topAnchor,constant: 2),
      
      ruler.topAnchor.constraint(equalTo: label.bottomAnchor),
      ruler.rightAnchor.constraint(equalTo: containerGuide.rightAnchor),
      ruler.leftAnchor.constraint(equalTo: containerGuide.leftAnchor),
      ruler.bottomAnchor.constraint(lessThanOrEqualTo: containerGuide.bottomAnchor),
      ruler.centerYAnchor.constraint(equalTo: containerGuide.centerYAnchor),
      ruler.heightAnchor.constraint(equalToConstant: 60),

      ])

  }
}

