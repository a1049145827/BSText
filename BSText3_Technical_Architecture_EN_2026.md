# BSText 3 Technical Architecture (2026)

## Project Positioning

BSText 3 is no longer a traditional CoreText-based rich text framework.

It is:

> A modern rich text infrastructure framework for iOS built on top of TextKit 2.

Core philosophy:

- System manages input and interaction
- BSText manages rich text capabilities and performance enhancements
- Respect UIKit and TextKit 2
- Do not reimplement UITextInput
- Do not take over IME pipelines

---

# 1. Project Goals

## Core Features

### Rich Text Editing

- Rich text editing
- Markdown editing
- Code blocks
- Mentions / hashtags
- Inline attachments
- Async image rendering
- Syntax highlighting
- Tables / quotes / lists
- Block-based documents

---

### Performance Goals

- Editable 100k+ line documents
- 120 FPS scrolling
- Viewport-based incremental layout
- Fragment-level rendering
- Deferred attachment loading
- Low memory usage

---

### System Compatibility

Must support:

- Korean IME
- Japanese IME
- Chinese Pinyin IME
- Apple Scribble
- Voice Dictation
- Accessibility
- Apple Intelligence Writing Tools

---

# 2. Technical Direction

## Foundation Stack

```text
TextKit 2
+
Viewport Layout
+
Fragment Rendering
+
Incremental Editing
+
Async Decoration
```

---

## Deprecated Direction

```text
CoreText
+
Custom UITextInput
+
Full Async Text Engine
```

---

# 3. System Requirements

| Item | Requirement |
|---|---|
| Minimum iOS | iOS 16 |
| Recommended | iOS 17+ |
| Architecture | UIKit |
| Language | Swift Core + ObjC API |
| Text System | TextKit 2 |

---

# 4. Overall Architecture

```text
┌────────────────────────────┐
│        BSTextView          │
├────────────────────────────┤
│     Editing Layer          │
│  selection / input / IME   │
│   (System Managed)         │
├────────────────────────────┤
│     Rich Text Layer        │
│ markdown / syntax / attr   │
├────────────────────────────┤
│     Layout Layer           │
│ TextKit 2 Fragment Layout  │
├────────────────────────────┤
│     Rendering Layer        │
│ viewport / async draw      │
├────────────────────────────┤
│     Attachment Layer       │
│ image / video / custom     │
├────────────────────────────┤
│     Cache Layer            │
│ glyph / image / fragment   │
└────────────────────────────┘
```

---

# 5. Core Modules

## 5.1 BSTextView

Built on:

```swift
class BSTextView: UITextView
```

Responsibilities:

- Text input entry point
- Rich text editing
- Selection handling
- Rich interaction
- Viewport coordination

Principles:

- Do not implement custom UITextInput
- Do not override IME behavior
- Do not replace system selection handling

---

## 5.2 BSTextContentStorage

Built on:

```swift
NSTextContentStorage
```

Responsibilities:

- Attributed text storage
- Incremental editing
- Syntax invalidation
- Block model synchronization

---

## 5.3 BSTextLayoutManager

Built on:

```swift
NSTextLayoutManager
```

Responsibilities:

- Fragment layout
- Viewport layout
- Incremental invalidation
- Async decoration

---

## 5.4 BSTextFragment

Built on:

```swift
NSTextLayoutFragment
```

Goals:

- Fragment cache
- Async preparation
- Decoration rendering
- Viewport recycling

---

## 5.5 BSTextViewportController

Responsibilities:

- Visible fragment layout
- Prefetching
- Recycling
- Scrolling optimization

Conceptually similar to:

```text
UICollectionView for text rendering
```

---

## 5.6 Attachment System

Supported attachment types:

| Type | Support |
|---|---|
| Image | ✅ |
| Animated image | ✅ |
| Video | ✅ |
| UIKit view | ✅ |
| SwiftUI host | ✅ |
| Async component | ✅ |

Lifecycle:

```text
placeholder
↓
async load
↓
decode
↓
display
↓
cache
```

---

# 6. Input System Design

## Core Rule

When:

```swift
textView.markedTextRange != nil
```

Never:

- setAttributedText
- rebuild the entire document
- reset selection
- invalidate full layout

---

## Incremental Editing

Avoid:

```swift
storage.setAttributedString(...)
```

Use:

```swift
textStorage.beginEditing()
textStorage.addAttributes(...)
textStorage.endEditing()
```

---

# 7. Async Architecture

## Modern Async Strategy

### No longer:

```text
Entire text engine async
```

### Instead:

```text
Partial async rendering
```

---

## Async Allowed

| Module | Async |
|---|---|
| Syntax parsing | ✅ |
| Markdown parsing | ✅ |
| Image decoding | ✅ |
| Fragment preparation | ✅ |
| Decoration rendering | ✅ |
| Attachment loading | ✅ |

---

