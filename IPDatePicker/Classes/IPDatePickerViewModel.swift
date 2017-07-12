//
//  IPDatePickerViewModel.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit

final class IPDatePickerViewModel: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    private(set) var locale: Locale
    private(set) var formatString: String

    weak var picker: IPDatePicker?

    var date: Date {
        get {
            return Calendar.current.date(from: dateComponents) ?? Date()
        }
        set {
            dateComponents = Calendar.current.dateComponents(calendarComponents, from: date)
        }
    }

    func setSelectionsFromDate(_ date: Date) -> [(component: Int, row: Int)] {
        let dateComponents = Calendar.current.dateComponents(calendarComponents, from: date)
        return setSelectionsFromDateComponents(dateComponents: dateComponents)
    }

    fileprivate var componentViewModels = [IPDatePickerComponentViewModel]()

    weak var delegate: IPDatePickerDelegate?

    private var calendarComponents: Set<Calendar.Component> {
        return Set(componentViewModels.flatMap { $0.calendarComponent() })
    }

    private var dateComponents: DateComponents {
        get {
            return dateComponentsFromSelections()
        }
        set {
            _ = setSelectionsFromDateComponents(dateComponents: newValue)
        }
    }

    func selectedRows() -> [Int] {
        return componentViewModels.map { $0.selection }
    }

    init(date: Date = Date(), locale: Locale = Locale.current, formatString: String) {
        self.locale = locale
        self.formatString = DateFormatter.dateFormat(fromTemplate: formatString, options: 0, locale: locale) ?? formatString

        super.init()

        let dateComponents = date.timeComponents
        setupPickerComponentsFromDateComponents(dateComponents)
        self.dateComponents = dateComponents
    }

    func setupPickerComponentsFromDateComponents(_ dateComponents: DateComponents) {
        let possibleComponents: [IPDatePickerComponentViewModel] = [
            TwelveHourComponentViewModel(dateComponents: dateComponents, locale: locale),
            TwentyFourHourComponentViewModel(dateComponents: dateComponents, locale: locale),
            MinutesComponentViewModel(dateComponents: dateComponents, locale: locale),
            AmPmComponentViewModel(dateComponents: dateComponents, locale: locale)
        ]

        componentViewModels = possibleComponents.flatMap { (component: IPDatePickerComponentViewModel) -> (component: IPDatePickerComponentViewModel, position: String.Index)? in
            guard let position = formatString.range(of: component.formatSymbol())?.lowerBound else {
                return nil
            }

            return (component: component, position: position)
        }.sorted {
            return $0.position < $1.position
        }.map {
            return $0.component
        }
    }

    func selections() -> [(component: Int, row: Int)] {
        return componentViewModels.enumerated().map { (index, viewModel) in
            return (component: index, row: viewModel.selection)
        }
    }

    // Returns the selections that have changed
    func setSelectionsFromDateComponents(dateComponents: DateComponents) -> [(component: Int, row: Int)] {
        var changes = [(component: Int, row: Int)]()

        componentViewModels.enumerated().forEach { (component, viewModel) in
            let oldSelection = viewModel.selection
            viewModel.setSelectionFromDateComponents(dateComponents)
            let newSelection = viewModel.selection
            if oldSelection != newSelection {
                changes.append((component: component, row: newSelection))
            }
        }

        return changes
    }

    func dateComponentsFromSelections() -> DateComponents {
        let zeroTime = DateComponents(calendar: Calendar.current, hour: 0, minute: 0)
        let selectedTime = componentViewModels.reduce(zeroTime) { (previousResult, component) -> DateComponents in
            let selectedDateComponents = component.selectedDateComponents()
            var result = previousResult
            result.hour = (result.hour ?? 0) + (selectedDateComponents.hour ?? 0)
            result.minute = (result.minute ?? 0) + (selectedDateComponents.minute ?? 0)

            return result
        }

        return selectedTime
    }

    // MARK: Data Source and Delegate Helpers

    fileprivate func numberOfComponents() -> Int {
        return componentViewModels.count
    }

    fileprivate func numberOfRowsInComponent(_ component: Int) -> Int {
        return componentViewModels[ip_safe: component]?.titles.count ?? 0
    }

    fileprivate func widthForComponent(_ component: Int) -> CGFloat {
        guard
            let componentViewModel = componentViewModels[ip_safe: component],
            let picker = picker,
            let width = delegate?.datePicker(picker, widthForComponent: componentViewModel.component())
            else {
                return 80.0
        }

        return width
    }

    fileprivate func rowHeightForComponent(_ component: Int) -> CGFloat {
        guard
            let componentViewModel = componentViewModels[ip_safe: component],
            let picker = picker,
            let height = delegate?.datePicker(picker, rowHeightForComponent: componentViewModel.component())
            else {
                return 44.0
        }

        return height
    }

    fileprivate func attributedTitleForRow(_ row: Int, forComponent component: Int) -> NSAttributedString? {
        guard
            let picker = picker,
            let componentViewModel = componentViewModels[ip_safe: component]
        else {
            return nil
        }

        let pickerComponent = componentViewModel.component()
        let suggestedSymbol = componentViewModel.titles[ip_safe: row] ?? ""

        return delegate?.datePicker(
            picker,
            attributedSymbolForComponent: pickerComponent,
            row: row,
            suggestedSymbol: suggestedSymbol
        )
    }

    fileprivate func titleForRow(_ row: Int, forComponent component: Int) -> String {
        guard
            let picker = picker,
            let componentViewModel = componentViewModels[ip_safe: component]
        else {
            return ""
        }

        let pickerComponent = componentViewModel.component()
        let suggestedSymbol = componentViewModel.titles[ip_safe: row] ?? ""

        return delegate?.datePicker(
            picker,
            symbolForComponent: pickerComponent,
            row: row,
            suggestedSymbol: suggestedSymbol
        ) ?? suggestedSymbol
    }

    fileprivate func viewForRow(_ row: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        guard
            let picker = picker,
            let componentViewModel = componentViewModels[ip_safe: component]
        else {
            return nil
        }

        let pickerComponent = componentViewModel.component()
        let suggestedSymbol = componentViewModel.titles[ip_safe: row] ?? ""

        return delegate?.datePicker(
            picker,
            viewForItemForComponent: pickerComponent,
            row: row,
            suggestedSymbol: suggestedSymbol,
            reusing: view
        )
    }

    fileprivate func didSelectRow(_ row: Int, inComponent component: Int) {
        guard let componentViewModel = componentViewModels[ip_safe: component] else {
            return
        }

        componentViewModel.selection = row

        guard let picker = picker, let delegate = delegate else {
            return
        }

        delegate.datePicker(picker, didSelectRow: row, inComponent: componentViewModel.component())
        delegate.datePicker(picker, didSelectDate: date)
    }

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfRowsInComponent(component)
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return widthForComponent(component)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeightForComponent(component)
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let view = viewForRow(row, forComponent: component, reusing: view) {
            return view
        }

        let label = UILabel()
        label.textAlignment = .center

        if let attributedTitle = attributedTitleForRow(row, forComponent: component) {
            label.attributedText = attributedTitle
        } else {
            label.text = titleForRow(row, forComponent: component)
        }

        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectRow(row, inComponent: component)
    }

    // MARK: - IPPickerViewDelegate

    func numberOfComponentsInIPPickerView(_ pickerView: IPPickerView) -> Int {
        return numberOfComponents()
    }
}

