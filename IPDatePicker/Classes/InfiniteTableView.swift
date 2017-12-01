//
//  InfiniteTableView.swift
//  Pods
//
//  Created by Andrew Dolce on 9/2/17.
//
//

import UIKit
import PureLayout

protocol InfiniteTableViewDataSource: class {
    func numberOfItems(in infiniteTableView: InfiniteTableView) -> Int
    func infiniteTableView(_ infiniteTableView: InfiniteTableView, cellForItem item: Int, row: Int) -> UITableViewCell
}

protocol InfiniteTableViewDelegate: class {
    func infiniteTableView(_ infiniteTableView: InfiniteTableView, didSelectItem item: Int, at row: Int)
    func infiniteTableView(_ infiniteTableView: InfiniteTableView, willDisplay cell: UITableViewCell, forItem item: Int, at row: Int)

    func infiniteTableViewWillEndDragging(_ infiniteTableView: InfiniteTableView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func infiniteTableViewDidScroll(_ infiniteTableView: InfiniteTableView)
}

// The infinite scroll effect provided by InfiniteTableView works by:
// - repeating each unique item multiple times so that content repeats as the user scrolls, and
// - opportunistically resetting the content offset to seemlessly jump the user back towards the center of the repeated
//   content, so that hopefully we never reach the end.
//
// With that in mind, we define the following terminology:
//
// - An "item" is a semantically unique item in the table, which may repeat.
// - A "row" is a literal row of the underlying UITableView. Each item may correspond to multiple rows.
// - A "block" refers to a single continuous section of content containing all items 0-N. In other words, every time
//   the repeating content "starts over", that's a new block.
// - The "primary block" is the block that we consider the center of the entire table. When we reset the content offset
//   during/after scrolling, we aim to reset back to the primary block.
// - The "primary offset" and "primary row" of an item refer to the content offset/row within the primary block at
//   which that item is present.
//
// So for example, a table set up with 3 items (A, B, C) and 3 blocks would have 9 rows, such that content from top
// to bottom looks like:
//
// A (item 0, row 0, block 0)
// B (item 1, row 1, block 0)
// C (item 2, row 2, block 0)
// A (item 0, row 3, block 1)
// B (item 1, row 4, block 1)
// C (item 2, row 5, block 1)
// A (item 0, row 6, block 2)
// B (item 1, row 7, block 2)
// C (item 2, row 8, block 2)
//
// In this example, the primary block would be block 1. The primary row for item 0 is row 3. If each row is 40 points
// high, then the primary offset of item 0 would be 120, since that's the content offset at which row 3 starts.

final class InfiniteTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    enum ScrollMode {
        case infinite
        case finite
    }

    private let tableView = UITableView()
    private let scrollMode: ScrollMode

    private var blocks: Int {
        return scrollMode == .infinite ? 1001 : 1
    }

    weak var dataSource: InfiniteTableViewDataSource?
    weak var delegate: InfiniteTableViewDelegate?

    var rowHeight: CGFloat {
        get {
            return tableView.rowHeight
        }
        set {
            tableView.rowHeight = newValue
        }
    }

