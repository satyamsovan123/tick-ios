//
//  SignupViewController.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 09/09/23.
//

import UIKit

class SignupViewController: UIViewController {
    
    var authenticationManager = AuthenticationManager()
    let commonService = CommonService()

    var email: String = ""
    var password: String = ""
    var token: String = ""
    var message: String = K.errorMessage.genericError
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var brandIllustration: UIImageView!

    @IBOutlet weak var brandIllustrationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandIllustrationWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signupStackView: UIStackView!
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
    
    @IBAction func signupPressed(_ sender: UIButton) {
        signupButton.configuration?.showsActivityIndicator = true
        signupButton.isEnabled = false
        let authenticationRequest = AuthenticationRequest(email: email, password: password)
         authenticationManager.authenticate(authenticationRequest: authenticationRequest, action: "signup")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "signupToInformation") {
            let destinationViewController = segue.destination as! InformationViewController
            destinationViewController.message = message
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
        
        brandIllustration.alpha = 0.7
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
        // Deactivate constraints for when the keyboard is shown
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
        
        brandIllustration.alpha = 1
       
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

}

extension SignupViewController: UITextFieldDelegate {
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

extension SignupViewController: AuthenticationManagerDelegate {
    func didCompleteAuthentication(_ authenticationManager: AuthenticationManager, authenticationResponse: AuthenticationResponse, token: String) {
        DispatchQueue.main.async {
            self.token = token
            self.message = authenticationResponse.message
            self.signupButton.isEnabled = true
            self.signupButton.configuration?.showsActivityIndicator = false
            self.commonService.logger(authenticationResponse)
            if(self.message == K.successMessage.signupSuccessful) {
                self.performSegue(withIdentifier: "signupToTodo", sender: self)
            } else {
                self.performSegue(withIdentifier: "signupToInformation", sender: self)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.signupButton.isEnabled = true
            self.signupButton.configuration?.showsActivityIndicator = false
            self.performSegue(withIdentifier: "signupToInformation", sender: self)
            self.commonService.logger(error)
        }
    }
}
