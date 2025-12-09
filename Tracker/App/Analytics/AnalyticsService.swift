import Foundation
import YandexMobileMetrica

final class AnalyticsService {

    static let shared = AnalyticsService()

    private init() {}

    func report(event: String, screen: String, item: String? = nil) {

        var parameters: [String: Any] = [
            "event": event,
            "screen": screen
        ]

        if let item {
            parameters["item"] = item
        }

        YMMYandexMetrica.reportEvent("ui_event", parameters: parameters, onFailure: { error in
            print("AppMetrica event error:", error.localizedDescription)
        })

        print("Analytics:", parameters)
    }
}
