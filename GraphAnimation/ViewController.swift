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
    let shapeLayer = CAShapeLayer()
    
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
        print("Original frame: \(originalFrame)")
    }
    
    func addPanGestureOnView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.animationView.addGestureRecognizer(panGesture)
    }
    
    func halfPoint1D(p0: CGFloat, p2: CGFloat, control: CGFloat) -> CGFloat {
        return 2 * control - p0 / 2 - p2 / 2
    }
    
    @objc func panGestureAction(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let point = panGestureRecognizer.location(in: self.view)
        translation = panGestureRecognizer.translation(in: self.view)
        let velocity = (-panGestureRecognizer.velocity(in: self.view).y)/(-translation.y)
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom
        let areaRemoved = (bottomPadding ?? 0) + 55
        let maxHeight = self.backgroundImageView.frame.height - areaRemoved
        if panGestureRecognizer.state == .began {
            startPosition = panGestureRecognizer.location(in: self.animationView) // the postion at which PanGestue Started
        }
        
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            panGestureRecognizer.setTranslation(CGPoint(x: 0.0, y: 0.0), in: self.view)
            let endPosition = panGestureRecognizer.location(in: animationView) // the posiion at which PanGesture Ended
            difference = endPosition.y - startPosition.y
            var newFrame = animationView.frame
            if (newFrame.height >= (originalHeight)) && (newFrame.height <= maxHeight) {
                newFrame.origin.x = animationView.frame.origin.x
                newFrame.origin.y = animationView.frame.origin.y + difference //Gesture Moving Upward will produce a negative value for difference
                newFrame.size.width = animationView.frame.size.width
                newFrame.size.height = animationView.frame.size.height - difference //Gesture Moving Upward will produce a negative value for difference
                
//                let path = UIBezierPath()
//                path.move(to: newFrame.origin)
//                let y:CGFloat = newFrame.origin.y
//                path.addQuadCurve(to: CGPoint(x: animationView.frame.size.width, y: y), controlPoint: CGPoint(x: point.x, y: newFrame.origin.y - (newFrame.height)))
//                path.addLine(to: CGPoint(x: newFrame.maxX, y: newFrame.maxY))
//                path.addLine(to: CGPoint(x: newFrame.minX, y: newFrame.maxY))
//                path.close()
//                shapeLayer.path = path.cgPath
                self.animationView.layer.addSublayer(shapeLayer)
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: velocity, options: .curveEaseInOut, animations: {
                    self.animationView.frame = newFrame
                }, completion: nil)
            }
        }
        
        if panGestureRecognizer.state == .ended || panGestureRecognizer.state == .cancelled {
            if originalHeight > self.animationView.frame.height {
                let heightDifference = originalHeight - self.animationView.frame.height
                var newFrame = animationView.frame
                newFrame.origin.x = animationView.frame.origin.x
                newFrame.origin.y = animationView.frame.origin.y - heightDifference //Gesture Moving Upward will produce a negative value for difference
                newFrame.size.width = animationView.frame.size.width
                newFrame.size.height = animationView.frame.size.height + heightDifference
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.animationView.frame = newFrame
                }, completion: nil)
            } else if self.animationView.frame.height > maxHeight {
                let heightDifference = self.animationView.frame.height - maxHeight
                var newFrame = animationView.frame
                newFrame.origin.x = animationView.frame.origin.x
                newFrame.origin.y = animationView.frame.origin.y + heightDifference //Gesture Moving Upward will produce a negative value for difference
                newFrame.size.width = animationView.frame.size.width
                newFrame.size.height = animationView.frame.size.height - heightDifference
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.animationView.frame = newFrame
                }, completion: nil)
            }
        }
        panGestureRecognizer.setTranslation(CGPoint.zero, in: self.animationView)
    }
}

extension UIPanGestureRecognizer {
    
    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        static let Up = PanGestureDirection(rawValue: 1 << 0)
        static let Down = PanGestureDirection(rawValue: 1 << 1)
        static let Left = PanGestureDirection(rawValue: 1 << 2)
        static let Right = PanGestureDirection(rawValue: 1 << 3)
    }
    
    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }
    
    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        let xDirection = getDirectionBy(velocity: velocity.x, greater: PanGestureDirection.Right, lower: PanGestureDirection.Left)
        return xDirection.union(yDirection)
    }
}
