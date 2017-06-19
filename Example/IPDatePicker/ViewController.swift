//
//  ViewController.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 06/19/2017.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit
import IPDatePicker
import PureLayout

class ViewController: UIViewController {
    let picker = DatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(picker)
        picker.autoCenterInSuperview()
    }
}
