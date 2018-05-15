//
//  GradientView.swift
//  toHomeMapBox
//
//  Created by Kristyan Danailov on 15.05.18 г..
//  Copyright © 2018 г. Kristyan Danailov. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.2392156863, green: 0.662745098, blue: 0.9764705882, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    override func layoutSubviews() {
        let gradientLyer = CAGradientLayer()
        gradientLyer.colors = [topColor.cgColor,bottomColor.cgColor]
        gradientLyer.startPoint = CGPoint(x: 0, y: 0)
        gradientLyer.endPoint = CGPoint(x: 1, y: 1)
        gradientLyer.frame = self.bounds
        self.layer.insertSublayer(gradientLyer, at: 0)
    }
}
