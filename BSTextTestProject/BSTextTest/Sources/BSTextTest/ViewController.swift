//
//  ViewController.swift
//  BSTextTest
//
//  BSText 3.0 测试视图控制器
//

import UIKit
import BSText

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        setupToolbar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    private func setupTextView() {
        // 创建工具栏高度
        let toolbarHeight: CGFloat = 60
        let safeTop = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        
        // 创建 BSTextView
        let textView = BSTextView(frame: CGRect(
            x: 0,
            y: safeTop + toolbarHeight,
            width: view.bounds.width,
            height: view.bounds.height - safeTop - safeBottom - toolbarHeight
        ))
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.keyboardDismissMode = .interactive
        textView.viewportLayoutEnabled = true
        textView.debugOptions = []
        textView.backgroundColor = .systemBackground
        
        // 设置测试文本
        let testText = """
        BSText 3.0 测试

        这是一个测试！
        使用新的 TextKit 2 实现的 BSText。

        主要特性：
        • 基于 UITextView 继承，完全兼容系统行为
        • IME 输入安全机制
        • Viewport 布局优化
        • Fragment 缓存和复用
        """
        
        let attributedText = NSMutableAttributedString(string: testText)
        let titleRange = (testText as NSString).range(of: "BSText 3.0 测试")
        attributedText.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.systemBlue
        ], range: titleRange)
        
        textView.attributedText = attributedText
        textView.font = .systemFont(ofSize: 17)
        
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        
        // 滚动到底部
        textView.selectedRange = NSRange(location: attributedText.length - 1, length: 0)
    }
    
    private func setupToolbar() {
        let toolbarHeight: CGFloat = 60
        let safeTop = view.safeAreaInsets.top
        
        let toolbar = UIView(frame: CGRect(
            x: 0,
            y: safeTop,
            width: view.bounds.width,
            height: toolbarHeight
        ))
        toolbar.backgroundColor = .systemGray6
        toolbar.autoresizingMask = [.flexibleWidth]
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "BSText 3.0 测试"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(
            x: toolbar.bounds.width / 2,
            y: toolbar.bounds.height / 2
        )
        toolbar.addSubview(titleLabel)
        
        view.addSubview(toolbar)
    }
}
