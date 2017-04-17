#!/usr/bin/swift

/**
 *  Selenops
 *  Copyright (c) Federico Zanetello 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

// Input your parameters here
let startUrl: URL
var wordToSearch = "Swift"
var maximumPagesToVisit = 10

// Crawler Parameters
let semaphore = DispatchSemaphore(value: 0)
var visitedPages: Set<URL> = []
var pagesToVisit: Set<URL> = []

// Crawler Core
func crawl() {
  guard visitedPages.count <= maximumPagesToVisit else {
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
  
  find(word: wordToSearch)
  collectLinks().forEach { pagesToVisit.insert($0) }
}

let args: [String] = CommandLine.arguments
//if they use an incorrect number of parameters, show help
if args.count == 2 || args.count > 4 {
  print("usage: swift selenops [startUrl searchWord [maxNumberOfPagesToVisit]]")
  print("\t-Either no arguments can be used, two arguments can be used (startUrl")
  print("\t and searchWord), or all three arguments can be used.")
  exit(0)
}
//we should have a URL and a word
if args.count >= 3 {     //validate and set the word
  guard let url = URL(string: args[1]) else {
    print("🚫 Bad url!")
    exit(1)
  }
  
  startUrl = url
  wordToSearch = args[2]
  if args.count == 4 {
    if let max = Int(args[3]) {
      maximumPagesToVisit = max
    }
  }
} else {
  startUrl = URL(string: "https://developer.apple.com/swift/")! //sample URL
}

pagesToVisit = [startUrl] //set to default or whatever input comes from parameters

crawl()
semaphore.wait()
