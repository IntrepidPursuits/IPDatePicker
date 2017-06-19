//
//  DatePickerDelegate.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit

protocol DatePickerDelegate: class {
    func datePicker(_ datePicker: DatePicker, viewForItemForComponent: DatePickerComponent, row: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView?
    func datePicker(_ datePicker: DatePicker, attributedSymbolForComponent: DatePickerComponent, row: Int, suggestedSymbol: String) -> NSAttributedString?
    func datePicker(_ datePicker: DatePicker, symbolForComponent: DatePickerComponent, row: Int, suggestedSymbol: String) -> String?

    func datePicker(_ datePicker: DatePicker, rowHeightForComponent: DatePickerComponent) -> CGFloat?
    func datePicker(_ datePicker: DatePicker, widthForComponent: DatePickerComponent) -> CGFloat?

    func datePicker(_ datePicker: DatePicker, didSelectDate date: Date)
    func datePicker(_ datePicker: DatePicker, didSelectRow row: Int, inComponent: DatePickerComponent)
}

extension DatePickerDelegate {
    func datePicker(_ datePicker: DatePicker, viewForItemForComponent: DatePickerComponent, row: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView? {
        return nil
    }

    func datePicker(_ datePicker: DatePicker, attributedSymbolForComponent: DatePickerComponent, row: Int, suggestedSymbol: String) -> NSAttributedString? {
        return nil
    }

    func datePicker(_ datePicker: DatePicker, symbolForComponent: DatePickerComponent, row: Int, suggestedSymbol: String) -> String? {
        return nil
    }

    func datePicker(_ datePicker: DatePicker, rowHeightForComponent: DatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: DatePicker, widthForComponent: DatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: DatePicker, didSelectDate date: Date) {}

    func datePicker(_ datePicker: DatePicker, didSelectRow row: Int, inComponent: DatePickerComponent) {}
}
