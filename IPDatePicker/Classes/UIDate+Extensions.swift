//
//  UIDate+Extensions.swift
//  Pods
//
//  Created by Andrew Dolce on 6/19/17.
//
//

import Foundation

extension Date {
    var timeComponents: DateComponents {
        get {
            return Calendar.current.dateComponents([.hour, .minute], from: self)
        }
        set {
            guard let newDate = Calendar.current.date(from: newValue) else {
                return
            }
            self = newDate
        }
    }
}
