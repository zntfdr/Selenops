//
//  Executor.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation
import SelenopsCore

final class Executor {
  func run(parameters: Parameters) {
    print("✅ Searching for: \(parameters.wordToSearch)")
    print("✅ Starting from: \(parameters.startUrl.absoluteString)")
    print("✅ Maximum numbe of pages to visit: \(parameters.maximumPagesToVisit)")

    let publisher = CrawlerPublisher(
      startURL: parameters.startUrl,
      wordToSearch: parameters.wordToSearch,
      maxNumberOfPagesToVisit: parameters.maximumPagesToVisit
    )

    let cancellable = publisher
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          exit(EXIT_SUCCESS)
        case .failure(let failure):
          print("💥 An error occurred: \(failure)")
          exit(EXIT_FAILURE)
        }
    }) { url in
      print("✅ Word found at: \(url.absoluteString)")
    }

    dispatchMain()
  }
}
