import Foundation
import ArgumentParser

struct Selenops: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Searches for the given word on the web."
  )

  @Option(
    name: [.short, .customLong("start")],
    help: "The starting page URL (must have http:// or https:// prefix)."
  )
  var startUrl: URL

  @Option(
    name: [.short, .customLong("word")],
    help: "The word to look for."
  )
  var wordToSearch: String

  @Option(
    name: [.short, .customLong("max")],
    default: 10,
    help: "The maximum number of pages to visit."
  )
  var maximumPagesToVisit: Int

  func run() throws {
    print("✅ Searching for: \(wordToSearch)")
    print("✅ Starting from: \(startUrl.absoluteString)")
    print("✅ Maximum number of pages to visit: \(maximumPagesToVisit)")

    Executor(
      startUrl: startUrl,
      wordToSearch: wordToSearch,
      maximumPagesToVisit: maximumPagesToVisit
    ).run()
  }
}

Selenops.main()
