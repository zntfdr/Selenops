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
    let crawler = Crawler(startURL: parameters.startUrl,
                          maximumPagesToVisit: parameters.maximumPagesToVisit,
                          wordToSearch: parameters.wordToSearch)
  }
}
