#!/usr/bin/swift

/**
 *  Selenops
 *  Copyright (c) Federico Zanetello 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension Collection {
  /// Returns the element at the specified index iff it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Iterator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

let defaultMaxWebpages = 10

func printHelp() {
  print("""
    🕸 Synopsis
      selenops word_to_search https://your_start_url [max_pages_number]
    
    🕷 Example
      selenops swift https://developer.apple.com/swift/
    
    🕸 Description
      selenops is a simple swift web crawler that look for a word of your choosing on the web, starting from a given webpage.
      By default it will crawl \(defaultMaxWebpages) webpages, use the third optional parameter to change this behaviour
    
    🕷 Author
      selenops is brought to you by Federico Zanetello (@zntfdr)
    
    🕸 Reporting Bugs
      Please open an issue at https://github.com/zntfdr/Selenops
    """)
}

let args = CommandLine.arguments

guard let wordToSearch: String = args[safe: 1] else {
  printHelp()
  exit(1)
}

let wordToSearch2: String = wordToSearch // this avoids a segmentation fault, I've filed a radar already

guard let startUrlString = args[safe: 2] else {
  print("💥 Missing start url")
  exit(1)
}

guard let startUrl = URL(string: startUrlString) else {
  print("🚫 Bad url!")
  exit(1)
}

let maximumPagesToVisit = Int(args[safe: 3] ?? "") ?? defaultMaxWebpages

// Crawler Parameters
let semaphore = DispatchSemaphore(value: 0)
var visitedPages: Set<URL> = []
var pagesToVisit: Set<URL> = [startUrl]

// Crawler Core
func crawl() {
  guard visitedPages.count < maximumPagesToVisit else {
    print("🏁 Reached max number of pages to visit")
    semaphore.signal()
    return
  }
  guard let pageToVisit = pagesToVisit.popFirst() else {
    print("🏁 No more pages to visit")
    semaphore.signal()
    return
  }
  if visitedPages.contains(pageToVisit) {
    crawl()
  } else {
    visit(page: pageToVisit)
  }
}

func visit(page url: URL) {
  visitedPages.insert(url)
  
  let task = URLSession.shared.dataTask(with: url) { data, response, error in
    defer { crawl() }
    guard
      let data = data,
      error == nil,
      let document = String(data: data, encoding: .utf8) else { return }
    parse(document: document, url: url)
  }
  
  print("🔎 Visiting page: \(url)")
  task.resume()
}

func parse(document: String, url: URL) {
  func find(word: String) {
    if document.contains(word) {
      print("✅ Word '\(word)' found at page \(url)")
    }
  }
  
  func collectLinks() -> [URL] {
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector?.matches(in: document, options: [], range: NSRange(location: 0, length: document.utf16.count))
    return matches?.flatMap { $0.url } ?? []
  }
  
  find(word: wordToSearch2)
  collectLinks().forEach { pagesToVisit.insert($0) }
}

crawl()
semaphore.wait()
