# StrongSelfRewriter
StrongSelfRewriter is the tool to replace variable name for `guard let self = self` optional binding code using SwiftSyntax

## Usage
Input code
```swift
    func execute(completion: () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.output(text: "hello")
            print(strongSelf)
        }
    }
```

Run StrongSelfRewriter
```shell
StrongSelfRewriter rewrite Sample.swift
```

Output result (diff)
```diff
     func execute(completion: () -> Void) {
         DispatchQueue.main.async { [weak self] in
-            guard let strongSelf = self else {
+            guard let self = self else {
                 return
             }
-            strongSelf.output(text: "hello")
-            print(strongSelf)
+            self.output(text: "hello")
+            print(self)
         }
     }
```

## Build
```shell
git clone <repo>
cd <repo>
swift build
```
Debug run
```shell
.build/debug/StrongSelfRewriter rewrite Tests/StrongSelfRewriterTests/Sample.swift 
```
Generate Xcode project
```shell
swift package generate-xcodeproj
```
