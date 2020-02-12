import Foundation
import TSCUtility

let parser = ArgumentParser(
  usage: "selenops",
  overview: "Searches for the given word on the web"
)

let pageArgument: OptionArgument<Foundation.URL> = parser.add(
  option: "--page",
  shortName: "-p",
  kind: Foundation.URL.self,
  usage: "The starting URL"
)

let wordArgument: OptionArgument<String> = parser.add(
  option: "--word",
  shortName: "-w",
  kind: String.self,
  usage: "The word to look for"
)

let pageNumberArgument: OptionArgument<Int> = parser.add(
  option: "--number",
  shortName: "-n",
  kind: Int.self,
  usage: "The maximum number of pages to visit")

do {
  let arguments = Array(CommandLine.arguments.dropFirst())
  let parsedArguments = try parser.parse(arguments)

  let startUrl = parsedArguments.get(pageArgument) ?? URL(string: "https://developer.apple.com/swift/")!
  let wordToSearch = parsedArguments.get(wordArgument) ?? "Swift"
  let maximumPagesToVisit = parsedArguments.get(pageNumberArgument) ?? 10

  print(startUrl, wordToSearch, maximumPagesToVisit)
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print(error.localizedDescription)
}
