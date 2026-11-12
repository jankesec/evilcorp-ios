import XCTest

@testable import EvilCorp

final class ChallengeProgressTests: XCTestCase {
  private var suiteName: String!
  private var defaults: UserDefaults!

  override func setUp() {
    super.setUp()
    suiteName = "evilcorp.tests.\(UUID().uuidString)"
    defaults = UserDefaults(suiteName: suiteName)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suiteName)
    defaults = nil
    suiteName = nil
    super.tearDown()
  }

  private func challenge(_ difficulty: String) throws -> EvilCorpChallenge {
    try XCTUnwrap(EvilCorpChallenge.all.first { $0.difficulty == difficulty })
  }

  func testTogglingASolvedChallengeCannotInflateTheCTFScore() throws {
    let hard = try challenge("Hard")
    let progress = ChallengeProgress(defaults: defaults)
    progress.startCTF()

    for _ in 0..<5 {
      progress.toggle(hard.id)  // solve
      progress.toggle(hard.id)  // unsolve
    }
    XCTAssertEqual(progress.ctfScore, 0)

    progress.toggle(hard.id)
    XCTAssertEqual(progress.ctfScore, AppMetadata.points(for: hard.id))
  }

  func testOnlySolvesDuringTheSessionCountTowardsTheCTFScore() throws {
    let easy = try challenge("Easy")
    let medium = try challenge("Medium")
    let progress = ChallengeProgress(defaults: defaults)

    progress.toggle(easy.id)
    progress.startCTF()
    progress.toggle(medium.id)

    XCTAssertEqual(progress.completed, [easy.id, medium.id])
    XCTAssertEqual(progress.ctfScore, AppMetadata.points(for: medium.id))
  }

  func testCTFSessionSurvivesARelaunch() throws {
    let medium = try challenge("Medium")
    let start = Date(timeIntervalSince1970: 1_800_000_000)
    let first = ChallengeProgress(defaults: defaults)
    first.startCTF(at: start)
    first.toggle(medium.id)
    first.toggleBookmark(medium.id)

    let relaunched = ChallengeProgress(defaults: defaults)

    XCTAssertTrue(relaunched.ctfMode)
    XCTAssertEqual(relaunched.ctfStart, start)
    XCTAssertEqual(relaunched.ctfScore, AppMetadata.points(for: medium.id))
    XCTAssertTrue(relaunched.isCompleted(medium.id))
    XCTAssertTrue(relaunched.isBookmarked(medium.id))
  }

  func testStoppingTheCTFClearsTheSessionButKeepsCompletions() throws {
    let easy = try challenge("Easy")
    let progress = ChallengeProgress(defaults: defaults)
    progress.startCTF()
    progress.toggle(easy.id)

    progress.stopCTF()

    XCTAssertFalse(progress.ctfMode)
    XCTAssertEqual(progress.ctfScore, 0)
    XCTAssertTrue(progress.isCompleted(easy.id))
    XCTAssertFalse(ChallengeProgress(defaults: defaults).ctfMode)
  }

  func testResetClearsEverythingForEveryScreen() throws {
    let easy = try challenge("Easy")
    let progress = ChallengeProgress(defaults: defaults)
    progress.startCTF()
    progress.toggle(easy.id)
    progress.toggleBookmark(easy.id)

    progress.resetAll()

    XCTAssertTrue(progress.completed.isEmpty)
    XCTAssertTrue(progress.bookmarks.isEmpty)
    XCTAssertFalse(progress.ctfMode)
    let relaunched = ChallengeProgress(defaults: defaults)
    XCTAssertTrue(relaunched.completed.isEmpty)
    XCTAssertTrue(relaunched.bookmarks.isEmpty)
    XCTAssertFalse(relaunched.ctfMode)
  }

  func testUnknownIdentifiersFromOlderBuildsAreIgnored() throws {
    let easy = try challenge("Easy")
    defaults.set([easy.id, "removed-challenge"], forKey: ChallengeProgress.Keys.completed)

    let progress = ChallengeProgress(defaults: defaults)

    XCTAssertEqual(progress.completed, [easy.id])
  }

  func testEveryCatalogEntryHasALabScreen() {
    XCTAssertEqual(LabRegistry.registeredIDs, Set(EvilCorpChallenge.all.map(\.id)))
  }
}
