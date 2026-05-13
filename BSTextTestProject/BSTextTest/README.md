# BSText 3.0 测试项目

此目录包含 BSText 3.0 的测试项目源文件。

## 使用方法

由于我们的项目是使用 Swift Package Manager (SPM) 的，最简便的方式是：

### 方式 1: 在 Xcode 中创建新项目并添加依赖（推荐）

1. **打开 Xcode，创建一个新的 iOS App 项目**
   - File -> New -> Project
   - 选择 "iOS App"
   - 产品名称填 "BSTextTest"
   - 语言选择 "Swift"
   - 界面选择 "Storyboard" 或 "SwiftUI"（用 Storyboard 可以直接用我们的 ViewController）
   - 生命周期选择 "UIKit App Delegate"

2. **将我们的源文件复制到你的新项目**
   - 将本目录 `Sources/BSTextTest` 下的所有文件（`AppDelegate.swift`, `SceneDelegate.swift`, `ViewController.swift`）复制到你的新项目
   - 替换项目原有的同名文件

3. **添加 BSText 作为本地依赖**
   - 选中你的项目 -> Project -> Package Dependencies
   - 点击 "+" 按钮
   - 点击 "Add Local" 或输入本地路径
   - 选择 BSText 根目录（包含 Package.swift 的目录）
   - 点击 "Add Package"

4. **将 BSText 模块添加到目标**
   - 选中你的 target -> General -> Frameworks, Libraries, and Embedded Content
   - 点击 "+" 按钮
   - 选择 "BSText" 库

5. **运行项目！**
   - 选择一个模拟器
   - 按 Cmd+R 运行

### 方式 2: 直接在 Xcode 中打开 Package.swift

1. 在 Xcode 中打开根目录的 `Package.swift`
2. 这会在 Xcode 中打开包
3. 创建一个新的测试目标

### 测试文件说明

- **`AppDelegate.swift`**: 应用程序入口
- **`SceneDelegate.swift`**: 场景管理
- **`ViewController.swift`**: 主要的测试视图控制器，包含 BSTextView 的使用示例
- **`Info.plist`**: 应用程序配置

## 当前状态

✅ **库已编译完成 - Phase 1 基础重构成功！**

## Phase 1 完成的功能

- [x] `BSTextView` - 继承自 `UITextView` 的富文本视图
- [x] `BSTextContentStorage` - 内容管理和增量编辑
- [x] `BSTextViewportController` - 可见区域布局管理
- [x] `BSTextLayoutManager` - TextKit 2 布局管理
- [x] `BSTextFragment` - 文本片段管理
- [x] `BSTextCache` - 缓存系统
- [x] 项目可以成功编译

## 下一步

- Phase 2: 富文本功能开发（Attachment、Markdown、语法高亮）
