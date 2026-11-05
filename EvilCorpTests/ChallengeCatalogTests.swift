import XCTest

@testable import EvilCorp

final class ChallengeCatalogTests: XCTestCase {
  func testCatalogContainsThirtyUniqueChallenges() {
    let challenges = EvilCorpChallenge.all
    XCTAssertEqual(challenges.count, 30)
    XCTAssertEqual(Set(challenges.map(\.id)).count, challenges.count)
  }

  func testEveryChallengeHasTrainingMetadata() {
    for challenge in EvilCorpChallenge.all {
      XCTAssertFalse(challenge.title.isEmpty, challenge.id)
      XCTAssertFalse(challenge.description.isEmpty, challenge.id)
      XCTAssertFalse(challenge.cwe.isEmpty, challenge.id)
      XCTAssertFalse(challenge.masvs.isEmpty, challenge.id)
      XCTAssertFalse(challenge.maswe.isEmpty, challenge.id)
      XCTAssertEqual(challenge.hints.count, 3, challenge.id)
      XCTAssertFalse(challenge.fridaSnippet.isEmpty, challenge.id)
      XCTAssertTrue(["Easy", "Medium", "Hard"].contains(challenge.difficulty), challenge.id)
    }
  }

  func testCTFPointsFollowDifficulty() {
    let easy = try? XCTUnwrap(EvilCorpChallenge.all.first { $0.difficulty == "Easy" })
    let medium = try? XCTUnwrap(EvilCorpChallenge.all.first { $0.difficulty == "Medium" })
    let hard = try? XCTUnwrap(EvilCorpChallenge.all.first { $0.difficulty == "Hard" })

    XCTAssertEqual(easy.map { AppMetadata.points(for: $0.id) }, 100)
    XCTAssertEqual(medium.map { AppMetadata.points(for: $0.id) }, 200)
    XCTAssertEqual(hard.map { AppMetadata.points(for: $0.id) }, 300)
  }
}
