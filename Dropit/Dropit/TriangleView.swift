//
//  TriangleView.swift
//  Dropit
//
//  Created by Aliaksandr Hladkou on 5/13/20.
//  Copyright © 2020 Aliaksandr Hladkou. All rights reserved.
//

import UIKit

@IBDesignable
class TriangleView : UIView {
    
    var path: UIBezierPath!
    var _color: UIColor! = UIColor.blue
    var _margin: CGFloat! = 0

    @IBInspectable var margin: Double {
        get { return Double(_margin)}
        set { _margin = CGFloat(newValue)}
    }


    @IBInspectable var fillColor: UIColor? {
        get { return _color }
        set{ _color = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.red
        
        Sublayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func simpleShapeLayer() {
        //self.createRectangle()
     
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = self.path.cgPath
     
        self.layer.addSublayer(shapeLayer)
        
    }
    func Sublayer() {
        self.createTriangle()
     
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.yellow.cgColor
     
        //self.layer.addSublayer(shapeLayer)
        self.layer.mask = shapeLayer
    }
    
    func createTriangle() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width/2, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.close()
        UIColor.blue.setFill()
        path.fill()
        UIColor.purple.setStroke()
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        self.createTriangle()
    }
}
