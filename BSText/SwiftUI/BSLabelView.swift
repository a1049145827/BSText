import SwiftUI
import UIKit
import BSText

@available(iOS 13.0, *)
public struct BSLabelView: UIViewRepresentable {
    
    private let attributedText: NSAttributedString?
    private let text: String?
    private let font: UIFont?
    private let textColor: UIColor?
    private let textAlignment: NSTextAlignment
    private let numberOfLines: Int
    private let lineBreakMode: NSLineBreakMode
    
    public init(
        attributedText: NSAttributedString? = nil,
        text: String? = nil,
        font: UIFont? = nil,
        textColor: UIColor? = nil,
        textAlignment: NSTextAlignment = .left,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) {
        self.attributedText = attributedText
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
    }
    
    public func makeUIView(context: Context) -> BSText.BSLabel {
        let label = BSText.BSLabel()
        configureLabel(label)
        return label
    }
    
    public func updateUIView(_ uiView: BSText.BSLabel, context: Context) {
        configureLabel(uiView)
    }
    
    private func configureLabel(_ label: BSText.BSLabel) {
        if let attributedText = attributedText {
            label.attributedText = attributedText
        } else if let text = text {
            label.text = text
        }
        
        if let font = font {
            label.font = font
        }
        
        if let textColor = textColor {
            label.textColor = textColor
        }
        
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
    }
}

@available(iOS 13.0, *)
extension BSLabelView {
    public func font(_ font: UIFont) -> BSLabelView {
        BSLabelView(
            attributedText: self.attributedText,
            text: self.text,
            font: font,
            textColor: self.textColor,
            textAlignment: self.textAlignment,
            numberOfLines: self.numberOfLines,
            lineBreakMode: self.lineBreakMode
        )
    }
    
    public func textColor(_ color: UIColor) -> BSLabelView {
        BSLabelView(
            attributedText: self.attributedText,
            text: self.text,
            font: self.font,
            textColor: color,
            textAlignment: self.textAlignment,
            numberOfLines: self.numberOfLines,
            lineBreakMode: self.lineBreakMode
        )
    }
    
    public func textAlignment(_ alignment: NSTextAlignment) -> BSLabelView {
        BSLabelView(
            attributedText: self.attributedText,
            text: self.text,
            font: self.font,
            textColor: self.textColor,
            textAlignment: alignment,
            numberOfLines: self.numberOfLines,
            lineBreakMode: self.lineBreakMode
        )
    }
    
    public func numberOfLines(_ lines: Int) -> BSLabelView {
        BSLabelView(
            attributedText: self.attributedText,
            text: self.text,
            font: self.font,
            textColor: self.textColor,
            textAlignment: self.textAlignment,
            numberOfLines: lines,
            lineBreakMode: self.lineBreakMode
        )
    }
}