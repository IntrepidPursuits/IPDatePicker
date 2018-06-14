//
//  LocaleAgnosticDateFormat.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/13/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import Foundation

enum LocaleAgnosticDateFormat: String {
    // Using "jj" to indicate hours means we are not expressing a requirement on either
    // a 12-hour clock format ("h") or a 24-hour clock format ("HH"). It is left up to
    // the DateFormatter to interpret which is preferred based on locale.
    //
    // See unicode docs for more information:
    //   https://www.unicode.org/reports/tr35/tr35-dates.html#dfst-hour
    case time = "jj:mm"

    var formatString: String {
        return rawValue
    }
}
