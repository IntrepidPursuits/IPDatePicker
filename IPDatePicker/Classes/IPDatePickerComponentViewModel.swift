//
//  IPDatePickerComponentViewModel.swift
//  IPDatePicker
//
//  Created by Andrew Dolce on 6/14/17.
//  Copyright © 2017 Intrepid Pursuits, LLC. All rights reserved.
//

import Foundation

public struct IPDatePickerComponent {
    public enum Unit: String {
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

        static func all() -> [Unit] {
            return [.hour12, .hour24, .minute, .amPm]
        }
    }

    public let unit: Unit
    public let index: Int
}

class IPDatePickerComponentViewModel {
    var titles = [String]()

    private(set) var index: Int
    var selection: Int = 0

    init(index: Int, dateAsComponents: DateComponents, locale: Locale = Locale.current) {
        self.index = index

        setupTitlesFromLocale(locale)
        setSelectionFromDateComponents(dateAsComponents)
    }

    func unit() -> IPDatePickerComponent.Unit {
        preconditionFailure("Function unimplemented")
    }

    func component() -> IPDatePickerComponent {
        return IPDatePickerComponent(unit: unit(), index: index)
    }

    func calendarComponent() -> Calendar.Component? {
        return unit().calendarComponent
    }

    func formatSymbol() -> String {
        return unit().formatSymbol
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

    func defaultComponentView() -> UIView? {
        return IPTablePickerComponentView(component: index, scrollMode: .infinite)
    }
}

// Factory

extension IPDatePickerComponentViewModel {
    class func viewModel(
        for component: IPDatePickerComponent,
        dateAsComponents: DateComponents,
        locale: Locale = Locale.current
    ) -> IPDatePickerComponentViewModel {
        switch component.unit {
        case .hour12:
            return TwelveHourComponentViewModel(index: component.index, dateAsComponents: dateAsComponents, locale: locale)
        case .hour24:
            return TwentyFourHourComponentViewModel(index: component.index, dateAsComponents: dateAsComponents, locale: locale)
        case .minute:
            return MinutesComponentViewModel(index: component.index, dateAsComponents: dateAsComponents, locale: locale)
        case .amPm:
            return AmPmComponentViewModel(index: component.index, dateAsComponents: dateAsComponents, locale: locale)
        }
    }
}

final class TwelveHourComponentViewModel: IPDatePickerComponentViewModel {
    override func unit() -> IPDatePickerComponent.Unit {
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

final class TwentyFourHourComponentViewModel: IPDatePickerComponentViewModel {
    override func unit() -> IPDatePickerComponent.Unit {
        return .hour24
    }

    override func setupTitlesFromLocale(_ locale: Locale) {
        titles = (0...23).map { String(format: "%02d", $0) }
    }

    override func setSelectionFromDateComponents(_ dateComponents: DateComponents) {
        selection = (dateComponents.hour ?? 0)
    }

    override func selectedDateComponents() -> DateComponents {
        return DateComponents(hour: selection, minute: 0)
    }
}

final class AmPmComponentViewModel: IPDatePickerComponentViewModel {
    override func unit() -> IPDatePickerComponent.Unit {
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

    override func defaultComponentView() -> UIView? {
        return IPTablePickerComponentView(component: index, scrollMode: .finite)
    }
}

final class MinutesComponentViewModel: IPDatePickerComponentViewModel {
    override func unit() -> IPDatePickerComponent.Unit {
        return .minute
    }

    override func setupTitlesFromLocale(_ locale: Locale) {
        titles = (0...59).map { String(format: "%02d", $0) }
    }

    override func setSelectionFromDateComponents(_ dateComponents: DateComponents) {
        selection = (dateComponents.minute ?? 0)
    }

    override func selectedDateComponents() -> DateComponents {
        return DateComponents(hour: 0, minute: selection)
    }
}
