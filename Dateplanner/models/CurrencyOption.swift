import Foundation

enum CurrencyOption: String, CaseIterable, Identifiable {
    case jpy
    case usd
    case eur
    case gbp
    case cny
    case krw
    case cad
    case aud
    case chf
    case sgd

    var id: String { rawValue }

    static let plannerCases: [CurrencyOption] = [
        .jpy,
        .usd,
        .eur,
        .krw,
        .cny
    ]

    var code: String { rawValue.uppercased() }

    var symbol: String {
        switch self {
        case .jpy: return "¥"
        case .usd, .cad, .aud, .sgd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .cny: return "¥"
        case .krw: return "₩"
        case .chf: return "CHF"
        }
    }

    var budgetRange: ClosedRange<Double> {
        switch self {
        case .jpy:
            return 2000...20000
        case .usd, .eur, .gbp, .chf:
            return 20...240
        case .cny:
            return 100...1400
        case .krw:
            return 30000...300000
        case .cad, .aud, .sgd:
            return 30...320
        }
    }

    var budgetStep: Double {
        switch self {
        case .jpy, .krw:
            return 100
        case .cny:
            return 10
        case .usd, .eur, .gbp, .cad, .aud, .chf, .sgd:
            return 1
        }
    }

    var defaultBudget: Double {
        switch self {
        case .jpy:
            return 5000
        case .usd, .eur, .gbp, .chf:
            return 50
        case .cny:
            return 300
        case .krw:
            return 70000
        case .cad, .aud, .sgd:
            return 70
        }
    }

    func displayName(localeIdentifier: String) -> String {
        let locale = Locale(identifier: localeIdentifier)
        return locale.localizedString(forCurrencyCode: code) ?? code
    }

    static func resolvedFromDevice() -> CurrencyOption {
        let deviceCurrencyCode = Locale.current.currency?.identifier.lowercased()
            ?? Locale.autoupdatingCurrent.currency?.identifier.lowercased()

        if let deviceCurrencyCode,
           let currency = CurrencyOption(rawValue: deviceCurrencyCode) {
            return currency
        }

        return .usd
    }
}
