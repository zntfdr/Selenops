import Foundation
import ArgumentParser

struct Selenops: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Searches for the given word on the web."
  )

  @Option(
    name: .shortAndLong,
    help: "The starting page URL (must have http:// or https:// prefix)."
  )
  var start: URL //startUrl

  @Option(
    name: .shortAndLong,
    help: "The word to look for."
  )
  var word: String //wordToSearch

  @Option(
    name: .shortAndLong,
    default: 10,
    help: "The maximum number of pages to visit."
  )
  var max: Int //maximumPagesToVisit

  func run() throws {
    print("✅ Searching for: \(word)")
    print("✅ Starting from: \(start.absoluteString)")
    print("✅ Maximum number of pages to visit: \(max)")

    Executor(startUrl: start, wordToSearch: word, maximumPagesToVisit: max).run()
  }
}

Selenops.main()