## Async Forbidden

| Module | Async |
|---|---|
| IME | ❌ |
| Selection | ❌ |
| markedText | ❌ |
| Text editing | ❌ |

---

# 8. Viewport Rendering

## Core Principle

Only layout:

```text
Visible fragments
```

Supports:

- Pre-rendering
- Fragment caching
- Viewport prefetching
- Incremental layout

---

## Rendering Pipeline

```text
text edit
↓
fragment invalidation
↓
background prepare
↓
main-thread commit
↓
display
```

---

# 9. Markdown Architecture

## Pipeline

```text
Markdown
↓
AST
↓
Block Model
↓
Attributed String
↓
Fragment Layout
```

---

## Block Model

```text
Document
 ├── Paragraph
 ├── Heading
 ├── Quote
 ├── CodeBlock
 ├── Table
 └── List
```

---

# 10. Syntax Highlighting

## Goals

- Incremental highlighting
- Large document stability
- Code editor support

---

## Avoid

```text
Full-document regex scanning
```

---

## Recommended

```text
Line-based incremental parsing
```

---

# 11. Caching System

## Fragment Cache

Caches:

- Glyph layouts
- Rendered decorations
- Attachment metrics

---

## Image Cache

Supports:

- Memory cache
- Disk cache
- Decoded cache

---

# 12. Swift and Objective-C API Strategy

## Core Implementation

Use:

```text
Swift Core
```

---

## Public APIs

Support:

```text
Swift + Objective-C
```

---

## Architecture

```text
Swift Core
    ↓
ObjC Bridge Layer
    ↓
Public ObjC API
```

---

## API Principles

### Swift

Modern APIs:

```swift
textView.insertAttachment(image)
```

---

### Objective-C

Traditional Cocoa APIs:

```objective-c
[textView insertAttachment:image];
```

---

## Avoid

```text
Separate Swift implementation
Separate ObjC implementation
```

Instead:

```text
One core
Two API layers
```

---

# 13. Directory Structure

```text
BSText/
├── Sources/
│   ├── Core/
│   ├── Layout/
│   ├── Rendering/
│   ├── Attachment/
│   ├── Markdown/
│   ├── Syntax/
│   ├── Cache/
│   ├── Async/
│   ├── ObjCBridge/
│   └── Utils/
│
├── Public/
│   ├── Swift/
│   └── ObjC/
│
├── Demo/
├── Benchmarks/
└── Tests/
```

---

# 14. Development Roadmap

# Phase 1 — Foundation Rebuild

Duration:

```text
4–8 weeks
```

Tasks:

- BSTextView
- TextKit 2 pipeline
- Viewport layout
- Basic editing
- Selection compatibility
- IME compatibility

---

# Phase 2 — Rich Text Features

Duration:

```text
4 weeks
```

Tasks:

- Attachment system
- Markdown parser
- Syntax highlighting
- Mention system
- Async image rendering

---

# Phase 3 — Performance Layer

Duration:

```text
4 weeks
```

Tasks:

- Fragment cache
- Async decoration
- Incremental invalidation
- Large document optimization

---

# Phase 4 — Advanced Editor Features

Duration:

```text
4–8 weeks
```

Tasks:

- Code editor mode
- Folding
- Table support
- Search indexing
- Block editor

---

# Phase 5 — Production Hardening

Continuous:

- Benchmarks
- CI
- Snapshot tests
- Accessibility
- Memory optimization
- Instruments profiling

---

# 15. Technical Pitfalls to Avoid

## Do not:

### Implement custom UITextInput

Reason:

```text
IME compatibility hell
```

---

### Rebuild entire attributed strings

Always use incremental editing.

---

### Use CoreText to replace the system text engine

TextKit 2 is the future.

---

### Call setNeedsDisplay on entire documents

Use:

```text
Fragment invalidation
```

---

# 16. Recommended Open Source References

Recommended projects:

- STTextView
- CodeEdit
- Nova Editor
- Zed Editor

Key concepts to study:

```text
viewport + fragment + incremental rendering
```

---

# 17. Distribution Strategy

## Recommended Support

| Technology | Support |
|---|---|
| Swift Package Manager | ✅ |
| CocoaPods | ✅ |
| XCFramework | ✅ |

---

# 18. Final Positioning

BSText 3 should position itself as:

> A TextKit 2 Enhancement Framework

Not:

> A Custom Text Engine

---

# 19. Future Expansion

Potential future directions:

- AI Writing
- Inline Completion
- Collaborative Editing
- CRDT
- Streaming Markdown
- Notion-style Block Editor
- Code Editor

---

# 20. Final Conclusion

The correct direction for BSText 3:

```text
System Text Engine
+
Incremental Layout
+
Viewport Rendering
+
Fragment Rendering
+
Async Decoration
+
IME Compatibility
```

Core philosophy:

```text
Enhance the system
instead of replacing the system
```
