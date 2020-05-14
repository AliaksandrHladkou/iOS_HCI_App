//
//  DropitViewController.swift
//  Dropit
//
//  Created by Aliaksandr Hladkou on 5/13/20.
//  Copyright © 2020 Aliaksandr Hladkou. All rights reserved.
//

import UIKit

class DropitViewController: UIViewController {

    @IBOutlet weak var gameView: DropitView! {
        didSet {
//            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DropitView.addDrop())))
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addDrop(recognizer:))))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(DropitView.grabDrop(recognizer:))))
            gameView.realGravity = true
        }
    }
    
    private(set) var score = 0 {
        didSet {
            updateLabel.text = "Score: \(score)"
        }
    }
    
    @IBOutlet weak var updateLabel: UILabel!
    
    @objc func addDrop(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            gameView.addDrop()
            score += 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = false
    }
}
