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

    private var pickerView: IPDatePickerViewProtocol {
        guard let pickerView = view as? IPDatePickerViewProtocol else {
            fatalError("IPDatePickerController must have a view that confirms to IPDatePickerProtocol")
        }
        return pickerView
    }

    private let viewModel: IPDatePickerViewModel

    public weak var delegate: IPDatePickerDelegate? {
        get {
            return viewModel.delegate
        }
        set {
            viewModel.delegate = newValue
        }
    }

    public init(view: UIView = UIPickerView(), date: Date = Date(), format: IPDatePickerFormat) {
        self.view = view
        viewModel = IPDatePickerViewModel(date: date, format: format)
        setup()
    }

    public init(view: UIView = UIPickerView(), date: Date = Date(), locale: Locale = Locale.current, formatString: String = "hh:mm") {
        self.view = view
        viewModel = IPDatePickerViewModel(date: date, locale: locale, formatString: formatString)
        setup()
    }

    private func setup() {
        viewModel.picker = self

        pickerView.dataSource = viewModel
        pickerView.delegate = viewModel
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
        viewModel.date = date

        viewModel.selectedRows().enumerated().forEach { (component, row) in
            pickerView.selectRow(row, inComponent: component, animated: animated)
        }
    }
}
