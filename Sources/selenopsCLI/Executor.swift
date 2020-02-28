//
//  Executor.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation
import Selenops
import TSCBasic
import TSCUtility

final class Executor: CrawlerDelegate {
  var visitedPagesNumber = 0
  let animation = NinjaProgressAnimation(stream: stdoutStream)
  let parameters: Parameters

  init(parameters: Parameters) {
    self.parameters = parameters
  }

  func run() {
    print("✅ Searching for: \(parameters.wordToSearch)")
    print("✅ Starting from: \(parameters.startUrl.absoluteString)")
    print("✅ Maximum number of pages to visit: \(parameters.maximumPagesToVisit)")
    print("Word found at:")

    let crawler = Crawler(
      startURL: parameters.startUrl,
      maximumPagesToVisit: parameters.maximumPagesToVisit,
      wordToSearch: parameters.wordToSearch
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
      total: parameters.maximumPagesToVisit,
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
