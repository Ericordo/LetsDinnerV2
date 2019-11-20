//
//  EventInfoViewController.swift
//  LetsDinnerV2
//
//  Created by Alex Cheung on 19/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol EventInfoViewControllerDelegate: class {
    func eventInfoVCDidTapBackButton(controller: EventInfoViewController)
}

class EventInfoViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var eventInfoTableView: UITableView!
    
    
    weak var delegate: EventInfoViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.delegate?.eventInfoVCDidTapBackButton(controller: self)
    }
    
    


}
