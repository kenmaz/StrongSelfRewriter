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
    
    private func output(text: String) {
        print(text)
    }
}
