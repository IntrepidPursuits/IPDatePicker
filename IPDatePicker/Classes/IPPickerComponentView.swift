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
    func viewForItem(_ item: Int, component: Int, reusing view: UIView?) -> UIView?
    func titleForItem(_ item: Int, component: Int) -> String?
    func attributedTitleForItem(_ item: Int, component: Int) -> NSAttributedString?

    func itemHeightForComponent(_ component: Int) -> CGFloat?

    func didSelectItem(_ item: Int, component: Int, direction: ScrollDirection)
    func didScrollItemView(_ itemView: UIView, item: Int, component: Int, toOffsetFromCenter offset: CGFloat)
}

public protocol IPPickerComponentView: class {
    var component: Int { get }
    var delegate: IPPickerComponentViewDelegate? { get set }

    var selectedItem: Int { get }
    func setSelectedItem(_ item: Int, animated: Bool)
}

final class IPTablePickerComponentView: UIView, IPPickerComponentView, InfiniteTableViewDataSource, InfiniteTableViewDelegate {
    private let scrollMode: InfiniteTableView.ScrollMode
    private let tableView: InfiniteTableView

    private(set) var component: Int
    private(set) var selectedItem: Int = 0

    weak var delegate: IPPickerComponentViewDelegate? {
        didSet {
            tableView.rowHeight = delegate?.itemHeightForComponent(component) ?? 44.0
            tableView.reloadData()
        }
    }

    init(component: Int, scrollMode: InfiniteTableView.ScrollMode) {
        self.component = component
        self.scrollMode = scrollMode
        self.tableView = InfiniteTableView(scrollMode: scrollMode)

        super.init(frame: .zero)

        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tableView.register(IPTablePickerCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = delegate?.itemHeightForComponent(component) ?? 44.0
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

    func setSelectedItem(_ item: Int, animated: Bool) {
        selectedItem = item
        centerOnItem(item, animated: animated)
    }

    // MARK: - InfiniteTableViewDataSource

    private let cellIdentifier = "cellIdentifier"

    func numberOfItems(in infiniteTableView: InfiniteTableView) -> Int {
        return delegate?.numberOfItemsForComponent(component) ?? 0
    }

    func infiniteTableView(_ infiniteTableView: InfiniteTableView, cellForItem item: Int, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, forRow: row)
        let previousItemView = (cell as? IPTablePickerCell)?.itemView

        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear

        let itemView: UIView

        if let providedItemView = delegate?.viewForItem(item, component: component, reusing: previousItemView) {
            itemView = providedItemView
        } else {
            let label = UILabel()
            label.textAlignment = .center

            if let attributedTitle = delegate?.attributedTitleForItem(item, component: component) {
                label.attributedText = attributedTitle
            } else if let title = delegate?.titleForItem(item, component: component) {
                label.text = title
            }

            itemView = label
        }

        (cell as? IPTablePickerCell)?.itemView = itemView
        
        return cell
    }

    // MARK: - InfiniteTableViewDelegate

    func infiniteTableView(_ infiniteTableView: InfiniteTableView, willDisplay cell: UITableViewCell, forItem item: Int, at row: Int) {
        guard
            let delegate = delegate,
            let itemView = (cell as? IPTablePickerCell)?.itemView
        else {
            return
        }

        let centerOffset = tableView.contentOffset.y + tableView.bounds.height / 2.0
        let itemCenter = tableView.rectForRow(row).ip_center.y
        let offset = itemCenter - centerOffset

        delegate.didScrollItemView(itemView, item: item, component: component, toOffsetFromCenter: offset)
    }

    func infiniteTableView(_ infiniteTableView: InfiniteTableView, didSelectItem item: Int, at row: Int) {
        selectedItem = item
        tableView.scrollToRow(at: row, at: .middle, animated: true)

        let centerOffset = tableView.contentOffset.y + tableView.bounds.height / 2.0
        let itemCenter = tableView.rectForRow(row).ip_center.y
        let direction: ScrollDirection = itemCenter < centerOffset ? .up : .down

        delegate?.didSelectItem(item, component: component, direction: direction)
    }

    // MARK: - Table Inset

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
            if scrollMode == .finite {
                updateTableInsets()
            }
            centerOnItem(selectedItem, animated: false)
            triggerScollHandlers()
            cachedBounds = tableView.bounds
        }
    }

    private func triggerScollHandlers() {
        guard let delegate = delegate else {
            return
        }

        let centerOffset = tableView.contentOffset.y + tableView.bounds.height / 2.0

        tableView.visibleRows().forEach { row in
            guard
                let cell = tableView.cellForRow(row) as? IPTablePickerCell,
                let itemView = cell.itemView
                else {
                    return
            }

            let itemCenter = tableView.rectForRow(row).ip_center.y
            let offset = itemCenter - centerOffset
            let item = tableView.itemAtRow(row)

            delegate.didScrollItemView(itemView, item: item, component: component, toOffsetFromCenter: offset)
        }
    }

    // MARK: - UIScrollViewDelegate

    func infiniteTableViewDidScroll(_ infiniteTableView: InfiniteTableView) {
        triggerScollHandlers()
    }

    func infiniteTableViewWillEndDragging(_ infiniteTableView: InfiniteTableView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, direction: ScrollDirection) {
        let lastRow = tableView.numberOfRows() - 1

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

        let item = infiniteTableView.itemAtRow(Int(row))
        selectedItem = item
        delegate?.didSelectItem(selectedItem, component: component, direction: direction)
    }

    private func centerOnItem(_ item: Int, animated: Bool) {
        tableView.centerOnItem(item, animated: animated)
    }
}

private class IPTablePickerCell: UITableViewCell {
    override init(style: CellStyle, reuseIdentifier: String?) {
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
