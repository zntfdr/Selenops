//
//  Executor.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation
import Selenops

final class Executor {
  func run(parameters: Parameters) {
    print("✅ Searching for: \(parameters.wordToSearch)")
    print("✅ Starting from: \(parameters.startUrl.absoluteString)")
    print("✅ Maximum number of pages to visit: \(parameters.maximumPagesToVisit)")

    let visitingCallback: (URL) -> Void = { url in
      print("🔎 Visiting: \(url)")
    }

    let wordFoundCallback: (URL) -> Void = { url in
      print("✅ Word found at: \(url.absoluteString)")
    }

    let completion: (Int) -> Void = { visitedPagesNumber in
      print("🏁 Visited pages: \(visitedPagesNumber)")
      exit(EXIT_SUCCESS)
    }

    let crawler = Crawler(
      startURL: parameters.startUrl,
      maximumPagesToVisit: parameters.maximumPagesToVisit,
      wordToSearch: parameters.wordToSearch,
      visitingCallback: visitingCallback,
      wordFoundCallback: wordFoundCallback,
      completion: completion
    )

    crawler.start()

    dispatchMain()
  }
}
