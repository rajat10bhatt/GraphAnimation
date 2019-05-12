//
//  ViewController.swift
//  GraphAnimation
//
//  Created by Rajat Bhatt on 10/05/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //MARK: Properties
    var originalFrame = CGRect.zero
    var translation: CGPoint!
    var startPosition: CGPoint! //Start position for the gesture transition
    var originalHeight: CGFloat = 0 // Initial Height for the UIView
    var difference: CGFloat!
    enum PanDirection: Int {
        case up
        case down
    }
    var currentDirection = PanDirection.up
    
    // MARK: Navigation controller life cycle methods
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    }

    // MARK: Custom methods
    // Initialize view
    func initializeView() {
        //Remove bottom line of navigation bar
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
        self.title = Constants.controllerTitle
        //Increase size of page control
        pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        //Add pan gesture on animation view
        addPanGestureOnView()
        self.originalHeight = self.animationView.frame.height
        self.originalFrame = CGRect(x: self.animationView.frame.origin.x, y: self.animationView.frame.origin.y, width: self.animationView.frame.width, height: self.animationView.frame.height)
        self.animationView.backgroundColor = #colorLiteral(red: 0.2615871429, green: 0.8389324546, blue: 0.4879657626, alpha: 1)
    }
    
    func addPanGestureOnView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.animationView.addGestureRecognizer(panGesture)
    }
    
    @objc func panGestureAction(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let point = panGestureRecognizer.location(in: self.view)
        let direction: PanDirection = (panGestureRecognizer.velocity(in: self.view).y > 0) ? .down : .up
        self.currentDirection = direction
        translation = panGestureRecognizer.translation(in: self.view)
//        let velocity = (-panGestureRecognizer.velocity(in: self.view).y)/(-translation.y)
        if panGestureRecognizer.state == .began {
            startPosition = panGestureRecognizer.location(in: self.animationView) // the postion at which PanGestue Started
        }
        
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            panBegan(panGestureRecognizer: panGestureRecognizer, direction: direction, point: point)
        }
        
        if panGestureRecognizer.state == .ended || panGestureRecognizer.state == .cancelled {
            panEnded()
        }
        panGestureRecognizer.reset()
    }
    
    //Max height of animated view
    func getMaxAnimatedViewHeight() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom
        let areaRemoved = (bottomPadding ?? 0) + 55
        return self.backgroundImageView.frame.height - areaRemoved
    }
    
    // Pan began
    func panBegan(panGestureRecognizer: UIPanGestureRecognizer, direction: PanDirection, point: CGPoint) {
        panGestureRecognizer.setTranslation(CGPoint(x: 0.0, y: 0.0), in: self.view)
        let maxHeight = getMaxAnimatedViewHeight()
        let endPosition = panGestureRecognizer.location(in: animationView) // the posiion at which PanGesture Ended
        difference = endPosition.y - startPosition.y
        var newFrame = animationView.frame
        if (newFrame.height >= (originalHeight)) && (newFrame.height <= maxHeight) {
            newFrame.origin.x = animationView.frame.origin.x
            newFrame.origin.y = animationView.frame.origin.y + difference //Gesture Moving Upward will produce a negative value for difference
            newFrame.size.width = animationView.frame.size.width
            newFrame.size.height = animationView.frame.size.height - difference //Gesture Moving Upward will produce a negative value for difference
            self.animationView.frame = newFrame
            switch direction {
            case .up:
                self.setTopCurve(newFrame: newFrame, point: point)
            case.down:
                self.setBottomCurve(newFrame: newFrame, point: point)
            }
        }
    }
    
    // Pan ended
    func panEnded() {
        self.resetView()
        let maxHeight = getMaxAnimatedViewHeight()
        var newFrame = animationView.frame
        newFrame.origin.x = animationView.frame.origin.x
        newFrame.size.width = animationView.frame.size.width
        
        if originalHeight > self.animationView.frame.height {
            let heightDifference = originalHeight - self.animationView.frame.height
            newFrame.origin.y = animationView.frame.origin.y - heightDifference
            newFrame.size.height = animationView.frame.size.height + heightDifference
            self.animationView.frame = newFrame
        } else if self.animationView.frame.height > maxHeight {
            let heightDifference = self.animationView.frame.height - maxHeight
            newFrame.origin.y = animationView.frame.origin.y + heightDifference
            newFrame.size.height = animationView.frame.size.height - heightDifference
            self.animationView.frame = newFrame
        }
    }
    
    // Create curve on top
    func setTopCurve(newFrame: CGRect, point: CGPoint) {
        self.resetView()
        self.animationView.layer.masksToBounds = false
        self.animationView.clipsToBounds = false
        self.animationView.layer.mask = nil
        let origin = CGPoint(x: 0.0, y: 0.0)
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: origin)
        path.addQuadCurve(to: CGPoint(x: animationView.frame.size.width, y: origin.y), controlPoint: CGPoint(x: point.x, y: origin.y - 50))
        path.addLine(to: CGPoint(x: newFrame.width, y: newFrame.height))
        path.addLine(to: CGPoint(x: 0, y: newFrame.height))
        path.close()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = #colorLiteral(red: 0.2615871429, green: 0.8389324546, blue: 0.4879657626, alpha: 1).cgColor
        self.animationView.layer.addSublayer(shapeLayer)
    }
    
    // Create curve under top
    func setBottomCurve(newFrame: CGRect, point: CGPoint) {
        self.resetView()
        self.animationView.clipsToBounds = true
        let origin = CGPoint(x: 0.0, y: 0.0)
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: origin)
        path.addQuadCurve(to: CGPoint(x: animationView.frame.size.width, y: origin.y), controlPoint: CGPoint(x: point.x, y: origin.y + 50))
        path.addLine(to: CGPoint(x: newFrame.width, y: newFrame.height))
        path.addLine(to: CGPoint(x: 0, y: newFrame.height))
        path.close()
        shapeLayer.path = path.cgPath
        self.animationView.layer.addSublayer(shapeLayer)
        self.animationView.layer.mask = shapeLayer
        self.animationView.layer.masksToBounds = true
    }
    
    // Reset view to initial state
    func resetView() {
        if self.currentDirection == .up {
            if let subLayers = self.animationView.layer.sublayers {
                for layer in subLayers {
                    layer.removeFromSuperlayer()
                }
            }
        }
        self.animationView.layer.mask = nil
    }
}
