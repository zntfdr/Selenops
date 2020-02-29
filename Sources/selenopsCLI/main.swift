import Foundation
import ArgumentParser

struct Selenops: ParsableCommand {
  @Option(name: .shortAndLong) var start: URL //startUrl
  @Option(name: .shortAndLong) var word: String //wordToSearch
  @Option(name: .shortAndLong, default: 10) var max: Int //maximumPagesToVisit

  func run() throws {
    print("✅ Searching for: \(word)")
    print("✅ Starting from: \(start.absoluteString)")
    print("✅ Maximum number of pages to visit: \(max)")

    Executor(startUrl: start, wordToSearch: word, maximumPagesToVisit: max).run()
  }
}

Selenops.main()
