import Foundation

enum AppMetadata {
  static let name = "EvilCorp"
  static let trainingPurpose = "Intentionally vulnerable mobile security laboratory"

  static var challengeCount: Int { EvilCorpChallenge.all.count }
  static var categoryCount: Int { Set(EvilCorpChallenge.all.map(\.category)).count }

  static var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
  }

  static func points(for challengeID: String) -> Int {
    guard let challenge = EvilCorpChallenge.all.first(where: { $0.id == challengeID }) else {
      return 0
    }
    switch challenge.difficulty {
    case "Hard": return 300
    case "Medium": return 200
    default: return 100
    }
  }
}
