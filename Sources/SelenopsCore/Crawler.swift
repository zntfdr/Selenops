//
//  Crawler.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Combine
import Foundation

public class CrawlerSubscription<T: Subscriber>: Subscription where T.Input == URL {
  private var subscriber: T?
  let startURL: URL
  let wordToSearch: String
  let maxNumberOfPagesToVisit: Int

  init(subscriber: T, startURL: URL, wordToSearch: String, maxNumberOfPagesToVisit: Int) {
    self.subscriber = subscriber
    self.startURL = startURL
    self.wordToSearch = wordToSearch
    self.maxNumberOfPagesToVisit = maxNumberOfPagesToVisit
  }

  public func request(_ demand: Subscribers.Demand) {
    let callback: (URL) -> Void = { url in
        self.subscriber?.receive(url)
    }

    // demand.max
    let crawler = Crawler(startURL: startURL, maximumPagesToVisit: maxNumberOfPagesToVisit, wordToSearch: wordToSearch, callback: callback) {
      self.subscriber?.receive(completion: .finished)
    }
    crawler.crawl()
  }

  public func cancel() {
    subscriber = nil
  }
}

public enum CrawlerError: Error {
  case network(Error)
}

public struct CrawlerPublisher: Publisher {
  let startURL: URL
  let wordToSearch: String
  let maxNumberOfPagesToVisit: Int

  public init(startURL: URL, wordToSearch: String, maxNumberOfPagesToVisit: Int) {
    self.startURL = startURL
    self.wordToSearch = wordToSearch
    self.maxNumberOfPagesToVisit = maxNumberOfPagesToVisit
  }

  public func receive<S>(subscriber: S) where S: Subscriber, S.Input == URL {
    let subscription = CrawlerSubscription(subscriber: subscriber, startURL: startURL, wordToSearch: wordToSearch, maxNumberOfPagesToVisit: maxNumberOfPagesToVisit)
    // Tells the subscriber that it has successfully subscribed to the publisher
    // and may request items.
    subscriber.receive(subscription: subscription)
  }

  public typealias Output = URL
  public typealias Failure = CrawlerError
}

class Crawler {
  private let maximumPagesToVisit: Int
  private let wordToSearch: String
  private lazy var visitedPages: Set<URL> = []
  private var pagesToVisit: Set<URL> = []
  private let callback: (URL) -> Void
  private let completion: () -> Void

  public init(startURL: URL, maximumPagesToVisit: Int, wordToSearch word: String, callback: @escaping (URL) -> Void, completion: @escaping () -> Void) {
    self.maximumPagesToVisit = maximumPagesToVisit
    self.pagesToVisit = [startURL]
    self.wordToSearch = word
    self.callback = callback
    self.completion = completion
  }

  public func start() {
    crawl()
  }

  func crawl() {
    guard visitedPages.count <= maximumPagesToVisit else {
      completion()
//      print("🏁 Reached max number of pages to visit")
      return
    }
    guard let pageToVisit = pagesToVisit.popFirst() else {
      completion()
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

    print("🔎 Visiting page: \(url)")
    task.resume()
  }

  func parse(document: String, url: Foundation.URL) {
    func find(word: String, from document: String) {
      guard document.contains(word) else { return }
      callback(url)
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
