//
//  IPPickerComponentView.swift
//  IPPickerView
//
//  Created by Andrew Dolce on 6/22/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import UIKit
import PureLayout

public protocol IPPickerComponentViewDelegate: class {
    func numberOfItemsForComponent(_ component: Int) -> Int
    func viewForRow(_ row: Int, component: Int, reusing view: UIView?) -> UIView?
    func titleForRow(_ row: Int, component: Int) -> String?
    func attributedTitleForRow(_ row: Int, component: Int) -> NSAttributedString?

    func rowHeightForComponent(_ component: Int) -> CGFloat?

    func didSelectRow(_ row: Int, component: Int)
    func didScrollItemView(_ itemView: UIView, row: Int, component: Int, toOffsetFromCenter offset: CGFloat)
}

public protocol IPPickerComponentView: class {
    init(component: Int)

    var component: Int { get }
    var delegate: IPPickerComponentViewDelegate? { get set }

    var selectedRow: Int { get }
    func setSelectedRow(_ row: Int, animated: Bool)
}

final class IPTablePickerComponentView: UIView, IPPickerComponentView, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()

    private(set) var component: Int
    private(set) var selectedRow: Int = 0

    weak var delegate: IPPickerComponentViewDelegate? {
        didSet {
            tableView.rowHeight = delegate?.rowHeightForComponent(component) ?? 44.0
            tableView.reloadData()
        }
    }

    init(component: Int) {
        self.component = component

        super.init(frame: .zero)

        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tableView.register(IPTablePickerCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = delegate?.rowHeightForComponent(component) ?? 44.0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear

        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()

        tableView.reloadData()
    }

    // MARK: - Selection

    func setSelectedRow(_ row: Int, animated: Bool) {
        selectedRow = row
        centerOnRow(row, animated: animated)
    }

    // MARK: - UITableViewDataSource

    private let cellIdentifier = "cellIdentifier"

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.numberOfItemsForComponent(component) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let previousItemView = (cell as? IPTablePickerCell)?.itemView

        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear

        let itemView: UIView

        if let providedItemView = delegate?.viewForRow(indexPath.row, component: component, reusing: previousItemView) {
            itemView = providedItemView
        } else {
            let label = UILabel()
            label.textAlignment = .center

            if let attributedTitle = delegate?.attributedTitleForRow(indexPath.row, component: component) {
                label.attributedText = attributedTitle
            } else if let title = delegate?.titleForRow(indexPath.row, component: component) {
                label.text = title
            }

            itemView = label
        }

        (cell as? IPTablePickerCell)?.itemView = itemView
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            let delegate = delegate,
            let itemView = (cell as? IPTablePickerCell)?.itemView
        else {
            return
        }

        let centerOffset = tableView.contentOffset.y + tableView.bounds.height / 2.0
        let itemCenter = tableView.rectForRow(at: indexPath).ip_center.y
        let offset = itemCenter - centerOffset

        delegate.didScrollItemView(itemView, row: indexPath.row, component: component, toOffsetFromCenter: offset)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setSelectedRow(indexPath.row, animated: true)
        delegate?.didSelectRow(indexPath.row, component: component)
    }

    // MARK: - Table Inset

    override var bounds: CGRect {
        didSet {
            if bounds != oldValue {
                updateTableInsets()
                centerOnRow(selectedRow, animated: false)
            }
        }
    }

    private func updateTableInsets() {
        let halfHeight = bounds.height * 0.5
        let inset = halfHeight - tableView.rowHeight * 0.5
        tableView.contentInset = UIEdgeInsets(top: inset, left: 0.0, bottom: inset, right: 0.0)
    }

    // MARK: - Scroll Handler

    private var cachedBounds: CGRect?

    override func layoutSubviews() {
        super.layoutSubviews()

        let boundsChanged: Bool
        if let cached = cachedBounds {
            boundsChanged = (cached != tableView.bounds)
        } else {
            boundsChanged = true
        }

        if boundsChanged {
            triggerScollHandlers()
            cachedBounds = tableView.bounds
        }
    }

    private func triggerScollHandlers() {
        guard let delegate = delegate else {
            return
        }

        let centerOffset = tableView.contentOffset.y + tableView.bounds.height / 2.0

        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            guard
                let cell = tableView.cellForRow(at: indexPath) as? IPTablePickerCell,
                let itemView = cell.itemView
                else {
                    return
            }

            let itemCenter = tableView.rectForRow(at: indexPath).ip_center.y
            let offset = itemCenter - centerOffset

            delegate.didScrollItemView(itemView, row: indexPath.row, component: component, toOffsetFromCenter: offset)
        }
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        triggerScollHandlers()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let tableView = scrollView as? UITableView else {
            return
        }

        let lastRow = tableView.numberOfRows(inSection: 0) - 1

        guard lastRow >= 0 else {
            return
        }

        let offsetY = targetContentOffset.pointee.y
        let tableHalfHeight = tableView.bounds.height * 0.5
        let centerOffsetY = offsetY + tableHalfHeight

        let rowHeight = tableView.rowHeight
        let row = floor(min(CGFloat(lastRow), max(0.0, centerOffsetY / rowHeight)))

        let adjustedOffsetY = (row + 0.5) * rowHeight - tableHalfHeight
        targetContentOffset.pointee.y = adjustedOffsetY

        selectedRow = Int(row)
        delegate?.didSelectRow(selectedRow, component: component)
    }

    private func centerOnRow(_ row: Int, animated: Bool) {
        let offset = contentOffsetForCenteringRow(row)
        tableView.setContentOffset(offset, animated: animated)
    }

    private func contentOffsetForCenteringRow(_ row: Int) -> CGPoint {
        // Note: We use our bounds here instead of the table's individual bounds, because under some conditions the table
        // might not have yet layed out it's bounds.
        let tableHalfHeight = bounds.height * 0.5
        let rowHeight = tableView.rowHeight
        let rowCenterY = (CGFloat(row) + 0.5) * rowHeight

        return CGPoint(x: 0.0, y: rowCenterY - tableHalfHeight)
    }
}

private class IPTablePickerCell: UITableViewCell {
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
