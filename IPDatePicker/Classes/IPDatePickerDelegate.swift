//
//  IPDatePickerDelegate.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit

public protocol IPDatePickerDelegate: class {
    func datePicker(_ datePicker: IPDatePicker, viewForItemForComponent component: IPDatePickerComponent, item: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView?
    func datePicker(_ datePicker: IPDatePicker, attributedSymbolForComponent component: IPDatePickerComponent, item: Int, suggestedSymbol: String) -> NSAttributedString?
    func datePicker(_ datePicker: IPDatePicker, symbolForComponent component: IPDatePickerComponent, item: Int, suggestedSymbol: String) -> String?

    func datePicker(_ datePicker: IPDatePicker, itemHeightForComponent component: IPDatePickerComponent) -> CGFloat?
    func datePicker(_ datePicker: IPDatePicker, widthForComponent component: IPDatePickerComponent) -> CGFloat?

    func datePicker(_ datePicker: IPDatePicker, didSelectDate date: Date)
    func datePicker(_ datePicker: IPDatePicker, didSelectItem item: Int, inComponent: IPDatePickerComponent)

    func datePicker(_ datePicker: IPDatePicker, viewForSpacingBetweenComponent leftComponent: IPDatePickerComponent, and rightComponent: IPDatePickerComponent) -> UIView?
    func datePicker(_ datePicker: IPDatePicker, widthOfViewForSpacingBetweenComponent leftComponent: IPDatePickerComponent, and rightComponent: IPDatePickerComponent) -> CGFloat?

    func datePicker(
        _ datePicker: IPDatePicker,
        componentViewForComponent component: IPDatePickerComponent
    ) -> UIView?

    // For now this doesn't work if you override the component view
    func datePicker(
        _ datePicker: IPDatePicker,
        didScrollItemView itemView: UIView,
        forComponent component: IPDatePickerComponent,
        forItem item: Int,
        toOffsetFromCenter offset: CGFloat
    )
}

public extension IPDatePickerDelegate {
    func datePicker(_ datePicker: IPDatePicker, viewForItemForComponent component: IPDatePickerComponent, item: Int, suggestedSymbol: String, reusing view: UIView?) -> UIView? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, attributedSymbolForComponent component: IPDatePickerComponent, item: Int, suggestedSymbol: String) -> NSAttributedString? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, symbolForComponent component: IPDatePickerComponent, item: Int, suggestedSymbol: String) -> String? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, itemHeightForComponent component: IPDatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, widthForComponent component: IPDatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, didSelectDate date: Date) {}

    func datePicker(_ datePicker: IPDatePicker, didSelectItem item: Int, inComponent: IPDatePickerComponent) {}

    func datePicker(_ datePicker: IPDatePicker, viewForSpacingBetweenComponent leftComponent: IPDatePickerComponent, and rightComponent: IPDatePickerComponent) -> UIView? {
        return nil
    }

    func datePicker(_ datePicker: IPDatePicker, widthOfViewForSpacingBetweenComponent leftComponent: IPDatePickerComponent, and rightComponent: IPDatePickerComponent) -> CGFloat? {
        return nil
    }

    func datePicker(
        _ datePicker: IPDatePicker,
        componentViewForComponent component: IPDatePickerComponent
    ) -> UIView? {
        return nil
    }

    func datePicker(
        _ datePicker: IPDatePicker,
        didScrollItemView itemView: UIView,
        forComponent component: IPDatePickerComponent,
        forItem item: Int,
        toOffsetFromCenter offset: CGFloat
    ) {
    }
}
