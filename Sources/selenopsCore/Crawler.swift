//
//  Crawler.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation

open class Crawler {
  private let maximumPagesToVisit: Int
  private let wordToSearch: String
  private lazy var visitedPages: Set<URL> = []
  private var pagesToVisit: Set<URL> = []

  init(startURL: URL, maximumPagesToVisit: Int, wordToSearch word: String) {
    self.maximumPagesToVisit = maximumPagesToVisit
    self.pagesToVisit = [startURL]
    self.wordToSearch = word
  }

  // Crawler Core
  func crawl() {
    guard visitedPages.count <= maximumPagesToVisit else {
      print("🏁 Reached max number of pages to visit")
      return
    }
    guard let pageToVisit = pagesToVisit.popFirst() else {
      print("🏁 No more pages to visit")
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

    let task = URLSession.shared.dataTask(with: url) { data, response, _ in
      defer { self.crawl() }
      guard
        let data = data,
        let document = String(data: data, encoding: .utf8) else { return }
      self.parse(document: document, url: url)
    }

    print("🔎 Visiting page: \(url)")
    task.resume()
  }

  func parse(document: String, url: Foundation.URL) {
    func find(word: String, from document: String) {
      guard document.contains(word) else { return }
      print("✅ Word '\(word)' found at page \(url)")
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
