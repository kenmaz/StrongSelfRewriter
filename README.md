# StrongSelfRewriter

## Usage
Input code
```
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
```
StrongSelfRewriter rewrite Sample.swift
```

Output result (diff)
```
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
```
git clone <repo>
cd <repo>
swift build
```
Debug run
```
.build/debug/StrongSelfRewriter rewrite Tests/StrongSelfRewriterTests/Sample.swift 
```
Generate Xcode project
```
swift package generate-xcodeproj
```
