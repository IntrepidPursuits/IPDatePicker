//
//  DatePickerComponentViewModel.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import Foundation

public enum DatePickerComponent: String {
    case hour12 = "h"
    case hour24 = "H"
    case minute = "m"
    case amPm = "a"

    var formatSymbol: String {
        return rawValue
    }

    var calendarComponent: Calendar.Component? {
        switch self {
        case .hour12, .hour24:
            return .hour
        case .minute:
            return .minute
        default:
            return nil
        }
    }
}

class DatePickerComponentViewModel {
    var titles = [String]()

    var selection: Int = 0

    init(dateComponents: DateComponents, locale: Locale = Locale.current) {
        setupTitlesFromLocale(locale)
        setSelectionFromDateComponents(dateComponents)
    }

    func component() -> DatePickerComponent {
        preconditionFailure("Function unimplemented")
    }

    func calendarComponent() -> Calendar.Component? {
        return component().calendarComponent
    }

    func formatSymbol() -> String {
        return component().rawValue
    }

    func setupTitlesFromLocale(_ locale: Locale) {
        preconditionFailure("Function unimplemented")
    }

    func setSelectionFromDateComponents(_ dateComponents: DateComponents) {
        preconditionFailure("Function unimplemented")
    }

    func selectedDateComponents() -> DateComponents {
        preconditionFailure("Function unimplemented")
    }
}

final class TwelveHourComponentViewModel: DatePickerComponentViewModel {
    override func component() -> DatePickerComponent {
        return .hour12
    }

    override func setupTitlesFromLocale(_ locale: Locale) {
        titles = (1...12).map { "\($0)" }
    }

    override func setSelectionFromDateComponents(_ dateComponents: DateComponents) {
        selection = ((dateComponents.hour ?? 0) + 11) % 12
    }

    override func selectedDateComponents() -> DateComponents {
        let hours = (selection + 1) % 12

        return DateComponents(hour: hours, minute: 0)
    }
}

final class TwentyFourHourComponentViewModel: DatePickerComponentViewModel {
    override func component() -> DatePickerComponent {
        return .hour24
    }

    override func setupTitlesFromLocale(_ locale: Locale) {
        titles = (0...23).map { "\($0)" }
    }

    override func setSelectionFromDateComponents(_ dateComponents: DateComponents) {
        selection = (dateComponents.hour ?? 0)
    }

    override func selectedDateComponents() -> DateComponents {
        return DateComponents(hour: selection, minute: 0)
    }
}

final class AmPmComponentViewModel: DatePickerComponentViewModel {
    override func component() -> DatePickerComponent {
        return .amPm
    }

    override func setupTitlesFromLocale(_ locale: Locale) {
        let formatter = DateFormatter()
        formatter.locale = locale
        titles = [formatter.amSymbol, formatter.pmSymbol]
    }

    override func setSelectionFromDateComponents(_ dateComponents: DateComponents) {
        selection = (dateComponents.hour ?? 0) / 12
    }

    override func selectedDateComponents() -> DateComponents {
        return DateComponents(hour: selection * 12, minute: 0)
    }
}

final class MinutesComponentViewModel: DatePickerComponentViewModel {
    override func component() -> DatePickerComponent {
        return .minute
    }

    override func setupTitlesFromLocale(_ locale: Locale) {
        titles = (0...59).map { "\($0)" }
    }

    override func setSelectionFromDateComponents(_ dateComponents: DateComponents) {
        selection = (dateComponents.minute ?? 0)
    }

    override func selectedDateComponents() -> DateComponents {
        return DateComponents(hour: 0, minute: selection)
    }
}
