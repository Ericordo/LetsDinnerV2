//
//  DynamicHeightTableView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 23/5/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class DynamicHeightTableView: UITableView {
  override open var intrinsicContentSize: CGSize {
    return contentSize
  }
}
