//
//  File.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 20/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit



class StandardTableView: UITableView {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tableFooterView = UIView()
    }
    
    private func registerCell(_ nibName: String) {
        self.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
}
