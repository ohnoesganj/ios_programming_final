//
//  SignUpViewController.swift
//  ch12-jangseonho-sharedPlan
//
//  Created by Mac on 2023/06/16.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var IdTextField: UITextField!
    @IBOutlet weak var PasswdTextField: UITextField!
    @IBOutlet weak var PasswdCheck: UITextField!
    
    @IBAction func SignUpDone(_ sender: UIButton) {
        if IdTextField != nil && PasswdTextField.text == PasswdCheck.text {
            
            
            
            performSegue(withIdentifier: "Login", sender: self)
        }
    }
    
}
