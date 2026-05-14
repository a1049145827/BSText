# BSText 异步渲染可行性分析

## 当前架构分析

### 核心限制

| 组件 | 主线程要求 | 原因 |
|------|-----------|------|
| `UITextView` | ✅ 必须在主线程 | UIKit 视图层级 |
| `NSTextLayoutManager` | ✅ 必须在主线程 | TextKit 2 布局 API |
| `NSTextContentStorage` | ✅ 必须在主线程 | 文本内容管理 |

## 无法做到完全异步化的原因

### 1. TextKit 2 架构限制
- TextKit 2 是 Apple 系统 API，**不支持后台线程布局**
- `NSTextLayoutManager` 的 `ensureLayout(for:)` 只能在主线程调用
- `UITextView` 是 `UIView` 子类，**所有布局和绘制必须在主线程**

### 2. IME 输入依赖
- 当前项目的核心原则：**系统处理 IME**
- 如果完全异步化，IME 会失去同步，导致输入混乱

## 可以做到的优化（已经部分实现）

### 1. 装饰器异步计算（已实现）
```swift
// BSTextAsyncRenderer 已经实现
BSTextAsyncRenderer.renderAsync(
    textStorage: textStorage,
    ranges: textRanges
) { decorations in
    // 只在主线程应用结果
}
```

### 2. 视口优化（已实现）
```swift
// BSTextViewportController 只布局可见区域
viewportController.enabled = true  // 只布局屏幕显示的文本
```

### 3. 增量无效化（已实现）
```swift
// BSTextIncrementalInvalidation 只更新变化的部分
invalidation.invalidate(range: changedRange)
```

## 如果真要完全异步化（类似 YYText），需要怎么做？

### 方案 1：完全脱离 TextKit，自绘引擎
```
✅ 完全异步布局 + 后台绘制
❌ 失去 IME 支持（需要自己实现 IME，非常难）
❌ 失去系统选择、光标等功能
❌ 开发成本极高
```

### 方案 2：混合方案（推荐）
```
✅ 系统处理 IME、输入、光标（主线程）
✅ 装饰器计算、语法高亮（后台线程）
✅ 视口优化 + 增量无效化（减少主线程工作量）
❌ 不能完全异步，但性能足够好
```

## 结论

基于当前 BSText 框架：

| 问题 | 答案 |
|------|------|
| **能做到完全异步化吗？** | ❌ **不能**，受限于 TextKit 2 和 UIKit |
| **能做到部分异步优化吗？** | ✅ **可以**，装饰器、语法高亮已支持后台计算 |
| **推荐方案** | **保持现状**，已有的视口优化 + 增量更新已足够好 |

如果需要 YYText 级别的完全异步渲染，需要重写整个文本引擎，放弃系统的 IME 支持（开发成本极高）。

当前的混合方案是最佳平衡点：**利用系统处理 IME，BSText 处理高性能装饰**。

## 相关文件

- `BSText/Sources/Async/BSTextAsyncRenderer.swift` - 异步装饰器渲染
- `BSText/Sources/Core/BSTextViewportController.swift` - 视口优化
- `BSText/Sources/Async/BSTextIncrementalInvalidation.swift` - 增量无效化
- `DemoApp/AsyncDemoViewController.swift` - 异步渲染 Demo
