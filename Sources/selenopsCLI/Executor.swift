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
    print("✅ Searching for '\(parameters.wordToSearch)'")
    print("✅ Starting from '\(parameters.startUrl.absoluteString)'")

    let publisher = CrawlerPublisher(
      startURL: parameters.startUrl,
      wordToSearch: parameters.wordToSearch,
      maxNumberOfPagesToVisit: parameters.maximumPagesToVisit
    )

    let cancellable = publisher
      .map{ url in
        print(url)
        return url.absoluteString
    }
    .sink(receiveCompletion: { completion in
      print("it ded")
    }) { value in
      print(value)
    }

    //    let crawler = Crawler(startURL: parameters.startUrl,
    //                          maximumPagesToVisit: parameters.maximumPagesToVisit,
    //                          wordToSearch: parameters.wordToSearch)
    //    crawler.start()

    dispatchMain()
  }
}
