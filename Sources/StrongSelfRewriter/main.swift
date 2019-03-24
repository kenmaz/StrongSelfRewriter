import Foundation
import StrongSelfRewriterCore
import Utility
import Basic

let parser = ArgumentParser(commandName: "my-command", usage: "usage", overview: "overview")
let pathOption = parser.add(positional: "path", kind: String.self, usage: "Path to .swift file")
let dryrunOption = parser.add(option: "--dryrun", shortName: "-d", kind: Bool.self, usage: "Dryrun mode is simply display rewrited code")
let dumpOption = parser.add(option: "--dump", kind: Bool.self, usage: "Dump syntax tree")
let targetNameOption = parser.add(option: "--target", kind: String.self, usage: "Before replacing variable name. e.g. strongSelf")
let rewriteNameOption = parser.add(option: "--rewrite", kind: String.self, usage: "After replacing variable name. e.g. self")

do {
    let args = try parser.parse(Array(CommandLine.arguments.dropFirst()))
    guard let path = args.get(pathOption) else {
        fatalError()
    }
    let fm = FileManager.default
    guard fm.fileExists(atPath: path) else {
        print("file does not exist: \(path)")
        exit(1)
    }
    let url = URL(fileURLWithPath: path)
    let target = args.get(targetNameOption) ?? "strongSelf"
    let rewrite = args.get(rewriteNameOption) ?? "self"
    let rewriter = StrongSelfRewriter(url: url, targetName: target, rewriteName: rewrite)
    
    let dryrun = args.get(dryrunOption) ?? false
    let dump = args.get(dumpOption) ?? false
    rewriter.rewrite(dryrun: dryrun, dump: dump)
    
} catch {
    parser.printUsage(on: stdoutStream)
}
