import Foundation

@main
struct CatalogCheck {
    static func main() {
        let challenges = EvilCorpChallenge.all
        var failures: [String] = []

        if challenges.count != 30 {
            failures.append("expected 30 challenges, found \(challenges.count)")
        }
        if Set(challenges.map(\.id)).count != challenges.count {
            failures.append("challenge identifiers are not unique")
        }

        for challenge in challenges {
            if challenge.hints.count != 3 {
                failures.append("\(challenge.id) must provide exactly three hints")
            }
            if challenge.cwe.isEmpty || challenge.masvs.isEmpty || challenge.maswe.isEmpty {
                failures.append("\(challenge.id) is missing security mapping metadata")
            }
            if AppMetadata.points(for: challenge.id) == 0 {
                failures.append("\(challenge.id) has no CTF point mapping")
            }
        }

        if failures.isEmpty {
            print("catalog check passed: \(challenges.count) unique challenges")
            return
        }

        failures.forEach { FileHandle.standardError.write("error: \($0)\n".data(using: .utf8)!) }
        exit(1)
    }
}
