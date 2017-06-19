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

    private var componentViewModels = [IPDatePickerComponentViewModel]()

    weak var delegate: IPDatePickerDelegate?

    private var calendarComponents: Set<Calendar.Component> {
        return Set(componentViewModels.flatMap { $0.calendarComponent() })
    }

    private var dateComponents: DateComponents {
        get {
            return dateComponentsFromSelections()
        }
        set {
            setSelectionsFromDateComponents(dateComponents: newValue)
        }
    }

    func selectedRows() -> [Int] {
        return componentViewModels.map { $0.selection }
    }

    convenience init(date: Date = Date(), format: IPDatePickerFormat) {
        let formatString = format.localizedFormatString() ?? "hh:mm"
        self.init(date: date, locale: format.locale, formatString: formatString)
    }

    init(date: Date = Date(), locale: Locale = Locale.current, formatString: String = "hh:mm") {
        self.locale = locale
        self.formatString = formatString

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

    func setSelectionsFromDateComponents(dateComponents: DateComponents) {
        componentViewModels.forEach { viewModel in
            viewModel.setSelectionFromDateComponents(dateComponents)
        }
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

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return componentViewModels.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return componentViewModels[ip_safe: component]?.titles.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        guard
            let componentViewModel = componentViewModels[ip_safe: component],
            let picker = picker,
            let width = delegate?.datePicker(picker, widthForComponent: componentViewModel.component())
        else {
            return 80.0
        }

        return width
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        guard
            let componentViewModel = componentViewModels[ip_safe: component],
            let picker = picker,
            let height = delegate?.datePicker(picker, rowHeightForComponent: componentViewModel.component())
        else {
            return 44.0
        }

        return height
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard
            let picker = picker,
            let componentViewModel = componentViewModels[ip_safe: component]
        else {
            return UIView()
        }

        let pickerComponent = componentViewModel.component()
        let suggestedSymbol = componentViewModel.titles[ip_safe: row] ?? ""

        if let itemView = delegate?.datePicker(
            picker,
            viewForItemForComponent: pickerComponent,
            row: row,
            suggestedSymbol: suggestedSymbol,
            reusing: view
        ) {
            return itemView
        }

        let label = UILabel()

        if let attributedSymbol = delegate?.datePicker(
            picker,
            attributedSymbolForComponent: pickerComponent,
            row: row,
            suggestedSymbol: suggestedSymbol
        ) {
            label.attributedText = attributedSymbol

            return label
        }

        label.textAlignment = .center

        label.text = delegate?.datePicker(
            picker,
            symbolForComponent: pickerComponent,
            row: row,
            suggestedSymbol: suggestedSymbol
        ) ?? suggestedSymbol

        return label
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
}
