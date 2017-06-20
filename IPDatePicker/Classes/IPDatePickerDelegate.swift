//
//  IPDatePickerDelegate.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit

public protocol IPDatePickerDelegate: class {
    func datePicker(_ datePicker: IPDatePicker, viewForItemForComponent component: IPDatePickerComponent, row: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView?
    func datePicker(_ datePicker: IPDatePicker, attributedSymbolForComponent component: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> NSAttributedString?
    func datePicker(_ datePicker: IPDatePicker, symbolForComponent component: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> String?

    func datePicker(_ datePicker: IPDatePicker, rowHeightForComponent component: IPDatePickerComponent) -> CGFloat?
    func datePicker(_ datePicker: IPDatePicker, widthForComponent component: IPDatePickerComponent) -> CGFloat?

    func datePicker(_ datePicker: IPDatePicker, didSelectDate date: Date)
    func datePicker(_ datePicker: IPDatePicker, didSelectRow row: Int, inComponent: IPDatePickerComponent)
}

public extension IPDatePickerDelegate {
    func datePicker(_ datePicker: IPDatePicker, viewForItemForComponent component: IPDatePickerComponent, row: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, attributedSymbolForComponent component: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> NSAttributedString? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, symbolForComponent component: IPDatePickerComponent, row: Int, suggestedSymbol: String) -> String? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, rowHeightForComponent component: IPDatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, widthForComponent component: IPDatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, didSelectDate date: Date) {}

    func datePicker(_ datePicker: IPDatePicker, didSelectRow row: Int, inComponent: IPDatePickerComponent) {}
}
