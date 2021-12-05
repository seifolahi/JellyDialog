//
//  InteractiveModalTransitioningDelegate.swift
//  JellyDialog
//
//  Created by Hamid reza Seifolahi on 12/5/21.
//

import UIKit

final class InteractiveModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    var modalPresentationController: InteractiveModalPresentationController!
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        
        modalPresentationController = InteractiveModalPresentationController(presentedViewController: presented,
                                                                             presenting: presenting)
        return modalPresentationController
    }
}
