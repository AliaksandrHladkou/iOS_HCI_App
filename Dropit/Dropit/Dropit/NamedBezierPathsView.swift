//
//  NamedBezierPathsView.swift
//  Dropit
//
//  Created by Aliaksandr Hladkou on 5/13/20.
//  Copyright © 2020 Aliaksandr Hladkou. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView {

    var bezierPaths = [String:UIBezierPath]() {didSet { setNeedsDisplay()}}
    
    override func draw(_ rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
}
