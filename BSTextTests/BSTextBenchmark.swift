import Foundation
@testable import BSText

public struct BenchmarkResult {
    let name: String
    let iterations: Int
    let totalTime: TimeInterval
    let averageTime: TimeInterval
    let minTime: TimeInterval
    let maxTime: TimeInterval
}

public class BSTextBenchmark {
    
    public static let shared = BSTextBenchmark()
    
    private init() {}
    
    public func measure(name: String, iterations: Int = 100, block: () throws -> Void) rethrows -> BenchmarkResult {
        var times: [TimeInterval] = []
        times.reserveCapacity(iterations)
        
        for _ in 0..<iterations {
            let start = Date()
            try block()
            let end = Date()
            let time = end.timeIntervalSince(start)
            times.append(time)
        }
        
        let totalTime = times.reduce(0, +)
        let averageTime = totalTime / Double(iterations)
        let minTime = times.min() ?? 0
        let maxTime = times.max() ?? 0
        
        return BenchmarkResult(
            name: name,
            iterations: iterations,
            totalTime: totalTime,
            averageTime: averageTime,
            minTime: minTime,
            maxTime: maxTime
        )
    }
    
    public func printResult(_ result: BenchmarkResult) {
        print("""
        ===== Benchmark: \(result.name) =====
        Iterations: \(result.iterations)
        Total Time: \(String(format: "%.4f", result.totalTime))s
        Average Time: \(String(format: "%.6f", result.averageTime))s
        Min Time: \(String(format: "%.6f", result.minTime))s
        Max Time: \(String(format: "%.6f", result.maxTime))s
        """)
    }
}

public class BSTextMemoryMonitor {
    
    public static func getMemoryUsage() -> UInt64? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return nil
        }
        
        return info.resident_size
    }
    
    public static func formatMemory(_ bytes: UInt64) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0
        
        if gb >= 1 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1 {
            return String(format: "%.2f KB", kb)
        } else {
            return String(format: "%d bytes", bytes)
        }
    }
    
    public static func measureMemory(name: String, block: () throws -> Void) rethrows {
        let before = getMemoryUsage() ?? 0
        print("Before \(name): \(formatMemory(before))")
        
        try block()
        
        let after = getMemoryUsage() ?? 0
        print("After \(name): \(formatMemory(after))")
        
        let diff = Int64(after) - Int64(before)
        if diff > 0 {
            print("Memory increase: +\(formatMemory(UInt64(diff)))")
        } else if diff < 0 {
            print("Memory decrease: \(formatMemory(UInt64(abs(diff))))")
        } else {
            print("No memory change")
        }
    }
}

public class BSTextProfilingHelper {
    
    public static func profileTextViewPerformance() {
        print("\n===== BSText Performance Benchmarks =====\n")
        
        let benchmark = BSTextBenchmark.shared
        
        let textViewResult = benchmark.measure(name: "BSTextView Initialization", iterations: 1000) {
            _ = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        }
        benchmark.printResult(textViewResult)
        
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        let largeText = (0..<1000).map { "Line \($0): Test content\n" }.joined()
        
        let setTextResult = benchmark.measure(name: "BSTextView Set Text", iterations: 100) {
            textView.text = largeText
        }
        benchmark.printResult(setTextResult)
        
        let sizeThatFitsResult = benchmark.measure(name: "BSTextView Size That Fits", iterations: 100) {
            _ = textView.sizeThatFits(CGSize(width: 320, height: CGFloat.greatestFiniteMagnitude))
        }
        benchmark.printResult(sizeThatFitsResult)
    }
    
    public static func profileMarkdownPerformance() {
        print("\n===== Markdown Performance Benchmarks =====\n")
        
        let benchmark = BSTextBenchmark.shared
        let parser = BSTextMarkdownParser()
        
        let simpleMarkdown = "# Heading\n**Bold** *italic*\n- List item\n- Another item"
        let simpleResult = benchmark.measure(name: "Simple Markdown Parsing", iterations: 1000) {
            _ = parser.parse(simpleMarkdown)
        }
        benchmark.printResult(simpleResult)
        
        let largeMarkdown = (0..<100).map { 
            "# Heading \($0)\n**Bold** *italic* `code`\n- List item 1\n- List item 2\n\n" 
        }.joined()
        
        let largeResult = benchmark.measure(name: "Large Markdown Parsing", iterations: 100) {
            _ = parser.parse(largeMarkdown)
        }
        benchmark.printResult(largeResult)
    }
    
    public static func profileSyntaxPerformance() {
        print("\n===== Syntax Highlighting Performance Benchmarks =====\n")
        
        let benchmark = BSTextBenchmark.shared
        let parser = BSTextSyntaxParser()
        
        let simpleCode = """
        let x = 5
        func hello() {
            print("world")
        }
        """
        
        parser.language = .swift
        let simpleSwiftResult = benchmark.measure(name: "Simple Swift Syntax Highlighting", iterations: 1000) {
            _ = parser.parse(simpleCode)
        }
        benchmark.printResult(simpleSwiftResult)
        
        let largeCode = (0..<50).map {
            """
            func function\($0)(param: String) -> String {
                let result = "Result: \\(param)"
                return result
            }
            """
        }.joined(separator: "\n\n")
        
        let largeSwiftResult = benchmark.measure(name: "Large Swift Syntax Highlighting", iterations: 100) {
            _ = parser.parse(largeCode)
        }
        benchmark.printResult(largeSwiftResult)
    }
    
    public static func profileMemoryUsage() {
        print("\n===== Memory Usage Benchmarks =====\n")
        
        BSTextMemoryMonitor.measureMemory(name: "Create BSTextView") {
            _ = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        }
        
        BSTextMemoryMonitor.measureMemory(name: "Create Large Text Content") {
            let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
            textView.text = (0..<10000).map { "Line \($0)\n" }.joined()
        }
    }
}
