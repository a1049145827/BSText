import UIKit

public protocol BSTextAsyncRenderDelegate: AnyObject {
    func renderer(_ renderer: BSTextAsyncRenderer, didRender decorations: [BSTextFragmentDecoration], forFragmentAt index: Int)
    func renderer(_ renderer: BSTextAsyncRenderer, didCompleteRendering allDecorations: [BSTextFragmentDecoration])
}

@objcMembers
open class BSTextAsyncRenderer: NSObject {
    
    public weak var delegate: BSTextAsyncRenderDelegate?
    
    public var maxConcurrentTasks: Int = 4
    
    private let serialQueue = DispatchQueue(label: "com.bstext.async-renderer.serial")
    private let concurrentQueue: DispatchQueue
    private var tasks: [Task<Void, Never>] = []
    private var isCancelled = false
    
    public override init() {
        self.concurrentQueue = DispatchQueue(
            label: "com.bstext.async-renderer.concurrent",
            attributes: .concurrent
        )
        super.init()
    }
    
    public func renderDecorations(for textStorage: NSTextStorage, ranges: [NSRange]) {
        cancelAllTasks()
        isCancelled = false
        
        let text = textStorage.string as NSString
        
        for (index, range) in ranges.enumerated() {
            guard !isCancelled else { return }
            
            let task = Task.detached(priority: .userInitiated) { [weak self] in
                guard let self = self, !self.isCancelled else { return }
                
                let decorations = self.computeDecorations(for: text, range: range)
                
                DispatchQueue.main.async {
                    guard !self.isCancelled else { return }
                    if let delegate = self.delegate {
                        delegate.renderer(self, didRender: decorations, forFragmentAt: index)
                    }
                }
            }
            
            tasks.append(task)
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            
            await withTaskGroup(of: Void.self) { group in
                for task in self.tasks {
                    group.addTask { await task.value }
                }
            }
            
            DispatchQueue.main.async {
                if let delegate = self.delegate {
                    delegate.renderer(self, didCompleteRendering: [])
                }
            }
            
            self.tasks.removeAll()
        }
    }
    
    private func computeDecorations(for text: NSString, range: NSRange) -> [BSTextFragmentDecoration] {
        var decorations: [BSTextFragmentDecoration] = []
        
        let substring = text.substring(with: range) as String
        
        if substring.contains("@") {
            let mentionPattern = "@(\\w+)"
            do {
                let regex = try NSRegularExpression(pattern: mentionPattern, options: [])
                let matches = regex.matches(in: substring, options: [], range: NSRange(location: 0, length: substring.count))
                
                for match in matches {
                    let localRange = match.range
                    let absoluteRange = NSRange(
                        location: range.location + localRange.location,
                        length: localRange.length
                    )
                    
                    let decoration = BSTextFragmentDecoration(
                        range: absoluteRange,
                        type: .highlight,
                        color: UIColor.systemBlue,
                        backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
                        isUnderline: false,
                        baselineOffset: 0,
                        font: nil
                    )
                    decorations.append(decoration)
                }
            } catch {
                // Ignore regex errors
            }
        }
        
        if substring.contains("#") {
            let hashtagPattern = "#(\\w+)"
            do {
                let regex = try NSRegularExpression(pattern: hashtagPattern, options: [])
                let matches = regex.matches(in: substring, options: [], range: NSRange(location: 0, length: substring.count))
                
                for match in matches {
                    let localRange = match.range
                    let absoluteRange = NSRange(
                        location: range.location + localRange.location,
                        length: localRange.length
                    )
                    
                    let decoration = BSTextFragmentDecoration(
                        range: absoluteRange,
                        type: .highlight,
                        color: UIColor.systemBlue,
                        backgroundColor: nil,
                        isUnderline: true,
                        baselineOffset: 0,
                        font: nil
                    )
                    decorations.append(decoration)
                }
            } catch {
                // Ignore regex errors
            }
        }
        
        return decorations
    }
    
    public func cancelAllTasks() {
        isCancelled = true
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    deinit {
        cancelAllTasks()
    }
}

public extension BSTextAsyncRenderer {
    static func renderAsync(textStorage: NSTextStorage, ranges: [NSRange], completion: @escaping ([BSTextFragmentDecoration]) -> Void) {
        let renderer = BSTextAsyncRenderer()
        let handler = AsyncRenderCompletionHandler(completion: completion)
        renderer.delegate = handler
        renderer.renderDecorations(for: textStorage, ranges: ranges)
    }
}

private class AsyncRenderCompletionHandler: NSObject, BSTextAsyncRenderDelegate {
    private let completion: ([BSTextFragmentDecoration]) -> Void
    private var allDecorations: [BSTextFragmentDecoration] = []
    
    init(completion: @escaping ([BSTextFragmentDecoration]) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func renderer(_ renderer: BSTextAsyncRenderer, didRender decorations: [BSTextFragmentDecoration], forFragmentAt index: Int) {
        allDecorations.append(contentsOf: decorations)
    }
    
    func renderer(_ renderer: BSTextAsyncRenderer, didCompleteRendering allDecorations: [BSTextFragmentDecoration]) {
        completion(self.allDecorations)
    }
}
