//
//  DatePickerView.swift
//  IPPickerView
//
//  Created by Andrew Dolce on 6/20/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit
import PureLayout

open class IPPickerView: UIView, IPPickerViewProtocol, IPPickerComponentViewDelegate {
    private var componentViews = [IPPickerComponentView]()
    private var stack = UIStackView()

    private var needsSetup = true
    private var selections = [Int: Int]()

    // MARK: - IPPickerViewProtocol

    public weak var delegate: IPPickerViewDelegate? {
        didSet {
            setupComponentViews()
        }
    }

    open func selectItem(_ item: Int, inComponent component: Int, animated: Bool) {
        selections[component] = item

        guard let view = componentViews[ip_safe: component] else {
            return
        }

        view.setSelectedItem(item, animated: animated)
    }

    open func reloadAllComponents() {
        setupComponentViews()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupStack()
        setupComponentViews()
    }

    private func setupStack() {
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        addSubview(stack)

        stack.autoPinEdgesToSuperviewEdges()
    }

    private func setupComponentViews() {
        guard let delegate = delegate else {
            return
        }

        let numberOfComponents = delegate.numberOfComponentsInIPPickerView(self)

        stack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        componentViews = (0..<numberOfComponents).flatMap { component in

            let componentWidth = delegate.ipPickerView(self, widthForComponent: component) ?? 80.0
            let view = delegate.ipPickerView(self, componentViewForComponent: component) ?? viewForComponent(component)

            guard let componentView = view as? IPPickerComponentView else {
                // TODO: Log this
                return nil
            }

            componentView.delegate = self

            stack.addArrangedSubview(view)
            view.autoSetDimension(.width, toSize: componentWidth)

            if let selectedItem = selections[component] {
                componentView.setSelectedItem(selectedItem, animated: false)
            }

            if component < numberOfComponents - 1 {
                if let spacerView = delegate.ipPickerView(self, viewForSpacingBetweenComponent: component, and: component + 1) {
                    let spacerWidth = delegate.ipPickerView(self, widthOfViewForSpacingBetweenComponent: component, and: component + 1) ?? 10.0
                    spacerView.autoSetDimension(.width, toSize: spacerWidth)
                    stack.addArrangedSubview(spacerView)
                }
            }

            return componentView
        }

        invalidateIntrinsicContentSize()
    }

    open func viewForComponent(_ component: Int) -> UIView {
        return IPTablePickerComponentView(component: component)
    }

    open override var intrinsicContentSize: CGSize {
        var size = stack.intrinsicContentSize
        size.height = 240.0
        return size
    }

    // MARK: - IPDatePickerComponentViewDelegate

    public func numberOfItemsForComponent(_ component: Int) -> Int {
        return delegate?.ipPickerView(self, numberOfItemsInComponent: component) ?? 0
    }

    public func viewForItem(_ item: Int, component: Int, reusing view: UIView?) -> UIView? {
        return delegate?.ipPickerView(self, viewForItem: item, forComponent: component, reusing: view)
    }

    public func titleForItem(_ item: Int, component: Int) -> String? {
        return delegate?.ipPickerView(self, titleForItem: item, forComponent: component)
    }

    public func attributedTitleForItem(_ item: Int, component: Int) -> NSAttributedString? {
        return delegate?.ipPickerView(self, attributedTitleForItem: item, forComponent: component)
    }

    public func itemHeightForComponent(_ component: Int) -> CGFloat? {
        return delegate?.ipPickerView(self, itemHeightForComponent: component)
    }

    public func didSelectItem(_ item: Int, component: Int) {
        delegate?.ipPickerView(self, didSelectItem: item, forComponent: component)
    }

    public func didScrollItemView(_ itemView: UIView, item: Int, component: Int, toOffsetFromCenter offset: CGFloat) {
        delegate?.ipPickerView(self, didScrollItemView: itemView, forComponent: component, forItem: item, toOffsetFromCenter: offset)
    }
}
