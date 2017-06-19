//
//  IPDatePickerFormat.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import Foundation

public enum ClockHourFormat {
    case twelve
    case twentyFour

    fileprivate func formatString() -> String {
        switch self {
        case .twelve:
            return "hh:mm"
        case .twentyFour:
            return "HH:mm"
        }
    }
}

public struct IPDatePickerFormat {
    let hourFormat: ClockHourFormat
    let locale: Locale

    init(locale: Locale = Locale.current, hourFormat: ClockHourFormat) {
        self.locale = locale
        self.hourFormat = hourFormat
    }

    func localizedFormatString() -> String? {
        return DateFormatter.dateFormat(fromTemplate: hourFormat.formatString(), options: 0, locale: locale)
    }
}