extension IPDatePickerViewModel: IPPickerViewDelegate {
    func ipPickerView(_ pickerView: IPPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfRowsInComponent(component)
    }

    func ipPickerView(_ pickerView: IPPickerView, widthForComponent component: Int) -> CGFloat? {
        return widthForComponent(component)
    }

    func ipPickerView(_ pickerView: IPPickerView, rowHeightForComponent component: Int) -> CGFloat? {
        return rowHeightForComponent(component)
    }

    func ipPickerView(_ pickerView: IPPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        return viewForRow(row, forComponent: component, reusing: view)
    }

    func ipPickerView(_ pickerView: IPPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleForRow(row, forComponent: component)
    }

    func ipPickerView(_ pickerView: IPPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return attributedTitleForRow(row, forComponent: component)
    }

    func ipPickerView(_ pickerView: IPPickerView, didSelectRow row: Int, forComponent component: Int) {
        didSelectRow(row, inComponent: component)
    }

    func ipPickerView(_ pickerView: IPPickerView, viewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> UIView? {
        guard
            let picker = picker,
            let leftDateComponent = componentViewModels[ip_safe: leftComponent]?.component(),
            let rightDateComponent = componentViewModels[ip_safe: rightComponent]?.component()
        else {
            return nil
        }
        return delegate?.datePicker(picker, viewForSpacingBetweenComponent: leftDateComponent, and: rightDateComponent)
    }

    func ipPickerView(_ pickerView: IPPickerView, widthOfViewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> CGFloat? {
        guard
            let picker = picker,
            let leftDateComponent = componentViewModels[ip_safe: leftComponent]?.component(),
            let rightDateComponent = componentViewModels[ip_safe: rightComponent]?.component()
            else {
                return nil
        }
        return delegate?.datePicker(picker, widthOfViewForSpacingBetweenComponent: leftDateComponent, and: rightDateComponent)
    }
}
