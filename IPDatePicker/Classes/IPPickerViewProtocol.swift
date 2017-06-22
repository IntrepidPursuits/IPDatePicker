//
//  IPDatePickerViewProtocol.swift
//  Pods
//
//  Created by Andrew Dolce on 6/19/17.
//
//

import UIKit

public protocol IPPickerViewDelegate: class {
    func numberOfComponentsInIPPickerView(_ pickerView: IPPickerView) -> Int
    func ipPickerView(_ pickerView: IPPickerView, numberOfRowsInComponent component: Int) -> Int

    func ipPickerView(_ pickerView: IPPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView?
    func ipPickerView(_ pickerView: IPPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    func ipPickerView(_ pickerView: IPPickerView, titleForRow row: Int, forComponent component: Int) -> String?

    func ipPickerView(_ pickerView: IPPickerView, widthForComponent component: Int) -> CGFloat?
    func ipPickerView(_ pickerView: IPPickerView, rowHeightForComponent component: Int) -> CGFloat?

    func ipPickerView(_ pickerView: IPPickerView, didSelectRow row: Int, forComponent component: Int)
}

extension IPPickerViewDelegate {
    func ipPickerView(_ pickerView: IPPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, widthForComponent component: Int) -> CGFloat? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, rowHeightForComponent component: Int) -> CGFloat? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, didSelectRow row: Int, forComponent component: Int) {
    }
}

public protocol IPPickerViewProtocol: class {
    var delegate: IPPickerViewDelegate? { get set }

    func reloadAllComponents()
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool)
}
