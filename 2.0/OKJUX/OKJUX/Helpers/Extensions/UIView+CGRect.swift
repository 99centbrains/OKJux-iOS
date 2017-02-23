//
//  UIViewExtension.swift
//  Quotr
//
//  Created by German Pereyra on 9/27/16.
//  Copyright © 2016 Tony Robbins. All rights reserved.
//

import UIKit

extension UIView {

    func change(origin: CGPoint) {
        self.frame = CGRect(x: origin.x, y: origin.y, width: self.frame.width, height: self.frame.height)
    }

    func change(originX: CGFloat) {
        self.frame = CGRect(x: originX, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
    }

    func change(originY: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: originY, width: self.frame.width, height: self.frame.height)
    }

    func change(size: CGSize) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: size.width, height: size.height)
    }

    func change(width: CGFloat, height: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: height)
    }

    func change(x originX: CGFloat, y yPos: CGFloat) {
        self.frame = CGRect(x: originX, y: yPos, width: self.frame.width, height: self.frame.height)
    }

    func change(width: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.height)
    }

    func change(height: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height)
    }

    func changeFrame(xPos: CGFloat, yPos: CGFloat, width: CGFloat, height: CGFloat) {
        self.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
    }

    func moveVertically(_ yPos: CGFloat) {
        self.change(originY: self.minY + yPos)
    }

    func moveHorizontally(_ xPos: CGFloat) {
        self.change(originX: self.minX + xPos)
    }

    func resizeToFitIn(size: CGSize) {
        self.change(size: self.sizeThatFits(size))
    }

    var maxX: CGFloat {
        get {
            return self.frame.maxX
        }
    }
    var minX: CGFloat {
        get {
            return self.frame.minX
        }
    }
    var minY: CGFloat {
        get {
            return self.frame.minY
        }
    }
    var maxY: CGFloat {
        get {
            return self.frame.maxY
        }
    }

    var width: CGFloat {
        get {
            return self.frame.width
        }
    }
    var height: CGFloat {
        get {
            return self.frame.height
        }
    }

    var centerX: CGFloat {
        get {
            return self.frame.width / 2
        }
    }

    var centerY: CGFloat {
        get {
            return self.frame.height / 2
        }
    }
}
