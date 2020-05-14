//
//  DropitView.swift
//  Dropit
//
//  Created by Aliaksandr Hladkou on 5/13/20.
//  Copyright © 2020 Aliaksandr Hladkou. All rights reserved.
//

import UIKit
import CoreMotion

@IBDesignable
class DropitView: UIView, UIDynamicAnimatorDelegate {

    var bezierPaths = [String:UIBezierPath]() {didSet { setNeedsDisplay()}}
    
    override func draw(_ rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    private let dropBehavior = FallingObjectBehavior()
    
    var animating: Bool = false {
        didSet {
            if animating {
                animator.addBehavior(dropBehavior)
                updateRealGravity()
            } else {
                animator.removeBehavior(dropBehavior)
            }
        }
    }
    
    var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }
    private let motionManager = CMMotionManager()
    private func updateRealGravity() {
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdates(to: OperationQueue())
                {
                    [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeRight: swap(&dx, &dy)
                            case .landscapeLeft: swap(&dx, &dy); dy = -dy
                            default: dx = 0; dy = 0
                            }
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                        }
                    } else {
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }
            }
        } else
        {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    private var attachment: UIAttachmentBehavior? {
        willSet {
            if attachment != nil {
                animator.removeBehavior(attachment!)
                bezierPaths[PathNames.Attachment] = nil
            }
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment!.action = { [unowned self] in
                    if let attachedDrop = self.attachment!.items.first as? UIView {
                        self.bezierPaths[PathNames.Attachment] = UIBezierPath.lineFrom(from: self.attachment!.anchorPoint, to: attachedDrop.center)
                    }
                }
            }
        }
    }
    
    private struct PathNames {
        static let LeftBarrier = "Left Barrier"
        static let MiddleBarrier = "Middle Bariier"
        static let RightBarrier = "Right Barrier"
        static let Attachment = "Attachment"
    }
    
    //presenting oval barriers here
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(ovalIn: CGRect(center: bounds.mid, size: barrierSize))
        dropBehavior.addBarrier(path: path, named: PathNames.MiddleBarrier)
        let lPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: bounds.midX*0.5, y: bounds.midY), size: barrierSize))
        dropBehavior.addBarrier(path: lPath, named: PathNames.LeftBarrier)
        let rPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: bounds.midX*1.5, y: bounds.midY), size: barrierSize))
        dropBehavior.addBarrier(path: rPath, named: PathNames.RightBarrier)
        bezierPaths[PathNames.MiddleBarrier] = path
        bezierPaths[PathNames.LeftBarrier] = lPath
        bezierPaths[PathNames.RightBarrier] = rPath
    }
    
    private let dropsPerRow = 10
    private var dropSize: CGSize {
        let size = bounds.size.width / CGFloat(dropsPerRow)
        //return CGSize(width: size, height: size * CGFloat(Int.random(in: 1..<3)))
        return CGSize(width: size, height: size)
    }
    
    private var barrierSize: CGSize {
        let size = bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    
    //function to hook new drop only
    @objc func grabDrop(recognizer: UIPanGestureRecognizer) {
        let gesturePoint = recognizer.location(in: self)
        
        switch recognizer.state {
        case .began:
            //create the attachment
            if let dropToAttachTo = lastDrop, dropToAttachTo.superview != nil
            {
                attachment = UIAttachmentBehavior(item: dropToAttachTo, attachedToAnchor: gesturePoint)
            }
            lastDrop = nil
        case .changed:
            //change the attachment's anchor point
            attachment?.anchorPoint = gesturePoint
        default:
            attachment = nil
        }
    }
    
    private func removeCompletedRow()
    {
        var dropsToRemove = [UIView]()
        
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        repeat {
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsTested = 0
            var dropsFound = [UIView]()
            while dropsTested < dropsPerRow {
                if let hitView = hitTest(p: hitTestRect.mid), hitView.superview == self {
                    dropsFound.append(hitView)
                }
                else {
                    break
                }
                hitTestRect.origin.x += dropSize.width
                dropsTested += 1
            }
            if dropsTested == dropsPerRow {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove {
            dropBehavior.removeItem(item: drop)
            drop.removeFromSuperview()
        }
    }
    
    private var lastDrop: UIView?
    
    func addDrop() {
        
        var frame = CGRect(origin: CGPoint.zero, size: dropSize)
        frame.origin.x = CGFloat.random(max: dropsPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        dropBehavior.addItem(item: drop)
        lastDrop = drop
    }
}