    init(scrollMode: ScrollMode) {
        self.scrollMode = scrollMode

        super.init(frame: .zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 0.0

        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = dataSource?.numberOfItems(in: self) ?? 0
        let rows = items * blocks
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemAtIndexPath(indexPath)
        return dataSource?.infiniteTableView(self, cellForItem: item, row: indexPath.row) ?? UITableViewCell()
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = itemAtIndexPath(indexPath)
        delegate?.infiniteTableView(self, willDisplay: cell, forItem: item, at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemAtIndexPath(indexPath)
        delegate?.infiniteTableView(self, didSelectItem: item, at: indexPath.row)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.infiniteTableViewDidScroll(self)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.infiniteTableViewWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollMode == .infinite {
            resetCurrentOffsetToPrimary()
        }
    }

    // MARK: - Helpers

    func numberOfItems() -> Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }

    func numberOfRows() -> Int {
        return numberOfItems() * blocks
    }

    private func blockHeight() -> CGFloat {
        return CGFloat(numberOfItems()) * rowHeight
    }

    private func totalHeight() -> CGFloat {
        return CGFloat(numberOfRows()) * rowHeight
    }

    private func primaryBlockIndex() -> Int {
        return blocks / 2
    }

    func itemAtRow(_ row: Int) -> Int {
        return row % numberOfItems()
    }

    private func itemAtIndexPath(_ indexPath: IndexPath) -> Int {
        return itemAtRow(indexPath.row)
    }

    // MARK: - Centering

    func centerOnItem(_ item: Int, animated: Bool) {
        // TODO: Refactor this to better handle the finite case (or remove that completely)
        // There is also an issue where this condition is met more often than expected.
        // It is not having any obvious adverse effects so we will leave it as-is
        if scrollMode == .finite {
            let offsetY = (CGFloat(item) + 0.5) * rowHeight - bounds.height * 0.5
            setContentOffset(CGPoint(x: 0.0, y: offsetY), animated: animated)

            return
        }

        resetCurrentOffsetToPrimary()
        if animated {
            layoutIfNeeded()
        }

        var alignmentOffset = contentOffset
        alignmentOffset.y += (0.5 * bounds.height) - (0.5 * rowHeight)

        var offset = closestOffsetForItem(item, to: alignmentOffset)
        offset.y += (0.5 * rowHeight) - (0.5 * bounds.height)

        setContentOffset(offset, animated: animated)
    }

    private func resetCurrentOffsetToPrimary() {
        let primaryOffset = primaryOffsetForOffset(contentOffset)
        if primaryOffset != contentOffset {
            contentOffset = primaryOffset
        }
    }

    private func primaryOffsetForOffset(_ offset: CGPoint) -> CGPoint {
        let block = contentOffset.y / blockHeight()
        let blockOffset = block - floor(block)
        let primaryY = (blockOffset + CGFloat(primaryBlockIndex())) * blockHeight()
        return CGPoint(x: offset.x, y: primaryY)
    }

    private func closestOffsetForItem(_ item: Int, to targetOffset: CGPoint) -> CGPoint {
        guard numberOfItems() > 0 else {
            return .zero
        }

        let blockOffsetForItem = CGFloat(item) / CGFloat(numberOfItems())

        let targetBlock = Int(floor(targetOffset.y / blockHeight()))

        let possibleBlocks = [targetBlock - 1, targetBlock, targetBlock + 1].filter {
            $0 >= 0 && $0 < blocks
        }
        let possibleOffsets: [CGFloat] = possibleBlocks.map {
            (CGFloat($0) + blockOffsetForItem) * blockHeight()
        }.sorted {
            let distanceLeft: CGFloat = abs($0 - targetOffset.y)
            let distanceRight: CGFloat = abs($1 - targetOffset.y)
            return distanceLeft < distanceRight
        }

        let closestOffset = possibleOffsets.first

        return CGPoint(x: targetOffset.x, y: closestOffset ?? .zero)
    }

    // MARK: - UITableView pass-throughs

    var contentOffset: CGPoint {
        get {
            return tableView.contentOffset
        }
        set {
            tableView.contentOffset = newValue
        }
    }

    func setContentOffset(_ offset: CGPoint, animated: Bool) {
        tableView.setContentOffset(offset, animated: animated)
    }

    var contentInset: UIEdgeInsets {
        get {
            return tableView.contentInset
        }
        set {
            tableView.contentInset = newValue
        }
    }

    func reloadData() {
        tableView.reloadData()
    }

    override var backgroundColor: UIColor? {
        didSet {
            tableView.backgroundColor = backgroundColor
        }
    }

    var separatorStyle: UITableViewCellSeparatorStyle {
        get {
            return tableView.separatorStyle
        }
        set {
            tableView.separatorStyle = newValue
        }
    }

    var separatorInset: UIEdgeInsets {
        get {
            return tableView.separatorInset
        }
        set {
            tableView.separatorInset = newValue
        }
    }

    var showsVerticalScrollIndicator: Bool {
        get {
            return tableView.showsVerticalScrollIndicator
        }
        set {
            tableView.showsVerticalScrollIndicator = newValue
        }
    }

    var tableHeaderView: UIView? {
        get {
            return tableView.tableHeaderView
        }
        set {
            tableView.tableHeaderView = newValue
        }
    }

    var tableFooterView: UIView? {
        get {
            return tableView.tableFooterView
        }
        set {
            tableView.tableFooterView = newValue
        }
    }

    func rectForRow(_ row: Int) -> CGRect {
        return tableView.rectForRow(at: IndexPath(row: row, section: 0))
    }

    func visibleRows() -> [Int] {
        return tableView.indexPathsForVisibleRows?.map { $0.row } ?? []
    }

    func cellForRow(_ row: Int) -> UITableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: row, section: 0))
    }

    func scrollToRow(at row: Int, at position: UITableViewScrollPosition, animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: position, animated: animated)
    }

    // MARK: - Cell Creation

    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }

    func dequeueReusableCell(withIdentifier identifier: String, forRow row: Int) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier:identifier, for: IndexPath(row: row, section: 0))
    }
}
