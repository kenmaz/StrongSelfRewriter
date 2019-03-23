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
    
    public func rewrite() {
        do {
            let src = try SyntaxTreeParser.parse(url)
            let res = visit(src)
            try res.description.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }

    let url: URL
    
    public init(path: String) {
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else {
            fatalError("file not found: \(path)")
        }
        url = URL(fileURLWithPath: path)
        super.init()
    }

    override public func visit(_ node: GuardStmtSyntax) -> StmtSyntax {
        let conds = node.conditions
        guard let cond = conds.first else { return node }
        guard let syntax = cond.condition as? OptionalBindingConditionSyntax else { return node }
        guard let pattern = syntax.pattern as? IdentifierPatternSyntax else { return node }
        guard pattern.identifier.text == "strongSelf" else { return node }
        let identifier = pattern.identifier
        let newKind = TokenKind.identifier("self")
        let newIdentifier = identifier.withKind(newKind)
        let newPattern = pattern.withIdentifier(newIdentifier)
        let newSyntax = syntax.withPattern(newPattern)
        let newCond = cond.withCondition(newSyntax)
        let newConds = conds.replacing(childAt: 0, with: newCond)
        let newNode = node.withConditions(newConds)
        return newNode
    }
}

