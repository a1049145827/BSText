import UIKit

public protocol BSTextSearchIndexerDelegate: AnyObject {
    func searchIndexer(_ indexer: BSTextSearchIndexer, didUpdateIndex progress: Double)
    func searchIndexer(_ indexer: BSTextSearchIndexer, didFindResults results: [BSTextSearchResult])
}

public struct BSTextSearchResult {
    public let range: NSRange
    public let lineNumber: Int
    public let context: String
    
    public init(range: NSRange, lineNumber: Int, context: String) {
        self.range = range
        self.lineNumber = lineNumber
        self.context = context
    }
}

@objcMembers
open class BSTextSearchIndexer: NSObject {
    
    public weak var delegate: BSTextSearchIndexerDelegate?
    
    private var indexedTerms: [String: [NSRange]] = [:]
    private var text: NSString = ""
    
    public func indexText(_ text: String) {
        self.text = text as NSString
        indexedTerms.removeAll()
        
        let words = extractWords(text)
        let total = words.count
        var processed = 0
        
        for word in words {
            let ranges = findAllOccurrences(of: word, in: text)
            if !ranges.isEmpty {
                indexedTerms[word] = ranges
            }
            processed += 1
            
            let progress = Double(processed) / Double(total)
            if let delegate = self.delegate {
                delegate.searchIndexer(self, didUpdateIndex: progress)
            }
        }
    }
    
    private func extractWords(_ text: String) -> Set<String> {
        let pattern = "\\w+"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            let words = matches.map {
                (text as NSString).substring(with: $0.range).lowercased()
            }
            return Set(words)
        } catch {
            return []
        }
    }
    
    private func findAllOccurrences(of term: String, in text: String) -> [NSRange] {
        var ranges: [NSRange] = []
        let lowerText = text.lowercased()
        let lowerTerm = term.lowercased()
        var searchStart = lowerText.startIndex
        
        while let range = lowerText.range(of: lowerTerm, range: searchStart..<lowerText.endIndex) {
            let nsRange = NSRange(range, in: text)
            ranges.append(nsRange)
            searchStart = range.upperBound
        }
        
        return ranges
    }
    
    public func search(_ query: String) -> [BSTextSearchResult] {
        let lowerQuery = query.lowercased()
        var results: [BSTextSearchResult] = []
        
        if let ranges = indexedTerms[lowerQuery] {
            for range in ranges {
                let lineNumber = lineNumberForLocation(range.location)
                let context = contextForRange(range)
                results.append(BSTextSearchResult(range: range, lineNumber: lineNumber, context: context))
            }
        } else {
            let allRanges = findAllOccurrences(of: query, in: text as String)
            for range in allRanges {
                let lineNumber = lineNumberForLocation(range.location)
                let context = contextForRange(range)
                results.append(BSTextSearchResult(range: range, lineNumber: lineNumber, context: context))
            }
        }
        
        if let delegate = self.delegate {
            delegate.searchIndexer(self, didFindResults: results)
        }
        
        return results
    }
    
    public func searchWithRegex(_ pattern: String) -> [BSTextSearchResult] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text as String, options: [], range: NSRange(location: 0, length: text.length))
            var results: [BSTextSearchResult] = []
            
            for match in matches {
                let range = match.range
                let lineNumber = lineNumberForLocation(range.location)
                let context = contextForRange(range)
                results.append(BSTextSearchResult(range: range, lineNumber: lineNumber, context: context))
            }
            
            if let delegate = self.delegate {
                delegate.searchIndexer(self, didFindResults: results)
            }
            return results
        } catch {
            return []
        }
    }
    
    private func lineNumberForLocation(_ location: Int) -> Int {
        let substring = text.substring(to: location)
        let lines = substring.components(separatedBy: .newlines)
        return lines.count
    }
    
    private func contextForRange(_ range: NSRange) -> String {
        let lineRange = text.lineRange(for: range)
        let lineText = text.substring(with: lineRange).trimmingCharacters(in: .whitespacesAndNewlines)
        return lineText
    }
    
    public func replaceAllOccurrences(of searchTerm: String, with replacement: String, in textStorage: NSTextStorage) -> Int {
        let ranges = findAllOccurrences(of: searchTerm, in: textStorage.string)
        let count = ranges.count
        
        textStorage.beginEditing()
        
        for range in ranges.reversed() {
            textStorage.replaceCharacters(in: range, with: replacement)
        }
        
        textStorage.endEditing()
        
        return count
    }
    
    public func clearIndex() {
        indexedTerms.removeAll()
        text = ""
    }
    
    public var indexedWordCount: Int {
        return indexedTerms.count
    }
    
    public var totalOccurrences: Int {
        return indexedTerms.values.reduce(0) { $0 + $1.count }
    }
}

public extension BSTextSearchIndexer {
    static func search(in text: String, query: String) -> [BSTextSearchResult] {
        let indexer = BSTextSearchIndexer()
        indexer.indexText(text)
        return indexer.search(query)
    }
}
