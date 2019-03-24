//
//  Sample.swift
//  StrongSelfRewriter
//
//  Created by kenmaz on 2019/03/23.
//

import Foundation

class Sample {
    
    func execute(completion: () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.output(text: "hello")
            print(strongSelf)
        }
    }
    
    func execute2(completion: () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else {
                return
            }
            this.output(text: "hello")
            print(this)
        }
    }
    
    //TODO: support this pattern
//    func execute3(completion: () -> Void) {
//        DispatchQueue.main.async { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.output(text: "hello")
//            print(self)
//        }
//    }

    private func output(text: String) {
        print(text)
    }
}
