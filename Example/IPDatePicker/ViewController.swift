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

class ViewController: UIViewController, IPDatePickerDelegate {
    let picker = IPDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(picker.view)
        picker.view.autoCenterInSuperview()

        picker.delegate = self
    }

    // MARK: - IPDatePickerDelegate

    func datePicker(_ datePicker: IPDatePicker, attributedSymbolForComponent component: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> NSAttributedString? {
        guard component == .amPm else {
            return nil
        }

        let attributes = [
            NSForegroundColorAttributeName: UIColor.blue
        ]
        return NSAttributedString(string: suggestedSymbol, attributes: attributes)
    }
}
