//
//  CustomSafariView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 12/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SafariServices

class CustomSafariVC: SFSafariViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSafariView()
    }

    private func configureSafariView() {
        self.registerForNotification()
        self.preferredControlTintColor = UIColor.activeButton
        self.preferredBarTintColor = Colors.paleGray
        self.dismissButtonStyle = .close
        self.modalPresentationStyle = .overFullScreen
    }
}
