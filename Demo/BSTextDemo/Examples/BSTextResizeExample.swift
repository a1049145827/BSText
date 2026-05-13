//
//  BSTextResizeExample.swift
//  BSTextDemo
//
//  Drag resize example like YYText
//

import UIKit
import BSText

class BSTextResizeExample: UIViewController {
    
    private let textView = BSTextView()
    private let resizeHandle = UIView()
    private let placeholderLabel = UILabel()
    
    private var minHeight: CGFloat = 44
    private var maxHeight: CGFloat = 200
    private var currentHeight: CGFloat = 44
    
    private var startY: CGFloat = 0
    private var startTextViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupTextView()
        setupResizeHandle()
        setupPlaceholder()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextView() {
        textView.frame = CGRect(
            x: 16,
            y: view.center.y - 100,
            width: view.width - 32,
            height: minHeight
        )
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 32, right: 12)
        textView.returnKeyType = .done
        textView.delegate = self
        textView.text = ""
        view.addSubview(textView)
        
        currentHeight = minHeight
    }
    
    private func setupResizeHandle() {
        resizeHandle.frame = CGRect(
            x: textView.center.x - 15,
            y: textView.bottom - 10,
            width: 30,
            height: 6
        )
        resizeHandle.backgroundColor = .systemGray4
        resizeHandle.layer.cornerRadius = 3
        resizeHandle.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        resizeHandle.addGestureRecognizer(panGesture)
        
        view.addSubview(resizeHandle)
    }
    
    private func setupPlaceholder() {
        placeholderLabel.text = "输入文字，拖拽底部调整大小..."
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.frame = CGRect(
            x: textView.left + 12,
            y: textView.top + 12,
            width: textView.width - 24,
            height: 20
        )
        view.addSubview(placeholderLabel)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            startY = gesture.location(in: view).y
            startTextViewHeight = textView.height
            
        case .changed:
            let deltaY = gesture.location(in: view).y - startY
            var newHeight = startTextViewHeight + deltaY
            
            newHeight = max(minHeight, min(newHeight, maxHeight))
            
            textView.height = newHeight
            resizeHandle.center = CGPoint(
                x: textView.center.x,
                y: textView.bottom - 3
            )
            
            currentHeight = newHeight
            
        case .ended, .cancelled:
            let finalHeight = textView.sizeThatFits(CGSize(width: textView.width, height: CGFloat.greatestFiniteMagnitude)).height
            let clampedHeight = max(minHeight, min(finalHeight, maxHeight))
            
            UIView.animate(withDuration: 0.2) {
                self.textView.height = clampedHeight
                self.resizeHandle.center = CGPoint(
                    x: self.textView.center.x,
                    y: self.textView.bottom - 3
                )
            }
            
            currentHeight = clampedHeight
            
        default:
            break
        }
    }
    
    @objc private func handleTap() {
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
    }
}

extension BSTextResizeExample: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        let contentSize = textView.sizeThatFits(CGSize(width: textView.width, height: CGFloat.greatestFiniteMagnitude))
        let targetHeight = max(minHeight, min(contentSize.height, maxHeight))
        
        if abs(targetHeight - textView.height) > 1 {
            UIView.animate(withDuration: 0.2) {
                self.textView.height = targetHeight
                self.resizeHandle.center = CGPoint(
                    x: self.textView.center.x,
                    y: self.textView.bottom - 3
                )
            }
            currentHeight = targetHeight
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
