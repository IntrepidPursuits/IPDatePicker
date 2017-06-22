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

    open func selectRow(_ row: Int, inComponent component: Int, animated: Bool) {
        selections[component] = row

        guard let view = componentViews[ip_safe: component] else {
            return
        }

        view.setSelectedRow(row, animated: animated)
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

        let line = UIView()
        line.backgroundColor = UIColor.red
        addSubview(line)
        line.autoSetDimension(.height, toSize: 1.0)
        line.autoPinEdge(toSuperviewEdge: .leading)
        line.autoPinEdge(toSuperviewEdge: .trailing)
        line.autoAlignAxis(toSuperviewAxis: .horizontal)
    }

    private func setupComponentViews() {
        guard let delegate = delegate else {
            return
        }

        let numberOfComponents = delegate.numberOfComponentsInIPPickerView(self)

        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
        }

        componentViews = (0..<numberOfComponents).flatMap { component in

            let componentWidth = delegate.ipPickerView(self, widthForComponent: component) ?? 80.0
            let view = viewForComponent(component)

            guard let componentView = view as? IPPickerComponentView else {
                // TODO: Log this
                return nil
            }

            stack.addArrangedSubview(view)
            view.autoSetDimension(.width, toSize: componentWidth)

            if let selectedRow = selections[component] {
                componentView.setSelectedRow(selectedRow, animated: false)
            }

            return componentView
        }

        invalidateIntrinsicContentSize()
    }

    open func viewForComponent(_ component: Int) -> UIView {
        return IPTablePickerComponentView(component: component, delegate: self)
    }

    open override var intrinsicContentSize: CGSize {
        var size = stack.intrinsicContentSize
        size.height = 240.0
        return size
    }

    // MARK: - IPDatePickerComponentViewDelegate

    func numberOfItemsForComponent(_ component: Int) -> Int {
        return delegate?.ipPickerView(self, numberOfRowsInComponent: component) ?? 0
    }

    func viewForRow(_ row: Int, component: Int, reusing view: UIView?) -> UIView? {
        return delegate?.ipPickerView(self, viewForRow: row, forComponent: component, reusing: view)
    }

    func titleForRow(_ row: Int, component: Int) -> String? {
        return delegate?.ipPickerView(self, titleForRow: row, forComponent: component)
    }

    func attributedTitleForRow(_ row: Int, component: Int) -> NSAttributedString? {
        return delegate?.ipPickerView(self, attributedTitleForRow: row, forComponent: component)
    }

    func rowHeightForComponent(_ component: Int) -> CGFloat? {
        return delegate?.ipPickerView(self, rowHeightForComponent: component)
    }

    func didSelectRow(_ row: Int, component: Int) {
        delegate?.ipPickerView(self, didSelectRow: row, forComponent: component)
    }
}

private class DatePickerViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var itemView: UIView? = nil {
        willSet {
            if itemView != newValue {
                itemView?.removeFromSuperview()
            }
        }
        didSet {
            setupItemView()
        }
    }

    private func setupItemView() {
        guard let itemView = itemView else {
            return
        }

        contentView.addSubview(itemView)
        itemView.autoPinEdgesToSuperviewEdges()
    }
}
