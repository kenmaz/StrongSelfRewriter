//
//  StrongSelfRewriter.swift
//  Created by kenmaz on 2019/03/23.
//

import Foundation
import SwiftSyntax

public class StrongSelfRewriter: SyntaxRewriter {
    
    public func dump() {
        do {
            let src = try SyntaxTreeParser.parse(url)
            Swift.dump(src)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func rewrite(dryrun: Bool = false) {
        do {
            let src = try SyntaxTreeParser.parse(url)
            let res = visit(src)
            if dryrun {
                print(res.description)
            } else {
                try res.description.write(to: url, atomically: true, encoding: .utf8)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    let url: URL
    let targetName: String
    let rewriteName: String
    
    public init(path: String, targetName: String = "strongSelf", rewriteName: String = "self") {
        self.targetName = targetName
        self.rewriteName = rewriteName
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else {
            fatalError("file not found: \(path)")
        }
        url = URL(fileURLWithPath: path)
        super.init()
    }

    public override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        let rewriter = SelfRenameRewriter(targetName: targetName, rewriteName: rewriteName)
        let retNode = rewriter.visit(node)
        if rewriter.isRewrite {
            let res = SelfRefRewriter(targetName: targetName, rewriteName: rewriteName).visit(retNode)
            return res as! ExprSyntax
        } else {
            return node
        }
    }
}

class BaseRewriter: SyntaxRewriter {
    let targetName: String
    let rewriteName: String
    init(targetName: String, rewriteName: String) {
        self.targetName = targetName
        self.rewriteName = rewriteName
    }
}

class SelfRenameRewriter: BaseRewriter {
    var isRewrite: Bool = false
    
    // guard let xxx = yyy else { .. }
    override public func visit(_ node: GuardStmtSyntax) -> StmtSyntax {
        let conds = node.conditions
        for (i, cond) in conds.enumerated() {
            guard
                let syntax = cond.condition as? OptionalBindingConditionSyntax,     // let xxx = yyy
                let rightVal = syntax.initializer.value as? IdentifierExprSyntax,   // yyy
                rightVal.identifier.text == "self",                                 // yyy == "self"
                let leftVal = syntax.pattern as? IdentifierPatternSyntax,           // xxx
                leftVal.identifier.text == targetName else {                        // xxx == "<targetName>"
                    return node
            }
            let identifier = leftVal.identifier
            let newKind = TokenKind.identifier(rewriteName)
            let newIdentifier = identifier.withKind(newKind)
            let newPattern = leftVal.withIdentifier(newIdentifier)
            let newSyntax = syntax.withPattern(newPattern)
            let newCond = cond.withCondition(newSyntax)
            let newConds = conds.replacing(childAt: i, with: newCond)
            let newNode = node.withConditions(newConds)
            isRewrite = true
            return SelfRefRewriter(targetName: targetName, rewriteName: rewriteName).visit(newNode)
        }
        return node
    }
}

class SelfRefRewriter: BaseRewriter {
    override func visit(_ node: IdentifierExprSyntax) -> ExprSyntax {
        let identifier = node.identifier
        if identifier.text == targetName {
            let newIdentifier = identifier.withKind(TokenKind.identifier(rewriteName))
            return node.withIdentifier(newIdentifier)
        } else {
            return node
        }
    }
}

