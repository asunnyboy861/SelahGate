import XCTest
@testable import SelahGate

final class SelahGateTests: XCTestCase {

    func testQuotaFreeUser() {
        XCTAssertTrue(QuotaLogic.canUnlock(pro: false, freeRitualsUsed: 0))
        XCTAssertTrue(QuotaLogic.canUnlock(pro: false, freeRitualsUsed: 2))
        XCTAssertFalse(QuotaLogic.canUnlock(pro: false, freeRitualsUsed: 3))
        XCTAssertFalse(QuotaLogic.canUnlock(pro: false, freeRitualsUsed: 10))
    }

    func testQuotaProUser() {
        XCTAssertTrue(QuotaLogic.canUnlock(pro: true, freeRitualsUsed: 0))
        XCTAssertTrue(QuotaLogic.canUnlock(pro: true, freeRitualsUsed: 99))
    }

    func testSRSLearning() {
        let first = SRS.next(easiness: 2.5, interval: 0, reps: 0, quality: 4)
        XCTAssertEqual(first.interval, 1)
        XCTAssertEqual(first.reps, 1)

        let second = SRS.next(easiness: first.easiness, interval: first.interval, reps: first.reps, quality: 5)
        XCTAssertEqual(second.interval, 3)
        XCTAssertEqual(second.reps, 2)
    }

    func testSRSForgetIsForgiving() {
        let result = SRS.next(easiness: 2.5, interval: 10, reps: 3, quality: 1)
        XCTAssertEqual(result.interval, 1)
        XCTAssertEqual(result.reps, 0)
        XCTAssertEqual(result.easiness, 1.76, accuracy: 0.001)
    }

    func testSRSMasteryFloor() {
        let result = SRS.next(easiness: 2.5, interval: 30, reps: 5, quality: 5)
        XCTAssertGreaterThanOrEqual(result.easiness, 1.3)
        XCTAssertGreaterThan(result.interval, 30)
    }

    func testNonceValidity() {
        XCTAssertTrue(NonceGuard.isValid(timestamp: Date()))
        XCTAssertFalse(NonceGuard.isValid(timestamp: Date().addingTimeInterval(-700)))
        XCTAssertFalse(NonceGuard.isValid(timestamp: Date().addingTimeInterval(700)))
    }

    func testVerseLibraryIntegrity() {
        XCTAssertGreaterThan(VerseLibrary.count, 500)
        let today = VerseLibrary.randomToday()
        XCTAssertFalse(today.text.isEmpty)
        XCTAssertFalse(today.ref.isEmpty)
        let again = VerseLibrary.randomToday()
        XCTAssertEqual(today.ref, again.ref)
    }

    func testVerseDedupAcrossMoods() {
        var seen = Set<String>()
        for _ in 0..<10 {
            let verse = VerseLibrary.pick(mood: MoodTag.all[0], excluding: seen)
            XCTAssertFalse(seen.contains(verse.ref))
            seen.insert(verse.ref)
        }
    }

    func testMoodRouting() {
        for mood in MoodTag.all {
            let verse = VerseLibrary.pick(mood: mood, excluding: [])
            XCTAssertTrue(verse.mood.contains(mood.id), "Verse for \(mood.id) should carry its mood tag")
        }
    }

    func testDepthWindows() {
        XCTAssertEqual(RitualDepth.light.windowMinutes, 15)
        XCTAssertEqual(RitualDepth.medium.windowMinutes, 30)
        XCTAssertEqual(RitualDepth.deep.windowMinutes, 60)
    }

    func testPrayerLibraryLoaded() {
        let prayer = PrayerLibrary.pick(mood: MoodTag.all[0])
        XCTAssertNotNil(prayer)
        XCTAssertGreaterThan(prayer?.text.count ?? 0, 40)
    }

    func testPendingRitualExpiry() {
        let ritual = PendingRitual(source: "test", depth: .light)
        XCTAssertFalse(ritual.isExpired)
    }
}
