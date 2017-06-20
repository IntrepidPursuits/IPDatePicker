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
    private var picker = IPDatePicker()

    let englishButton = UIButton(type: .system)
    let simplifiedChineseButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPickerWithLocale()
        setupButtons()
    }

    private func setupPickerWithLocale(_ locale: Locale = .current) {
        let date = picker.date
        picker.view.removeFromSuperview()

        picker = IPDatePicker(date: date, locale: locale)
        picker.delegate = self

        view.addSubview(picker.view)
        picker.view.autoCenterInSuperview()
    }

    private func setupButtons() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually

        stack.addArrangedSubview(englishButton)
        stack.addArrangedSubview(simplifiedChineseButton)

        englishButton.setTitle("English", for: .normal)
        englishButton.addTarget(self, action: #selector(didPressEnglish), for: .touchUpInside)

        simplifiedChineseButton.setTitle("Simplified Chinese", for: .normal)
        simplifiedChineseButton.addTarget(self, action: #selector(didPressSimplifiedChinese), for: .touchUpInside)

        view.addSubview(stack)
        stack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(0.0, 40.0, 40.0, 40.0), excludingEdge: .top)
    }

    private dynamic func didPressEnglish() {
        let locale = Locale(identifier: "en")
        setupPickerWithLocale(locale)
    }

    private dynamic func didPressSimplifiedChinese() {
        let locale = Locale(identifier: "zh")
        setupPickerWithLocale(locale)
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
