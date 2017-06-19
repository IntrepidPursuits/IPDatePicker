//
//  DatePicker.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/11/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import PureLayout
import Intrepid

extension Date {
    var timeComponents: DateComponents {
        get {
            return Calendar.current.dateComponents([.hour, .minute], from: self)
        }
        set {
            guard let newDate = Calendar.current.date(from: newValue) else {
                return
            }
            self = newDate
        }
    }
}

public class DatePicker: UIView {
    private let picker = UIPickerView()
    private let viewModel: DatePickerViewModel

    public weak var delegate: DatePickerDelegate? {
        get {
            return viewModel.delegate
        }
        set {
            viewModel.delegate = newValue
        }
    }

    public init(date: Date = Date(), format: DatePickerFormat) {
        viewModel = DatePickerViewModel(date: date, format: format)

        super.init(frame: .zero)

        setup()
    }

    public init(date: Date = Date(), locale: Locale = Locale.current, formatString: String = "hh:mm") {
        viewModel = DatePickerViewModel(date: date, locale: locale, formatString: formatString)

        super.init(frame: .zero)

        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        viewModel.picker = self

        picker.dataSource = viewModel
        picker.delegate = viewModel

        addSubview(picker)

        picker.autoPinEdgesToSuperviewEdges()
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
            picker.selectRow(row, inComponent: component, animated: animated)
        }
    }

    // MARK: - Intrinsic content size

    override public func invalidateIntrinsicContentSize() {
        picker.invalidateIntrinsicContentSize()
        super.invalidateIntrinsicContentSize()
    }

    override public var intrinsicContentSize: CGSize {
        return picker.intrinsicContentSize
    }
}
