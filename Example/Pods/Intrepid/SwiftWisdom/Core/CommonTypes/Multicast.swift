//
//  Multicast.swift
//  SwiftWisdom
//
//  Created by Logan Wright on 9/4/15.
//  Copyright © 2015 Intrepid. All rights reserved.
//

import Foundation

/// Wraps a weak reference to an object.
/// Useful for storing arrays of references without causing retain cycles.
public struct Weak<T> where T: AnyObject {

    public weak var weak: T?

    public init(_ weak: T) {
        self.weak = weak
    }
}

/**
    Conforming to this protocol lets a class implement a multi-delegate system.

    Only subclasses of NSObject can conform to this protocol. In addition, you can only typealias `MulticastDelegate` to a
    class or an `@objc` protocol.
 */
public protocol Multicast: class {

    associatedtype MulticastDelegate: AnyObject

    var delegateReferences: [Weak<MulticastDelegate>] { get set }
}

public extension Multicast {

    /// Delegates of this class.
    var delegates: [MulticastDelegate] {
        let existing = delegateReferences.compactMap { $0.weak }
        if existing.count != delegateReferences.count {
            delegateReferences = existing.map { Weak($0) }
        }
        return existing
    }

    /**
        Add a delegate.

        - parameter delegate: MulticastDelegate to be added.
     */
    func add(delegate: MulticastDelegate) {
        remove(delegate: delegate)
        delegateReferences.append(Weak(delegate))
    }

    /**
        Remove delegates matching a predicate.

        - parameter shouldRemove: A predicate that is called once for each delegate of this class. It should return true
          if a delegate should be removed.
     */
    func removeDelegates(_ shouldRemove: (MulticastDelegate) -> Bool) {
        delegateReferences = delegates
            .filter { !shouldRemove($0) }
            .map { Weak($0) }
    }

    /**
        Remove a delegate.

        - parameter delegate: MulticastDelegate to be removed.
     */
    func remove(delegate: MulticastDelegate) {
        removeDelegates { $0 === delegate }
    }
}
