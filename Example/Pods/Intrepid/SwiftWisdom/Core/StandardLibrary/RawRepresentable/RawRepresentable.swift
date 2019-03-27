//
//  RawRepresentable.swift
//  SwiftWisdom
//
//  Created by Logan Wright on 3/31/16.
//  Copyright © 2016 Intrepid. All rights reserved.
//

import Foundation

extension RawRepresentable where RawValue: BinaryInteger {
    @available(*, deprecated, message: "Conform to CaseIterable and use allCases instead.")
    public static var ip_allCases: [Self] {
        var caseIndex: RawValue = 0
        let generator: () -> Self? = {
            let next = Self(rawValue: caseIndex)
            caseIndex = caseIndex.advanced(by: 1)
            return next
        }

        let sequence = AnyIterator(generator)
        return [Self](sequence)
    }
}
