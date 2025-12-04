import Foundation

final class OnboardingStorage {
    static let shared = OnboardingStorage()
    private init() {}

    private let key = "hasSeenOnboarding"

    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
