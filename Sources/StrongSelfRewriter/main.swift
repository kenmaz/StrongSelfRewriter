import Foundation
import StrongSelfRewriterCore
import Utility
import Basic

let parser = ArgumentParser(commandName: "StrongSelfRewriter", usage: "<path>", overview: "Replace optional self binding variable name to \"self\" or specified name by --rewrite option")
let pathOption = parser.add(positional: "path", kind: String.self, usage: "Path to .swift file")
let dryrunOption = parser.add(option: "--dryrun", shortName: "-d", kind: Bool.self, usage: "Display rewrited code simply")
let dumpOption = parser.add(option: "--dump", kind: Bool.self, usage: "Dump syntax tree")
let rewriteNameOption = parser.add(option: "--rewrite", kind: String.self, usage: "Variable name for using replacement. Default is self")

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
    let rewrite = args.get(rewriteNameOption) ?? "self"
    let rewriter = StrongSelfRewriter(url: url, rewriteName: rewrite)
    
    let dryrun = args.get(dryrunOption) ?? false
    let dump = args.get(dumpOption) ?? false
    rewriter.rewrite(dryrun: dryrun, dump: dump)
    
} catch {
    parser.printUsage(on: stdoutStream)
}
