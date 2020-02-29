//
//  URL+ExpressibleByArgument.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation
import ArgumentParser

extension URL: ExpressibleByArgument {

  public init?(argument: String) {
    guard
      argument.hasPrefix("http://") || argument.hasPrefix("https://"),
      let url = URL(string: argument) else { return nil }
    self = url
  }
}
