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

    func setSelectionsFromDate(_ date: Date) -> [(component: Int, item: Int)] {
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
        let possibleUnits = IPDatePickerComponent.Unit.all()

        let components = possibleUnits.flatMap { (unit: IPDatePickerComponent.Unit) -> (unit: IPDatePickerComponent.Unit, position: String.Index)? in
            guard let position = formatString.range(of: unit.formatSymbol)?.lowerBound else {
                return nil
            }

            return (unit: unit, position: position)
        }.sorted {
            return $0.position < $1.position
        }.map {
            return $0.unit
        }.enumerated().map { (index, unit) in
            return IPDatePickerComponent(unit: unit, index: index)
        }

        componentViewModels = components.map { component in
            return IPDatePickerComponentViewModel.viewModel(for: component, dateAsComponents: dateComponents, locale: locale)
        }
    }

    func selections() -> [(component: Int, item: Int)] {
        return componentViewModels.enumerated().map { (index, viewModel) in
            return (component: index, item: viewModel.selection)
        }
    }

    // Returns the selections that have changed
    func setSelectionsFromDateComponents(dateComponents: DateComponents) -> [(component: Int, item: Int)] {
        var changes = [(component: Int, item: Int)]()

        componentViewModels.enumerated().forEach { (component, viewModel) in
            let oldSelection = viewModel.selection
            viewModel.setSelectionFromDateComponents(dateComponents)
            let newSelection = viewModel.selection
            if oldSelection != newSelection {
                changes.append((component: component, item: newSelection))
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

    fileprivate func numberOfItemsInComponent(_ component: Int) -> Int {
        return componentViewModels[ip_safely: component]?.titles.count ?? 0
    }

    fileprivate func widthForComponent(_ component: Int) -> CGFloat {
        guard
            let componentViewModel = componentViewModels[ip_safely: component],
            let picker = picker,
            let width = delegate?.datePicker(picker, widthForComponent: componentViewModel.component())
            else {
                return 80.0
        }

        return width
    }

    fileprivate func itemHeightForComponent(_ component: Int) -> CGFloat {
        guard
            let componentViewModel = componentViewModels[ip_safely: component],
            let picker = picker,
            let height = delegate?.datePicker(picker, itemHeightForComponent: componentViewModel.component())
            else {
                return 44.0
        }

        return height
    }

    fileprivate func attributedTitleForItem(_ item: Int, forComponent component: Int) -> NSAttributedString? {
        guard
            let picker = picker,
            let componentViewModel = componentViewModels[ip_safely: component]
        else {
            return nil
        }

        let pickerComponent = componentViewModel.component()
        let suggestedSymbol = componentViewModel.titles[ip_safely: item] ?? ""

        return delegate?.datePicker(
            picker,
            attributedSymbolForComponent: pickerComponent,
            item: item,
            suggestedSymbol: suggestedSymbol
        )
    }

    fileprivate func titleForItem(_ item: Int, forComponent component: Int) -> String {
        guard
            let picker = picker,
            let componentViewModel = componentViewModels[ip_safely: component]
        else {
            return ""
        }

        let pickerComponent = componentViewModel.component()
        let suggestedSymbol = componentViewModel.titles[ip_safely: item] ?? ""

        return delegate?.datePicker(
            picker,
            symbolForComponent: pickerComponent,
            item: item,
            suggestedSymbol: suggestedSymbol
        ) ?? suggestedSymbol
    }

    fileprivate func viewForItem(_ item: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        guard
            let picker = picker,
            let componentViewModel = componentViewModels[ip_safely: component]
        else {
            return nil
        }

        let pickerComponent = componentViewModel.component()
        let suggestedSymbol = componentViewModel.titles[ip_safely: item] ?? ""

        return delegate?.datePicker(
            picker,
            viewForItemForComponent: pickerComponent,
            item: item,
            suggestedSymbol: suggestedSymbol,
            reusing: view
        )
    }

    fileprivate func didSelectItem(_ item: Int, inComponent component: Int) {
        guard let componentViewModel = componentViewModels[ip_safely: component] else {
            return
        }

        componentViewModel.selection = item

        guard let picker = picker, let delegate = delegate else {
            return
        }

        delegate.datePicker(picker, didSelectItem: item, inComponent: componentViewModel.component())
        delegate.datePicker(picker, didSelectDate: date)
    }

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfItemsInComponent(component)
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return widthForComponent(component)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return itemHeightForComponent(component)
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let view = viewForItem(row, forComponent: component, reusing: view) {
            return view
        }

        let label = UILabel()
        label.textAlignment = .center

        if let attributedTitle = attributedTitleForItem(row, forComponent: component) {
            label.attributedText = attributedTitle
        } else {
            label.text = titleForItem(row, forComponent: component)
        }

        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectItem(row, inComponent: component)
    }
}

extension IPDatePickerViewModel: IPPickerViewDelegate {
    func numberOfComponentsInIPPickerView(_ pickerView: IPPickerView) -> Int {
        return numberOfComponents()
    }

    func ipPickerView(_ pickerView: IPPickerView, numberOfItemsInComponent component: Int) -> Int {
        return numberOfItemsInComponent(component)
    }

    func ipPickerView(_ pickerView: IPPickerView, widthForComponent component: Int) -> CGFloat? {
        return widthForComponent(component)
    }

    func ipPickerView(_ pickerView: IPPickerView, itemHeightForComponent component: Int) -> CGFloat? {
        return itemHeightForComponent(component)
    }

    func ipPickerView(_ pickerView: IPPickerView, viewForItem item: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        return viewForItem(item, forComponent: component, reusing: view)
    }

    func ipPickerView(_ pickerView: IPPickerView, titleForItem item: Int, forComponent component: Int) -> String? {
        return titleForItem(item, forComponent: component)
    }

    func ipPickerView(_ pickerView: IPPickerView, attributedTitleForItem item: Int, forComponent component: Int) -> NSAttributedString? {
        return attributedTitleForItem(item, forComponent: component)
    }

    func ipPickerView(_ pickerView: IPPickerView, didSelectItem item: Int, forComponent component: Int) {
        didSelectItem(item, inComponent: component)
    }

    func ipPickerView(_ pickerView: IPPickerView, viewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> UIView? {
        guard
            let picker = picker,
            let leftDateComponent = componentViewModels[ip_safely: leftComponent]?.component(),
            let rightDateComponent = componentViewModels[ip_safely: rightComponent]?.component()
        else {
            return nil
        }
        return delegate?.datePicker(picker, viewForSpacingBetweenComponent: leftDateComponent, and: rightDateComponent)
    }

    func ipPickerView(_ pickerView: IPPickerView, widthOfViewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> CGFloat? {
        guard
            let picker = picker,
            let leftDateComponent = componentViewModels[ip_safely: leftComponent]?.component(),
            let rightDateComponent = componentViewModels[ip_safely: rightComponent]?.component()
            else {
                return nil
        }
        return delegate?.datePicker(picker, widthOfViewForSpacingBetweenComponent: leftDateComponent, and: rightDateComponent)
    }

    func ipPickerView(_ pickerView: IPPickerView, componentViewForComponent component: Int) -> UIView? {
        guard
            let componentViewModel = componentViewModels[ip_safely: component],
            let delegate = delegate,
            let picker = picker
        else {
            return nil
        }

        if let view = delegate.datePicker(picker, componentViewForComponent: componentViewModel.component()) {
            return view
        }

        return componentViewModel.defaultComponentView()
    }

    func ipPickerView(_ pickerView: IPPickerView, didScrollItemView itemView: UIView, forComponent component: Int, forItem item: Int, toOffsetFromCenter offset: CGFloat) {
        guard
            let componentViewModel = componentViewModels[ip_safely: component],
            let delegate = delegate,
            let picker = picker
        else {
            return
        }

        delegate.datePicker(picker, didScrollItemView: itemView, forComponent: componentViewModel.component(), forItem: item, toOffsetFromCenter: offset)
    }

    // MARK: - Default Component View

    private func defaultViewForComponent(component: Int) -> UIView? {
        guard let componentViewModel = componentViewModels[ip_safely: component] else {
            return nil
        }

        return componentViewModel.defaultComponentView()
    }
}
