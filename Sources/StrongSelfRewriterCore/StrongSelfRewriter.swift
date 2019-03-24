//
//  StrongSelfRewriter.swift
//  Created by kenmaz on 2019/03/23.
//

import Foundation
import SwiftSyntax

public class StrongSelfRewriter: SyntaxRewriter {
    
    public func rewrite(dryrun: Bool = false, dump: Bool = false) {
        do {
            let src = try SyntaxTreeParser.parse(url)
            if dump {
                Swift.dump(src)
            }
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
    let rewriteName: String
    
    public init(url: URL, rewriteName: String = "self") {
        self.url = url
        self.rewriteName = rewriteName
        super.init()
    }

    public override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        let rewriter = SelfRenameRewriter(rewriteName: rewriteName)
        let retNode = rewriter.visit(node)
        if let targetName = rewriter.targetName {
            let res = SelfRefRewriter(targetName: targetName, rewriteName: rewriteName).visit(retNode)
            return res as! ExprSyntax
        } else {
            return node
        }
    }
}

class SelfRenameRewriter: SyntaxRewriter {
    var targetName: String? = nil

    let rewriteName: String
    init(rewriteName: String) {
        self.rewriteName = rewriteName
    }

    // guard let xxx = yyy else { .. }
    override public func visit(_ node: GuardStmtSyntax) -> StmtSyntax {
        let conds = node.conditions
        for (i, cond) in conds.enumerated() {
            guard
                let syntax = cond.condition as? OptionalBindingConditionSyntax,     // let xxx = yyy
                let rightVal = syntax.initializer.value as? IdentifierExprSyntax,   // yyy
                rightVal.identifier.text == "self",                                 // yyy == "self"
                let leftVal = syntax.pattern as? IdentifierPatternSyntax else {     // xxx
                    return node
            }
            targetName = leftVal.identifier.text
            
            let identifier = leftVal.identifier
            let newKind = TokenKind.identifier(rewriteName)
            let newIdentifier = identifier.withKind(newKind)
            let newPattern = leftVal.withIdentifier(newIdentifier)
            let newSyntax = syntax.withPattern(newPattern)
            let newCond = cond.withCondition(newSyntax)
            let newConds = conds.replacing(childAt: i, with: newCond)
            let newNode = node.withConditions(newConds)
            return newNode
        }
        return node
    }
}

class SelfRefRewriter: SyntaxRewriter {
    let targetName: String
    let rewriteName: String
    init(targetName: String, rewriteName: String) {
        self.targetName = targetName
        self.rewriteName = rewriteName
    }

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

