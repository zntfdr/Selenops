//
//  Parser.swift
//  
//
//  Created by Federico Zanetello on 2/12/20.
//

import Foundation
import TSCUtility

/// Parses the input from the command line.
///
/// It also declares what are all the possible argument types.
final class Parser {
  private let arguments: [String]

  public init(arguments: [String] = CommandLine.arguments) {
    // We drop the first argument, which is the script path.
    self.arguments = Array(arguments.dropFirst())
  }

  /// Returns the action requested by the user (if any).
  public func parse() throws -> Parameters {
    // Initializes and sets up the `ArgumentParser` instance.
    let parser = ArgumentParser(
      usage: "[-s https://...] [-w wordToSearch] [-m maxNumberOfVisitedPages]",
      overview: "Searches for the given word on the web"
    )

    let pageArgument: OptionArgument<Foundation.URL> = parser.add(
      option: "--start",
      shortName: "-s",
      kind: Foundation.URL.self,
      usage: "The starting page URL (must contain http:// or https://)"
    )

    let wordArgument: OptionArgument<String> = parser.add(
      option: "--word",
      shortName: "-w",
      kind: String.self,
      usage: "The word to look for"
    )

    let pageNumberArgument: OptionArgument<Int> = parser.add(
      option: "--max",
      shortName: "-m",
      kind: Int.self,
      usage: "The maximum number of pages to visit"
    )

    let parsedArguments: ArgumentParser.Result = try parser.parse(arguments)

    let startUrl = parsedArguments.get(pageArgument) ?? URL(string: "https://developer.apple.com/swift/")!
    let wordToSearch = parsedArguments.get(wordArgument) ?? "Swift"
    let maximumPagesToVisit = parsedArguments.get(pageNumberArgument) ?? 10

    return Parameters(
      startUrl: startUrl,
      wordToSearch: wordToSearch,
      maximumPagesToVisit: maximumPagesToVisit
    )
  }
}
