//
//  SigninViewController.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 09/09/23.
//

import UIKit

class SigninViewController: UIViewController {

    var authenticationManager = AuthenticationManager()
    let commonService = CommonService()
    
    var token: String = ""
    var email: String = ""
    var password: String = ""
    var message: String = K.errorMessage.genericError
    
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var brandIllustration: UIImageView!
    
    @IBOutlet weak var signinStackView: UIStackView!
    
    @IBOutlet weak var brandIllustrationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandIllustrationHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        passwordTextField.delegate = self
        emailTextField.delegate = self
        authenticationManager.delegate = self
    }
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func signinPressed(_ sender: UIButton) {
        
        signinButton.isEnabled = false
        signinButton.configuration?.showsActivityIndicator = true
        let authenticationRequest = AuthenticationRequest(email: email, password: password)
        authenticationManager.authenticate(authenticationRequest: authenticationRequest, action: "signin")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "signinToInformation") {
            let destinationViewController = segue.destination as! InformationViewController
            destinationViewController.message = message
        }
        
        if(segue.identifier == "signinToTodo") {
            let destinationViewController = segue.destination as! TodoViewController
            destinationViewController.token = token
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        // Create a vertical (Y-axis) centering constraint
        let verticalConstraint = NSLayoutConstraint(item: brandIllustration!,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: brandIllustration.superview,
                                                    attribute: .centerY,
                                                    multiplier: 1.0,
                                                    constant: 90.0)

        // Add both constraints to the image view's superview
        brandIllustration.superview?.addConstraints([verticalConstraint])


        
        brandIllustrationHeightConstraint.isActive = false
            brandIllustrationWidthConstraint.isActive = false

            // Activate constraints for when the keyboard is shown
            brandIllustrationHeightConstraint = brandIllustration.heightAnchor.constraint(lessThanOrEqualToConstant: 210.0)
            brandIllustrationWidthConstraint = brandIllustration.widthAnchor.constraint(lessThanOrEqualToConstant: 150.0)
            brandIllustrationHeightConstraint.isActive = true
            brandIllustrationWidthConstraint.isActive = true

            // Apply the constraint changes immediately
            view.layoutIfNeeded()

    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // Create a vertical (Y-axis) centering constraint
        let verticalConstraint = NSLayoutConstraint(item: brandIllustration!,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: brandIllustration.superview,
                                                    attribute: .centerY,
                                                    multiplier: 1.0,
                                                    constant: 0.0)

        // Add both constraints to the image view's superview
        brandIllustration.superview?.addConstraints([verticalConstraint])

        
        // Deactivate constraints for when the keyboard is shown
            brandIllustrationHeightConstraint.isActive = false
            brandIllustrationWidthConstraint.isActive = false

            // Activate constraints for when the keyboard is hidden
            brandIllustrationHeightConstraint = brandIllustration.heightAnchor.constraint(greaterThanOrEqualToConstant: 260.0)
            brandIllustrationWidthConstraint = brandIllustration.widthAnchor.constraint(greaterThanOrEqualToConstant: 200.0)
            brandIllustrationHeightConstraint.isActive = true
            brandIllustrationWidthConstraint.isActive = true

            // Apply the constraint changes immediately
            view.layoutIfNeeded()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(emailTextField.text != "") {
            email = emailTextField.text ?? ""
            emailTextField.endEditing(true)
        }
        if(passwordTextField.text != "") {
            password = passwordTextField.text ?? ""
            passwordTextField.endEditing(true)
        }
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(emailTextField.text != "") {
            email = emailTextField.text ?? ""
            emailTextField.endEditing(true)
        }
        if(passwordTextField.text != "") {
            password = passwordTextField.text ?? ""
            passwordTextField.endEditing(true)
        }
        return true
    }
}

extension SigninViewController: AuthenticationManagerDelegate {
    func didCompleteAuthentication(_ authenticationManager: AuthenticationManager, authenticationResponse: AuthenticationResponse, token: String) {
        DispatchQueue.main.async {
            self.token = token
            self.message = authenticationResponse.message
            self.signinButton.isEnabled = true
            self.signinButton.configuration?.showsActivityIndicator = false
            self.commonService.logger(authenticationResponse)
            if(self.message == K.successMessage.signinSuccessful) {
                self.performSegue(withIdentifier: "signinToTodo", sender: self)
            } else {
                self.performSegue(withIdentifier: "signinToInformation", sender: self)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.signinButton.isEnabled = true
            self.signinButton.configuration?.showsActivityIndicator = false
            self.performSegue(withIdentifier: "signinToInformation", sender: self)
            self.commonService.logger(error)
        }
    }
}
