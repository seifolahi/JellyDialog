//
//  JellyDialogViewController.swift
//  JellyDialog
//
//  Created by Hamid reza Seifolahi on 12/5/21.
//

import UIKit

class JellyDialogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Random", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 32)
        btn.addTarget(self, action: #selector(self.changeHeight), for: .touchUpInside)
        view.addSubview(btn)
        view.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        view.topAnchor.constraint(equalTo: btn.topAnchor, constant: -100).isActive = true
    }
    
    @objc func changeHeight() {
        if let delegate = transitioningDelegate as? InteractiveModalTransitioningDelegate {
            delegate.modalPresentationController.changeHeight()
        }
    }
}
