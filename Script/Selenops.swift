#!/usr/bin/swift

/**
 *  Selenops
 *  Copyright (c) Federico Zanetello 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension Collection where Indices.Iterator.Element == Index {
  /// Returns the element at the specified index iff it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Generator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

let defaultMaxWebpages = 10

func printHelp() {
  print("🕸 Synopsis")
  print("\tselenops word_to_search https://your_start_url [max_pages_number]")
  print("")
  print("🕷 Example")
  print("\tselenops swift https://developer.apple.com/swift/")
  print("")
  print("🕸 Description")
  print("\tselenops is a simple swift web crawler that look for a word of your choosing on the web, starting from a given webpage.")
  print("By default it will crawl \(defaultMaxWebpages) webpages, use the third optional parameter to change this behaviour")
  print("")
  print("🕷 Author")
  print("\tselenops is brought to you by Federico Zanetello (@zntfdr)")
  print("")
  print("🕸 Reporting Bugs")
  print("\tPlease open an issue at https://github.com/zntfdr/Selenops")
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
    func getMatches(pattern: String, text: String) -> [String] {
      // used to remove the 'href="' & '"' from the matches
      func trim(url: String) -> String {
        return String(url.characters.dropLast()).substring(from: url.index(url.startIndex, offsetBy: "href=\"".characters.count))
      }
      
      let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
      let matches = regex.matches(in: text, options: [.reportCompletion], range: NSRange(location: 0, length: text.characters.count))
      return matches.map { trim(url: (text as NSString).substring(with: $0.range)) }
    }
    
    let pattern = "href=\"(http://.*?|https://.*?)\""
    let matches = getMatches(pattern: pattern, text: document)
    return matches.flatMap { URL(string: $0) }
  }
  find(word: wordToSearch2)
  collectLinks().forEach { pagesToVisit.insert($0) }
}

crawl()
semaphore.wait()
