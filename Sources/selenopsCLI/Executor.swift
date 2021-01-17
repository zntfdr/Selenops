import Foundation
import Selenops
import TSCBasic
import TSCUtility

final class Executor: CrawlerDelegate {
  var visitedPagesNumber = 0
  let animation = NinjaProgressAnimation(stream: stdoutStream)

  let startUrl: Foundation.URL
  let wordToSearch: String
  let maximumPagesToVisit: Int

  init(
    startUrl: Foundation.URL,
    wordToSearch: String,
    maximumPagesToVisit: Int
  ) {
    self.startUrl = startUrl
    self.wordToSearch = wordToSearch
    self.maximumPagesToVisit = maximumPagesToVisit
  }

  func run() {
    print("Word found at:")

    let crawler = Crawler(
      startURL: startUrl,
      maximumPagesToVisit: maximumPagesToVisit,
      wordToSearch: wordToSearch
    )

    crawler.delegate = self
    crawler.start()

    dispatchMain()
  }

  // MARK: CrawlerDelegate

  func crawler(_ crawler: Crawler, willVisitUrl url: Foundation.URL) {
    visitedPagesNumber += 1
    animation.clear()
    animation.update(
      step: visitedPagesNumber,
      total: maximumPagesToVisit,
      text: "Fetching \(url)"
    )
  }

  func crawler(_ crawler: Crawler, didFindWordAt url: Foundation.URL) {
    animation.clear()
    print("✅ \(url.absoluteString)")
  }

  func crawlerDidFinish(_ crawler: Crawler) {
    animation.clear()
    print("🏁 Visited pages: \(visitedPagesNumber)")
    exit(EXIT_SUCCESS)
  }
}
