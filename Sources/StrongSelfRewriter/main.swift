import StrongSelfRewriterCore

enum Mode: String {
    case dump
    case rewrite
}

let args = Array(CommandLine.arguments.dropFirst())
switch args.count {
case 1:
    if args[0] == "help" {
        print("help")
    } else {
        fatalError()
    }
case 2:
    guard let mode = Mode(rawValue: args[0]) else { fatalError() }
    let path = args[1]
    let rewriter = StrongSelfRewriter(path: path)
    
    switch mode {
    case .dump:
        rewriter.dump()
    case .rewrite:
        rewriter.rewrite(dryrun: true)
    }
default:
    fatalError()
}
