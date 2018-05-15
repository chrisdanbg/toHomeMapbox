//
//  UIRoundedButtonWithGradientAndShadow.swift
//  toHomeMapBox
//
//  Created by Kristyan Danailov on 15.05.18 г..
//  Copyright © 2018 г. Kristyan Danailov. All rights reserved.
//

import UIKit

class UIRoundedButtonWithGradientAndShadow: UIButton {
        
        let gradientColors : [UIColor]
        let startPoint : CGPoint
        let endPoint : CGPoint
        
        required init(gradientColors: [UIColor],
                      startPoint: CGPoint = CGPoint(x: 0, y: 0),
                      endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
            self.gradientColors = gradientColors
            self.startPoint = startPoint
            self.endPoint = endPoint
            
            super.init(frame: .zero)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let halfOfButtonHeight = layer.frame.height / 2
            contentEdgeInsets = UIEdgeInsetsMake(10, halfOfButtonHeight, 10, halfOfButtonHeight)
            
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            backgroundColor = UIColor.clear
            
            // setup gradient
            
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = gradientColors.map { $0.cgColor }
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            gradient.cornerRadius = halfOfButtonHeight
            
            // replace gradient as needed
            if let oldGradient = layer.sublayers?[0] as? CAGradientLayer {
                layer.replaceSublayer(oldGradient, with: gradient)
            } else {
                layer.insertSublayer(gradient, below: nil)
            }
            
            // setup shadow
            
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: halfOfButtonHeight).cgPath
            layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 1
        }
        
        override var isHighlighted: Bool {
            didSet {
                let newOpacity : Float = isHighlighted ? 0.6 : 0.85
                let newRadius : CGFloat = isHighlighted ? 6.0 : 4.0
                
                let shadowOpacityAnimation = CABasicAnimation()
                shadowOpacityAnimation.keyPath = "shadowOpacity"
                shadowOpacityAnimation.fromValue = layer.shadowOpacity
                shadowOpacityAnimation.toValue = newOpacity
                shadowOpacityAnimation.duration = 0.1
                
                let shadowRadiusAnimation = CABasicAnimation()
                shadowRadiusAnimation.keyPath = "shadowRadius"
                shadowRadiusAnimation.fromValue = layer.shadowRadius
                shadowRadiusAnimation.toValue = newRadius
                shadowRadiusAnimation.duration = 0.1
                
                layer.add(shadowOpacityAnimation, forKey: "shadowOpacity")
                layer.add(shadowRadiusAnimation, forKey: "shadowRadius")
                
                layer.shadowOpacity = newOpacity
                layer.shadowRadius = newRadius
                
                let xScale : CGFloat = isHighlighted ? 1.025 : 1.0
                let yScale : CGFloat = isHighlighted ? 1.05 : 1.0
                UIView.animate(withDuration: 0.1) {
                    let transformation = CGAffineTransform(scaleX: xScale, y: yScale)
                    self.transform = transformation
                }
            }
        }
}
