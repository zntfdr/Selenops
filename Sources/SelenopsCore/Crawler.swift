//
//  Crawler.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation

public class Crawler {
  let maximumPagesToVisit: Int
  private let wordToSearch: String
  private lazy var visitedPages: Set<URL> = []
  private var pagesToVisit: Set<URL> = []
  private let visitingCallback: ((URL) -> Void)?
  private let wordFoundCallback: ((URL) -> Void)?
  private let completion: (() -> Void)?

  public init(startURL: URL, maximumPagesToVisit: Int, wordToSearch word: String, visitingCallback: ((URL) -> Void)?, wordFoundCallback: ((URL) -> Void)?, completion: (() -> Void)?) {
    self.maximumPagesToVisit = maximumPagesToVisit
    self.pagesToVisit = [startURL]
    self.wordToSearch = word
    self.wordFoundCallback = wordFoundCallback
    self.visitingCallback = visitingCallback
    self.completion = completion
  }

  public func start() {
    crawl()
  }

  func crawl() {
    guard visitedPages.count <= maximumPagesToVisit else {
      completion?()
//      print("🏁 Reached max number of pages to visit")
      return
    }
    guard let pageToVisit = pagesToVisit.popFirst() else {
      completion?()
//      print("🏁 No more pages to visit")
      return
    }
    if visitedPages.contains(pageToVisit) {
      crawl()
    } else {
      visit(page: pageToVisit)
    }
  }

  func visit(page url: Foundation.URL) {
    visitedPages.insert(url)

    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
      defer { self.crawl() }
      guard
        let data = data,
        let document = String(data: data, encoding: .utf8) else { return }
      self.parse(document: document, url: url)
    }

    visitingCallback?(url)
    task.resume()
  }

  func parse(document: String, url: Foundation.URL) {
    func find(word: String, from document: String) {
      guard document.contains(word) else { return }
      wordFoundCallback?(url)
    }

    func collectLinks(from document: String) -> [Foundation.URL] {
      let types: NSTextCheckingResult.CheckingType = .link
      let detector = try? NSDataDetector(types: types.rawValue)
      let range = NSRange(0..<document.count)
      let matches = detector?.matches(in: document, options: [], range: range)
      return matches?.compactMap { $0.url } ?? []
    }

    find(word: wordToSearch, from: document)
    collectLinks(from: document).forEach { pagesToVisit.insert($0) }
  }
}
