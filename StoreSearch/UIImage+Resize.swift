//
//  UIImage+Resize.swift
//  StoreSearch
//
//  Created by Dmytro Pasinchuk on 13.07.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width/size.width
        let verticalRatio = bounds.height/size.height
        let minSize = min(size.width, size.height)
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: minSize*ratio, height: minSize*ratio)
        let uncropedImageSize = CGSize(width: size.width*horizontalRatio, height: size.height*verticalRatio)
        
        
        UIGraphicsBeginImageContextWithOptions(uncropedImageSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: uncropedImageSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
