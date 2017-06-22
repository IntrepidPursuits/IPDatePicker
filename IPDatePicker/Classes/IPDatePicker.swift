//
//  IPDatePicker.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/11/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import PureLayout
import Intrepid

public class IPDatePicker {
    public var view: UIView

    private var pickerView: UIPickerView? {
        return view as? UIPickerView
    }

    private var ipPickerView: IPPickerViewProtocol? {
        return view as? IPPickerViewProtocol
    }

    private let viewModel: IPDatePickerViewModel

    public weak var delegate: IPDatePickerDelegate? {
        get {
            return viewModel.delegate
        }
        set {
            viewModel.delegate = newValue
            didSetDelegate()
        }
    }

    public init(
        view: UIView = UIPickerView(),
        date: Date = Date(),
        locale: Locale = Locale.current,
        formatString: String = "h:mm a"
    ) {
        guard (view as? UIPickerView) != nil || (view as? IPPickerViewProtocol) != nil else {
            fatalError("IPDatePicker view must either be a UIPickerView or conform to IPPickerViewProtocol")
        }

        self.view = view
        viewModel = IPDatePickerViewModel(date: date, locale: locale, formatString: formatString)
        setup()
    }

    private func setup() {
        viewModel.picker = self

        if let pickerView = pickerView {
            pickerView.dataSource = viewModel
            pickerView.delegate = viewModel
        } else {
            ipPickerView?.delegate = viewModel
        }

        setViewSelections(viewModel.selections(), animated: false)
    }

    private func didSetDelegate() {
        if let pickerView = pickerView {
            pickerView.reloadAllComponents()
        } else {
            ipPickerView?.reloadAllComponents()
        }

        setDate(date, animated: false)
    }

    // MARK: - Date getter/setter

    public var date: Date {
        get {
            return viewModel.date
        }
        set {
            setDate(newValue, animated: false)
        }
    }

    public func setDate(_ date: Date, animated: Bool) {
        let changedSelections = viewModel.setSelectionsFromDate(date)
        setViewSelections(changedSelections, animated: animated)
    }

    private func setViewSelections(_ selections: [(component: Int, row: Int)], animated: Bool) {
        selections.forEach { (component: Int, row: Int) in
            if let pickerView = pickerView {
                pickerView.selectRow(row, inComponent: component, animated: animated)
            } else {
                ipPickerView?.selectRow(row, inComponent: component, animated: animated)
            }
        }
    }
}
