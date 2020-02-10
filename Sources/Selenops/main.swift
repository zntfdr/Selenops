import Foundation

// Input your parameters here
let startUrl = URL(string: "https://developer.apple.com/swift/")!
let wordToSearch = "Swift"
let maximumPagesToVisit = 10

// Crawler Parameters
var visitedPages: Set<URL> = []
var pagesToVisit: Set<URL> = [startUrl]

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

func visit(page url: URL) {
  visitedPages.insert(url)

  let task = URLSession.shared.dataTask(with: url) { data, response, _ in
    defer { crawl() }
    guard
      let data = data,
      let document = String(data: data, encoding: .utf8) else { return }
    parse(document: document, url: url)
  }

  print("🔎 Visiting page: \(url)")
  task.resume()
}

func parse(document: String, url: URL) {
  func find(word: String, from document: String) {
    guard document.contains(word) else { return }
    print("✅ Word '\(word)' found at page \(url)")
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

crawl()

// Playground Options
// mutes annoying Xcode log errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

// needed for asychronous calls
dispatchMain()
