//
//  IPDatePickerViewProtocol.swift
//  Pods
//
//  Created by Andrew Dolce on 6/19/17.
//
//

import UIKit

public protocol IPDatePickerViewProtocol: class {
    var delegate: UIPickerViewDelegate? { get set }
    var dataSource: UIPickerViewDataSource? { get set }

    func selectRow(_ row: Int, inComponent component: Int, animated: Bool)
}

extension UIPickerView: IPDatePickerViewProtocol {}
