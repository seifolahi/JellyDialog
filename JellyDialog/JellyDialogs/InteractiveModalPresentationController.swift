//
//  InteractiveModalPresentationController.swift
//  JellyDialog
//
//  Created by Hamid reza Seifolahi on 12/5/21.
//

import UIKit

enum ModalScaleState {
    case presentation
    case interaction
}

final class InteractiveModalPresentationController: UIPresentationController {
    
    private let shapeLayer = CAShapeLayer()
    
    private var presentedHeight: CGFloat = 300
    private var topCurve: CGFloat = 20
    
    private var direction: CGFloat = 0
    private var state: ModalScaleState = .interaction
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }
        
        let view = UIView(frame: container.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        )
        
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedViewController.view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:)))
        )
        
        if let presented = presentedView {
            setTopClip(view: presented, pressPoint: nil)
        }
    }
    
    @objc func didPan(pan: UIPanGestureRecognizer) {
        guard let view = pan.view, let superView = view.superview,
            let presented = presentedView, let container = containerView else { return }
        
        let location = pan.translation(in: superView)
        
        switch pan.state {
        case .began:
            presented.frame.size.height = presentedHeight
        case .changed:
            let velocity = pan.velocity(in: superView)
            
            switch state {
            case .interaction:
                let tmpLoc = pan.location(in: presented)
                setTopClip(view: presented, pressPoint: tmpLoc)
            case .presentation:
                presented.frame.origin.y = location.y
            }
            direction = velocity.y
        case .ended:
            
            let tmpLoc = pan.location(in: presented)
            self.animatePath(view: presented,
                             pressPoint: tmpLoc,
                             curve2: self.topCurve,
                             duration: 0.2)
            
            let maxPresentedY = container.frame.height
            switch presented.frame.origin.y {
            case 0...maxPresentedY:
                changeScale(to: .interaction)
            default:
                presentedViewController.dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    @objc func didTap(tap: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    func changeScale(to state: ModalScaleState) {
        guard let presented = presentedView else { return }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) { [weak self] in
                guard let `self` = self else { return }
                
                presented.frame = self.frameOfPresentedViewInContainerView
        } completion: { (isFinished) in
            self.state = state
        }

        
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [weak self] in
//            guard let `self` = self else { return }
//
//            presented.frame = self.frameOfPresentedViewInContainerView
//
//            }, completion: { (isFinished) in
//                self.state = state
//        })
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        
        return CGRect(x: 0, y: container.bounds.height - self.presentedHeight, width: container.bounds.width, height: self.presentedHeight)
    }
    
    override func presentationTransitionWillBegin() {
        guard let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator else { return }
        
        dimmingView.alpha = 0
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let `self` = self else { return }
            
            self.dimmingView.alpha = 1
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let `self` = self else { return }
            
            self.dimmingView.alpha = 0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    
}

extension InteractiveModalPresentationController {
    
    func makePath(view: UIView, pressPoint: CGPoint?) -> CGPath {
        
        let maxPossibleHeight = UIScreen.main.bounds.height
        
        let eadgeHeight = CGFloat(70)
        let corner = CGFloat(16)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: eadgeHeight + corner))
        
        path.addArc(withCenter: CGPoint(x: corner, y: eadgeHeight + corner),
                    radius: corner,
                    startAngle: CGFloat.pi,
                    endAngle: CGFloat.pi * (3/2),
                    clockwise: true)
        
        if var pressPoint = pressPoint, pressPoint.y <= eadgeHeight {
            if pressPoint.y < 0 {
                pressPoint.y = 0
            }
            path.addCurve(to: pressPoint,
                          controlPoint1: CGPoint(x: pressPoint.x - 60, y: eadgeHeight),
                          controlPoint2: CGPoint(x: pressPoint.x - 60, y: pressPoint.y))
            
            
            path.addCurve(to: CGPoint(x: view.frame.width - corner, y: eadgeHeight),
                          controlPoint1: CGPoint(x: pressPoint.x + 60, y: pressPoint.y),
                          controlPoint2: CGPoint(x: pressPoint.x + 60, y: eadgeHeight))
        } else {
            path.addLine(to: CGPoint(x: view.frame.width - corner, y: eadgeHeight))
        }
        
        path.addArc(withCenter: CGPoint(x: view.frame.width - corner, y: eadgeHeight + corner),
                    radius: corner,
                    startAngle: CGFloat.pi * (3/2),
                    endAngle: 0,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: view.frame.width, y: maxPossibleHeight))
        path.addLine(to: CGPoint(x: 0, y: maxPossibleHeight))
        path.addLine(to: CGPoint(x: 0, y: view.frame.width / 2))

        path.close()
        
        return path.cgPath
    }
    
    func setTopClip(view: UIView, pressPoint: CGPoint?) {
        
        shapeLayer.path = makePath(view: view, pressPoint: pressPoint)
        view.layer.mask = shapeLayer
    }
    
    func animatePath(view: UIView,
                     pressPoint: CGPoint,
                     curve2: CGFloat,
                     duration: CFTimeInterval) {

        (view.layer.mask as? CAShapeLayer)?.path = makePath(view: view, pressPoint: pressPoint)

        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.fromValue = makePath(view: view, pressPoint: pressPoint)
        animation.toValue = makePath(view: view, pressPoint: CGPoint(x: pressPoint.x, y: 70))
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        view.layer.mask?.add(animation, forKey: "path")

        (view.layer.mask as? CAShapeLayer)?.path = makePath(view: view, pressPoint: CGPoint(x: pressPoint.x, y: 70))
    }
}
