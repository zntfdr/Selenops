//
//  URL+ArgumentKind.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation
import TSCUtility

extension Foundation.URL: ArgumentKind {

  enum InitializationError: Error {
    case malformedURL
  }

  public init(argument: String) throws {
    if let url = URL(string: argument) {
      self = url
    } else {
      throw InitializationError.malformedURL
    }
  }

  public static var completion: ShellCompletion {
    .none
  }
}
