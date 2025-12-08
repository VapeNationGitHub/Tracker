import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()

        isRecording = false
    }

    func testTrackersMainScreen() {
        let vc = TrackersViewController()

        let nav = UINavigationController(rootViewController: vc)

        // Размер экрана iPhone 16 Pro
        nav.view.frame = CGRect(x: 0, y: 0, width: 402, height: 874)

        nav.view.layoutIfNeeded()

        // Сам снимок (эталон будет записан в __Snapshots__)
        assertSnapshot(matching: nav, as: .image)
    }
}
