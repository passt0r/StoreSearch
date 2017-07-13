//
//  GradientView.swift
//  StoreSearch
//
//  Created by Dmytro Pasinchuk on 11.07.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override func draw(_ rect: CGRect) {
        let components: [CGFloat] = [0,0,0,0.3, 0,0,0,0.7] // array of two color in (red, green, blue, alpha); first for center of circle, second for circumference
        let locations: [CGFloat] = [0,1] //percents of where components colors exists
        //for more than 2 colors you must add another component and location position of this color
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x,y)
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
}
