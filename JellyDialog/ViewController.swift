//
//  ViewController.swift
//  JellyDialog
//
//  Created by Hamid reza Seifolahi on 12/5/21.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    var dialogVC: JellyDialogViewController?
    var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Show", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 32)
        btn.addTarget(self, action: #selector(self.openDialog), for: .touchUpInside)
        view.addSubview(btn)
        view.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
        
    }
    
    @objc func openDialog() {
        
        dialogVC = JellyDialogViewController()
        dialogVC?.modalPresentationStyle = .custom
        detailsTransitioningDelegate = InteractiveModalTransitioningDelegate()
        dialogVC?.transitioningDelegate = detailsTransitioningDelegate
        present(dialogVC!, animated: true, completion: nil)
    }
}
