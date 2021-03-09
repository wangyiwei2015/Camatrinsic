//
//  AboutView.swift
//  CaMat
//
//  Created by Wangyiwei on 2020/2/20.
//  Copyright © 2020 Wangyiwei. All rights reserved.
//

import UIKit
import MessageUI
import SwiftyStoreKit

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var txt: UITextView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var reviewBtn: UIButton!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var iapBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.layer.cornerRadius = backBtn.frame.height / 4
        contactBtn.layer.cornerRadius = contactBtn.frame.height / 4
        reviewBtn.layer.cornerRadius = reviewBtn.frame.height / 4
        view.backgroundColor = UIColor(white: 0.99, alpha: 1)
        txt.backgroundColor = view.backgroundColor
        
        //if(iapFirstCheckValid) {
            //
        //} else {
            //
        //}
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getPro(_ sender: UIButton) {
    }
    
    @IBAction func restore(_ sender: UIButton) {
    }
    
    @IBAction func contact(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else {return}
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        emailVC.setSubject("Camatrinsic : Feedback")
        emailVC.setToRecipients(["wangyw.dev@outlook.com"])
        emailVC.setMessageBody("", isHTML: false)
        self.present(emailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func review(_ sender: Any) {
        UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id1501150506")!, options: [:], completionHandler: nil)
        //TODO: App ID
    }
}
