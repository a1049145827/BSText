import SwiftUI
import UIKit
import BSText

@available(iOS 13.0, *)
public struct BSTextViewWrapper: UIViewRepresentable {
    
    private let attributedText: NSAttributedString?
    private let text: String?
    private let font: UIFont?
    private let textColor: UIColor?
    private let textAlignment: NSTextAlignment
    
    public init(
        attributedText: NSAttributedString? = nil,
        text: String? = nil,
        font: UIFont? = nil,
        textColor: UIColor? = nil,
        textAlignment: NSTextAlignment = .left
    ) {
        self.attributedText = attributedText
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
    }
    
    public func makeUIView(context: Context) -> BSText.BSTextView {
        let textView = BSText.BSTextView()
        configureTextView(textView)
        return textView
    }
    
    public func updateUIView(_ uiView: BSText.BSTextView, context: Context) {
        configureTextView(uiView)
    }
    
    private func configureTextView(_ textView: BSText.BSTextView) {
        if let attributedText = attributedText {
            textView.attributedText = attributedText
        } else if let text = text {
            textView.text = text
        }
        
        if let font = font {
            textView.font = font
        }
        
        if let textColor = textColor {
            textView.textColor = textColor
        }
        
        textView.textAlignment = textAlignment
    }
}

@available(iOS 13.0, *)
extension BSTextViewWrapper {
    public func font(_ font: UIFont) -> BSTextViewWrapper {
        BSTextViewWrapper(
            attributedText: self.attributedText,
            text: self.text,
            font: font,
            textColor: self.textColor,
            textAlignment: self.textAlignment
        )
    }
    
    public func textColor(_ color: UIColor) -> BSTextViewWrapper {
        BSTextViewWrapper(
            attributedText: self.attributedText,
            text: self.text,
            font: self.font,
            textColor: color,
            textAlignment: self.textAlignment
        )
    }
    
    public func textAlignment(_ alignment: NSTextAlignment) -> BSTextViewWrapper {
        BSTextViewWrapper(
            attributedText: self.attributedText,
            text: self.text,
            font: self.font,
            textColor: self.textColor,
            textAlignment: alignment
        )
    }
}