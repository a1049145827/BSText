# BSText 3.0 测试指南

## 编译 BSText 库

### 方法 1: 使用 Xcode 打开 Package.swift

1. 在 Xcode 中打开 `Package.swift` 文件
2. Xcode 会自动识别为 iOS 库
3. 创建一个新的测试项目（iOS App）
4. 将 BSText 作为本地依赖添加

### 方法 2: 使用 Swift Package Manager 集成到现有项目

```swift
// 在项目的 Package.swift 文件
dependencies: [
    .package(path: "/path/to/BSText")
]
```

### 基本使用示例

```swift
import UIKit
import BSText

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建 BSTextView
        let textView = BSTextView(frame: view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 设置文本
        textView.text = "Hello, BSText 3.0!"
        
        // 启用调试显示
        textView.debugOptions = .showFragments
        
        // 添加到视图
        view.addSubview(textView)
    }
}
```

## 重要说明

由于旧的 CocoaPods Demo 工程（`Demo/BSTextDemo.xcworkspace` 正在寻找旧的 Objective-C 代码结构，已不支持我们已经使用 Swift 我们已经使用 Swift 重构了 BSText 库，请使用新的 Swift Package Manager 来测试。

## 编译状态：✅ 库代码已成功编译，Phase 1 基础重构完成。

## 测试我们的库：

1. 使用我们在 `Demo/BSTextDemo/Examples/BSText3EditExample.swift` 中有一个测试视图控制器，你可以将其复制到一个新的 iOS 项目中测试。
