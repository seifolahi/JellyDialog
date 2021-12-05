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
    
    private var presentedHeight: CGFloat = 200
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
    }
    
    @objc func didPan(pan: UIPanGestureRecognizer) {
        guard let view = pan.view, let superView = view.superview,
            let presented = presentedView, let container = containerView else { return }
        
        let location = pan.translation(in: superView)
        
        switch pan.state {
        case .began:
            presented.frame.size.height = presentedHeight//container.frame.height
        case .changed:
            let velocity = pan.velocity(in: superView)
            
            switch state {
            case .interaction:
                
                presented.frame.origin.y = location.y + container.bounds.height - self.presentedHeight
            case .presentation:
                presented.frame.origin.y = location.y
            }
            direction = velocity.y
        case .ended:
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
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [weak self] in
            guard let `self` = self else { return }
            
            presented.frame = self.frameOfPresentedViewInContainerView
            
            }, completion: { (isFinished) in
                self.state = state
        })
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
    
    func changeHeight() {
        guard let container = containerView else { return }
        let maxHeight = presentingViewController.view.frame.height
        
        
        let minHeight = CGFloat(200)
        presentedHeight = CGFloat(arc4random())
            .truncatingRemainder(dividingBy: maxHeight - minHeight) + minHeight
        
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn,
                       animations: {
            
            self.presentedView?.frame.size.height = self.presentedHeight
            self.presentedView?.frame.origin.y = container.bounds.height - self.presentedHeight
            self.presentedView?.layoutIfNeeded()
            
        }, completion: nil)
        
    }
}

