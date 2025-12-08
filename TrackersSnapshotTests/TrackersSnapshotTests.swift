import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testMainScreenLight() {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)

        nav.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        // Светлая тема
        let lightTrait = UITraitCollection(userInterfaceStyle: .light)

        assertSnapshot(
            matching: nav,
            as: .image(traits: lightTrait),
            named: "MainScreen_Light"
        )
    }

    func testMainScreenDark() {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)

        nav.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        // Тёмная тема
        let darkTrait = UITraitCollection(userInterfaceStyle: .dark)

        assertSnapshot(
            matching: nav,
            as: .image(traits: darkTrait),
            named: "MainScreen_Dark"
        )
    }
}
