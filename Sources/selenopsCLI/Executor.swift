//
//  Executor.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation
import Selenops

final class Executor: CrawlerDelegate {
  var visitedPagesNumber = 0

  func run(parameters: Parameters) {
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

  func crawler(_ crawler: Crawler, willVisitUrl url: URL) {
    print("🔎 Visiting: \(url)")
    visitedPagesNumber += 1
  }

  func crawler(_ crawler: Crawler, didFindWordAt url: URL) {
    print("✅ \(url.absoluteString)")
  }

  func crawlerDidFinish(_ crawler: Crawler) {
    print("🏁 Visited pages: \(visitedPagesNumber)")
    exit(EXIT_SUCCESS)
  }
}
