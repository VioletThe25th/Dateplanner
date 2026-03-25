import Foundation
import Combine

final class CurrencyManager: ObservableObject {
    private static let storageKey = "selectedAppCurrency"

    @Published private(set) var currency: CurrencyOption

    init(defaults: UserDefaults = .standard) {
        if let storedValue = defaults.string(forKey: Self.storageKey),
           let storedCurrency = CurrencyOption(rawValue: storedValue) {
            self.currency = storedCurrency
        } else {
            let resolved = CurrencyOption.resolvedFromDevice()
            self.currency = resolved
            defaults.set(resolved.rawValue, forKey: Self.storageKey)
        }
    }

    func setCurrency(_ currency: CurrencyOption) {
        guard self.currency != currency else { return }
        self.currency = currency
        UserDefaults.standard.set(currency.rawValue, forKey: Self.storageKey)
    }

    static let preview = CurrencyManager()
}
