#!/usr/bin/swift

/**
 *  Selenops
 *  Copyright (c) Federico Zanetello 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

// Input your parameters here
var startUrl = URL(string: "https://developer.apple.com/swift/")!
var wordToSearch = "Swift"
var maximumPagesToVisit = 10

// Crawler Parameters
let semaphore = DispatchSemaphore(value: 0)
var visitedPages: Set<URL> = []
var pagesToVisit: Set<URL> = [startUrl] //originally set this to startURL, set below for dynamic page setting

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

func validateUrl(urlString: String) -> Bool {
  // create NSURL instance
  if NSURL(string: urlString) != nil {
    // check if your application can open the NSURL instance
    return true
  }
  return false
}

//error out from bad parameters
func errorOut(message: String) {
  print("🚫 Error: \(message)");
  exit(1);
}


/**
 * April 13, 2017, added support for dynamic URL, search word, and max page visits.
 * Validate and set URL below as well as set the search word and max page visits.added
 * Max page visits is optional, it defaults to 10. If no arguments are added, then
 * the pre-defined arguments are used.
 */
let args:[String] = CommandLine.arguments
//lets check if they just use type -help or help
if (args.count == 2) {
  if args[1] == "help" || args[1] == "-help" {
    print("usage: swift selenops [startUrl searchWord [maxNumberOfPagesToVisit]]");
    print("\t-Either no arguments can be used, two arguments can be used (startUrl");
    print("\t and searchWord), or all three arguments can be used.");
    exit(0);
  }
}
//we should have a URL and a word
if (args.count >= 3) {     //validate and set the word
  if validateUrl(urlString: args[1]) {
    startUrl = URL(string: args[1])!
  } else {
    //exits application
    errorOut(message: "Bad URL!");
  }
  
  //now we set the word
  wordToSearch = args[2];
  
  //now set max pages to search
  if (args.count == 4) {
    if let max:Int = Int(args[3]) {
      maximumPagesToVisit = max
    }
  }
  
  pagesToVisit = [startUrl] //we need to set it again because we have changed the startUrl
}

crawl()
semaphore.wait()
