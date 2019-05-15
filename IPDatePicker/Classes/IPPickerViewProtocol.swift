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
    func ipPickerView(_ pickerView: IPPickerView, numberOfItemsInComponent component: Int) -> Int

    func ipPickerView(_ pickerView: IPPickerView, viewForItem item: Int, forComponent component: Int, reusing view: UIView?) -> UIView?
    func ipPickerView(_ pickerView: IPPickerView, attributedTitleForItem item: Int, forComponent component: Int) -> NSAttributedString?
    func ipPickerView(_ pickerView: IPPickerView, titleForItem item: Int, forComponent component: Int) -> String?

    func ipPickerView(_ pickerView: IPPickerView, widthForComponent component: Int) -> CGFloat?
    func ipPickerView(_ pickerView: IPPickerView, itemHeightForComponent component: Int) -> CGFloat?

    func ipPickerView(_ pickerView: IPPickerView, didSelectItem item: Int, forComponent component: Int, inDirection: ScrollDirection)

    func ipPickerView(_ pickerView: IPPickerView, viewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> UIView?
    func ipPickerView(_ pickerView: IPPickerView, widthOfViewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> CGFloat?

    func ipPickerView(_ pickerView: IPPickerView, componentViewForComponent component: Int) -> UIView?

    // For now this doesn't work if you override the component view
    func ipPickerView(
        _ pickerView: IPPickerView,
        didScrollItemView itemView: UIView,
        forComponent component: Int,
        forItem item: Int,
        toOffsetFromCenter offset: CGFloat
    )
}

extension IPPickerViewDelegate {
    func ipPickerView(_ pickerView: IPPickerView, viewForItem item: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, attributedTitleForItem item: Int, forComponent component: Int) -> NSAttributedString? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, titleForItem item: Int, forComponent component: Int) -> String? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, widthForComponent component: Int) -> CGFloat? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, itemHeightForComponent component: Int) -> CGFloat? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, didSelectItem item: Int, forComponent component: Int, inDirection: ScrollDirection) {
    }

    func ipPickerView(_ pickerView: IPPickerView, viewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> UIView? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, widthOfViewForSpacingBetweenComponent leftComponent: Int, and rightComponent: Int) -> CGFloat? {
        return nil
    }

    func ipPickerView(_ pickerView: IPPickerView, componentViewForComponent component: Int) -> UIView? {
        return nil
    }

    // For now this doesn't work if you override the component view
    func ipPickerView(
        _ pickerView: IPPickerView,
        didScrollItemView itemView: UIView,
        forComponent component: Int,
        forItem item: Int,
        toOffsetFromCenter offset: CGFloat
    ) {
    }
}

public protocol IPPickerViewProtocol: class {
    var delegate: IPPickerViewDelegate? { get set }

    func reloadAllComponents()
    func selectItem(_ item: Int, inComponent component: Int, animated: Bool)
}
