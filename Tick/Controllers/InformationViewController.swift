//
//  InformationViewController.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 09/09/23.
//

import UIKit

class InformationViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    var message = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }


}
