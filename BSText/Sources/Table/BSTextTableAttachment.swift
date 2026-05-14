//
//  BSTextTableAttachment.swift
//  BSText 3.0
//
//  Table attachment for rendering Markdown tables.
//

import UIKit

/// Represents a table cell in a Markdown table.
@objcMembers
public class BSTextTableCell: NSObject {
    public let content: NSAttributedString
    public let alignment: NSTextAlignment
    
    public init(content: NSAttributedString, alignment: NSTextAlignment = .left) {
        self.content = content
        self.alignment = alignment
        super.init()
    }
}

/// Represents a table row in a Markdown table.
@objcMembers
public class BSTextTableRow: NSObject {
    public let cells: [BSTextTableCell]
    public let isHeader: Bool
    
    public init(cells: [BSTextTableCell], isHeader: Bool = false) {
        self.cells = cells
        self.isHeader = isHeader
        super.init()
    }
}

/// A text attachment for rendering tables in rich text.
@objcMembers
public class BSTextTableAttachment: BSTextAttachment {
    
    /// The table rows.
    public var rows: [BSTextTableRow] = []
    
    /// Column widths (automatic if not set).
    public var columnWidths: [CGFloat]?
    
    /// Table border color.
    public var borderColor: UIColor = .lightGray
    
    /// Table border width.
    public var borderWidth: CGFloat = 1.0
    
    /// Cell padding.
    public var cellPadding: CGFloat = 8.0
    
    /// Header background color.
    public var headerBackgroundColor: UIColor = .systemGray5
    
    public override init(type: BSTextAttachmentType) {
        super.init(type: type)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Creates a table attachment from Markdown table string.
    public static func tableAttachment(from markdown: String) -> BSTextTableAttachment {
        let attachment = BSTextTableAttachment(type: .image)
        let parser = BSTextTableParser()
        attachment.rows = parser.parse(markdown)
        attachment.updateDisplaySize()
        return attachment
    }
    
    /// Updates the display size based on content.
    public func updateDisplaySize() {
        let width = columnWidths?.reduce(0, +) ?? 300
        let rowHeight: CGFloat = 36
        let height = CGFloat(rows.count) * rowHeight + 2 * borderWidth
        displaySize = CGSize(width: width, height: height)
    }
    
    /// Renders the table to an image.
    public func renderTable() -> UIImage? {
        let width = displaySize.width
        let height = displaySize.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        let effectiveColumnWidths = columnWidths ?? calculateColumnWidths()
        
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(borderWidth)
        
        var y: CGFloat = borderWidth / 2
        
        for (rowIndex, row) in rows.enumerated() {
            // Draw header background
            if row.isHeader {
                context.setFillColor(headerBackgroundColor.cgColor)
                context.fill(CGRect(x: 0, y: y, width: width, height: rowHeight()))
            }
            
            var x: CGFloat = borderWidth / 2
            
            for (cellIndex, cell) in row.cells.enumerated() {
                let cellWidth = cellIndex < effectiveColumnWidths.count ? effectiveColumnWidths[cellIndex] : effectiveColumnWidths.last ?? 100
                
                // Draw cell content
                drawCellContent(cell, in: CGRect(x: x + cellPadding, y: y + cellPadding, width: cellWidth - cellPadding * 2, height: rowHeight() - cellPadding * 2), context: context)
                
                // Draw right border (except last cell)
                if cellIndex < row.cells.count - 1 {
                    let borderRect = CGRect(x: x + cellWidth - borderWidth / 2, y: y, width: borderWidth, height: rowHeight())
                    context.fill(borderRect)
                }
                
                x += cellWidth
            }
            
            // Draw bottom border (except last row)
            if rowIndex < rows.count - 1 {
                let borderRect = CGRect(x: 0, y: y + rowHeight() - borderWidth / 2, width: width, height: borderWidth)
                context.fill(borderRect)
            }
            
            y += rowHeight()
        }
        
        // Draw outer border
        context.fill(CGRect(x: 0, y: 0, width: width, height: borderWidth)) // top
        context.fill(CGRect(x: 0, y: height - borderWidth, width: width, height: borderWidth)) // bottom
        context.fill(CGRect(x: 0, y: 0, width: borderWidth, height: height)) // left
        context.fill(CGRect(x: width - borderWidth, y: 0, width: borderWidth, height: height)) // right
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func rowHeight() -> CGFloat {
        return 36
    }
    
    private func calculateColumnWidths() -> [CGFloat] {
        guard let firstRow = rows.first else { return [] }
        let totalWidth = displaySize.width - borderWidth * 2
        let columnCount = firstRow.cells.count
        return Array(repeating: totalWidth / CGFloat(columnCount), count: columnCount)
    }
    
    private func drawCellContent(_ cell: BSTextTableCell, in rect: CGRect, context: CGContext) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = cell.alignment
        
        let attributedString = NSMutableAttributedString(attributedString: cell.content)
        attributedString.addAttributes([
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 14)
        ], range: NSRange(location: 0, length: attributedString.length))
        
        attributedString.draw(in: rect)
    }
}

/// Parses Markdown table syntax into BSTextTableRow objects.
@objcMembers
public class BSTextTableParser: NSObject {
    
    public func parse(_ markdown: String) -> [BSTextTableRow] {
        let lines = markdown.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard lines.count >= 2 else { return [] }
        
        var rows: [BSTextTableRow] = []
        
        // Parse header row
        if let headerLine = lines.first {
            let headerCells = parseRow(headerLine)
            let headerRow = BSTextTableRow(cells: headerCells, isHeader: true)
            rows.append(headerRow)
        }
        
        // Skip separator line (second line)
        // Parse data rows
        for i in 2..<lines.count {
            let dataCells = parseRow(lines[i])
            let dataRow = BSTextTableRow(cells: dataCells, isHeader: false)
            rows.append(dataRow)
        }
        
        return rows
    }
    
    private func parseRow(_ line: String) -> [BSTextTableCell] {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("|") else { return [] }
        
        let parts = trimmed.components(separatedBy: "|").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        return parts.map { part in
            let trimmedPart = part.trimmingCharacters(in: .whitespaces)
            let alignment = detectAlignment(trimmedPart)
            let content = NSAttributedString(string: trimmedPart.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces))
            return BSTextTableCell(content: content, alignment: alignment)
        }
    }
    
    private func detectAlignment(_ cellContent: String) -> NSTextAlignment {
        let trimmed = cellContent.trimmingCharacters(in: .whitespaces)
        let hasLeftColon = trimmed.hasPrefix(":")
        let hasRightColon = trimmed.hasSuffix(":")
        
        if hasLeftColon && hasRightColon {
            return .center
        } else if hasRightColon {
            return .right
        } else if hasLeftColon {
            return .left
        }
        return .left
    }
}