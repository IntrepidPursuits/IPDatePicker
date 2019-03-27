//
//  UIView+Nib.swift
//  ChristmasCheer
//
//  Created by Logan Wright on 10/25/15.
//  Copyright © 2015 lowriDevs. All rights reserved.
//

import UIKit

// MARK: TypeIdentifiable

public protocol TypeIdentifiable {
    static var ip_identifier: String { get }
}

extension TypeIdentifiable {
    public static var ip_identifier: String {
        return "identifier:\(self)"
    }
}

extension UITableViewCell: TypeIdentifiable {}
extension UITableViewHeaderFooterView: TypeIdentifiable {}

extension UICollectionReusableView: TypeIdentifiable {}

// MARK: UICollectionView

public extension UICollectionView {

    // MARK: Register

    public func ip_registerCell<T>(_: T.Type, identifier: String = T.ip_identifier) where T: UICollectionViewCell {
        if let nib = T.ip_nib {
            register(nib, forCellWithReuseIdentifier: identifier)
        } else {
            register(T.self, forCellWithReuseIdentifier: identifier)
        }
    }

    public func ip_registerHeader<T>(_: T.Type, identifier: String = T.ip_identifier) where T: UICollectionReusableView {
        ip_registerSupplementary(T.self, kind: UICollectionView.elementKindSectionHeader, identifier: identifier)
    }

    public func ip_registerFooter<T>(_: T.Type, identifier: String = T.ip_identifier) where T: UICollectionReusableView {
        ip_registerSupplementary(T.self, kind: UICollectionView.elementKindSectionFooter, identifier: identifier)
    }

    public func ip_registerSupplementary<T>(_: T.Type, kind: String, identifier: String = T.ip_identifier) where T: UICollectionReusableView {
        if let nib = T.ip_nib {
            register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        } else {
            register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        }
    }

    // MARK: Dequeue

    // swiftlint:disable force_cast
    public func ip_dequeueCell<T>(_ indexPath: IndexPath, identifier: String = T.ip_identifier) -> T where T: UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }

    public func ip_dequeueHeader<T>(_ indexPath: IndexPath, identifier: String = T.ip_identifier) -> T where T: UICollectionReusableView {
        return ip_dequeueSupplementary(indexPath, kind: UICollectionView.elementKindSectionHeader, identifier: identifier)
    }

    public func ip_dequeueFooter<T>(_ indexPath: IndexPath, identifier: String = T.ip_identifier) -> T where T: UICollectionReusableView {
        return ip_dequeueSupplementary(indexPath, kind: UICollectionView.elementKindSectionFooter, identifier: identifier)
    }

    public func ip_dequeueSupplementary<T>(_ indexPath: IndexPath, kind: String, identifier: String = T.ip_identifier) -> T where T: UICollectionReusableView {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! T
    }
    // swiftlint:enable force_cast
}

// MARK: UITableView

public extension UITableView {

    // MARK: Register

    public func ip_registerCell<T>(_: T.Type, identifier: String = T.ip_identifier) where T: UITableViewCell {
        if let nib = T.ip_nib {
            register(nib, forCellReuseIdentifier: identifier)
        } else {
            register(T.self, forCellReuseIdentifier: identifier)
        }
    }

    public func ip_registerHeader<T>(_: T.Type, identifier: String = T.ip_identifier) where T: UITableViewHeaderFooterView {
        if let nib = T.ip_nib {
            register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        } else {
            register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }

    // MARK: Dequeue

    // swiftlint:disable force_cast
    public func ip_dequeueCell<T>(_ indexPath: IndexPath, identifier: String = T.ip_identifier) -> T where T: UITableViewCell {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }

    public func ip_dequeueHeader<T>(_ section: Int, identifier: String = T.ip_identifier) -> T where T: UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
    }

    public func ip_cellForRowAtIndexPath<T>(_ indexPath: IndexPath) -> T where T: UITableViewCell {
        return cellForRow(at: indexPath) as! T
    }
    // swiftlint:enable force_cast
}
