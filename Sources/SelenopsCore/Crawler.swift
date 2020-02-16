//
//  Crawler.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation

/// A web crawler.
///
/// Given a proper `startURL`, this object will crawl the web looking for the
/// given `wordToSearch` and report its findings.
open class Crawler {

  /// The maximum number of pages that the instance will visit.
  ///
  /// - Note: If not enough links are found, the crawler will stop its execution
  ///   prematurely.
  let maximumPagesToVisit: Int

  /// The word the crawler is looking for.
  let wordToSearch: String

  /// The urls of pages the instance has visited already.
  var visitedPages: Set<URL> = []

  /// The urls of pages found during crawling, but yet to visit.
  var pagesToVisit: Set<URL>

  /// This callback is fired each time the crawler is about to visit a new
  /// webpage.
  let visitingCallback: ((URL) -> Void)?

  /// This callback is fired each time the parser finds `wordToSearch` in a
  /// web page (fired up to one time per page).
  let wordFoundCallback: (URL) -> Void

  /// The completion block called when the crawler ends its execution.
  let completion: (Int) -> Void

  /// The current `URLSessionDataTask`, if any.
  var currentTask: URLSessionDataTask?

  /// Crawler initializer.
  ///
  /// - Note: After initialization, you must call `start()` in order for the
  ///   instance to start crawling the web.
  ///
  /// - Parameters:
  ///   - startURL: The starting page URL (must contain http:// or https://).
  ///   - maximumPagesToVisit: The maximum number of web pages to visit.
  ///   - word: The word to look for.
  ///   - visitingCallback: Fired each time the instance is about to visit a new
  ///     webpage.
  ///   - wordFoundCallback: Fired each time the instance finds `wordToSearch`
  ///     in a web page (fired up to one time per page).
  ///   - completion: Called when the instance ends its execution.
  public init(
    startURL: URL,
    maximumPagesToVisit: Int,
    wordToSearch word: String,
    visitingCallback: ((URL) -> Void)?,
    wordFoundCallback: @escaping (URL) -> Void,
    completion: @escaping (Int) -> Void
  ) {
    self.maximumPagesToVisit = maximumPagesToVisit
    self.pagesToVisit = [startURL]
    self.wordToSearch = word
    self.wordFoundCallback = wordFoundCallback
    self.visitingCallback = visitingCallback
    self.completion = completion
  }

  /// Trigger the instance to start crawling the web.
  public func start() {
    crawl()
  }

  /// Immediately ends the crawling process.
  public func cancel() {
    currentTask?.cancel()
    completion(visitedPages.count)
  }

  /// Starts a new crawling cycle.
  func crawl() {
    guard
      visitedPages.count < maximumPagesToVisit,
      let pageToVisit = pagesToVisit.popFirst() else {
      completion(visitedPages.count)
      return
    }

    if visitedPages.contains(pageToVisit) {
      crawl()
    } else {
      visit(page: pageToVisit)
    }
  }

  /// Tells the crawler to visit the given `url` page.
  /// - Parameter url: The page we want to visit.
  func visit(page url: URL) {
    visitedPages.insert(url)

    currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
      defer { self?.crawl() }
      guard
        let data = data,
        let document = String(data: data, encoding: .utf8) else { return }
      self?.parse(document: document, url: url)
    }

    visitingCallback?(url)
    currentTask?.resume()
  }

  /// Parses the given document.
  ///
  /// - Parameters:
  ///   - document: The content to parse.
  ///   - url: The url associated with the document.
  func parse(document: String, url: URL) {
    func find(word: String, from document: String) {
      guard document.contains(word) else { return }
      wordFoundCallback(url)
    }

    func collectLinks(from document: String) -> [URL] {
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
