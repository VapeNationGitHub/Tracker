import Foundation

final class OnboardingStorage {
    private let key = "hasSeenOnboarding"
    
    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
