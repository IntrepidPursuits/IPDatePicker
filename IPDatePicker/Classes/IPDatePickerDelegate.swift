//
//  IPDatePickerDelegate.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit

public protocol IPDatePickerDelegate: class {
    func datePicker(_ datePicker: IPDatePicker, viewForItemForComponent: IPDatePickerComponent, row: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView?
    func datePicker(_ datePicker: IPDatePicker, attributedSymbolForComponent: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> NSAttributedString?
    func datePicker(_ datePicker: IPDatePicker, symbolForComponent: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> String?

    func datePicker(_ datePicker: IPDatePicker, rowHeightForComponent: IPDatePickerComponent) -> CGFloat?
    func datePicker(_ datePicker: IPDatePicker, widthForComponent: IPDatePickerComponent) -> CGFloat?

    func datePicker(_ datePicker: IPDatePicker, didSelectDate date: Date)
    func datePicker(_ datePicker: IPDatePicker, didSelectRow row: Int, inComponent: IPDatePickerComponent)
}

extension IPDatePickerDelegate {
    func datePicker(_ datePicker: IPDatePicker, viewForItemForComponent: IPDatePickerComponent, row: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, attributedSymbolForComponent: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> NSAttributedString? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, symbolForComponent: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> String? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, rowHeightForComponent: IPDatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, widthForComponent: IPDatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, didSelectDate date: Date) {}

    func datePicker(_ datePicker: IPDatePicker, didSelectRow row: Int, inComponent: IPDatePickerComponent) {}
}
