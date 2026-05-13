//
//  BSText3EditExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2026/05/13.
//  Copyright © 2026 GeekBruce. All rights reserved.
//
//  BSText 3.0 测试示例 - 使用新的 TextKit 2 实现
//

import UIKit

/// 测试 BSText 3.0 新功能的示例视图控制器
class BSText3EditExample: UIViewController {
    
    /// 新的 BSText 3.0 视图
    private var textView = BSTextView()
    
    /// 调试开关
    private var debugSwitch = UISwitch()
    
    /// 显示 fragment 数量的标签
    private var fragmentCountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "BSText 3.0 编辑示例"
        
        // 创建顶部工具栏
        setupToolbar()
        
        // 配置 textView
        setupTextView()
        
        // 设置测试内容
        setupTestContent()
        
        // 自动显示键盘
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.textView.becomeFirstResponder()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 更新 textView 大小
        let toolbarHeight: CGFloat = 50
        let topInset = view.safeAreaInsets.top + toolbarHeight
        let bottomInset = view.safeAreaInsets.bottom
        
        textView.frame = CGRect(
            x: 0,
            y: topInset,
            width: view.bounds.width,
            height: view.bounds.height - topInset - bottomInset
        )
    }
    
    // MARK: - Setup
    
    private func setupToolbar() {
        let toolbar = UIView()
        toolbar.backgroundColor = .systemBackground
        toolbar.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.bounds.width,
            height: 50
        )
        view.addSubview(toolbar)
        
        // 调试开关
        let debugLabel = UILabel()
        debugLabel.text = "调试:"
        debugLabel.font = .systemFont(ofSize: 14)
        debugLabel.sizeToFit()
        debugLabel.frame.origin = CGPoint(x: 15, y: (toolbar.bounds.height - debugLabel.bounds.height) / 2)
        toolbar.addSubview(debugLabel)
        
        debugSwitch.sizeToFit()
        debugSwitch.isOn = false
        debugSwitch.center = CGPoint(
            x: debugLabel.frame.maxX + 10 + debugSwitch.bounds.width / 2,
            y: toolbar.bounds.height / 2
        )
        debugSwitch.addTarget(self, action: #selector(debugSwitchToggled), for: .valueChanged)
        toolbar.addSubview(debugSwitch)
        
        // Fragment 数量标签
        fragmentCountLabel.font = .systemFont(ofSize: 12)
        fragmentCountLabel.textColor = .systemGray
        fragmentCountLabel.text = "Fragments: 0"
        fragmentCountLabel.sizeToFit()
        fragmentCountLabel.frame.origin = CGPoint(
            x: toolbar.bounds.width - fragmentCountLabel.bounds.width - 15,
            y: (toolbar.bounds.height - fragmentCountLabel.bounds.height) / 2
        )
        toolbar.addSubview(fragmentCountLabel)
    }
    
    private func setupTextView() {
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.keyboardDismissMode = .interactive
        
        // 启用 viewport 布局
        textView.viewportLayoutEnabled = true
        
        view.addSubview(textView)
    }
    
    private func setupTestContent() {
        let testText = """
        BSText 3.0 测试

        这是一个使用新的 TextKit 2 实现的测试。BSText 3.0 的主要特性包括：

        • 基于 UITextView 和 TextKit 2 的架构
        • Viewport 布局优化，处理大文档时性能更好
        • Fragment 缓存和复用
        • 增量编辑和语法高亮支持
        • IME 输入安全机制

        现在你可以开始编辑这段文本，测试以下功能：
        1. 输入普通文本
        2. 选择和编辑
        3. 滚动查看效果
        4. 测试不同语言的输入（包括中文）

        下面是更多的测试文本，用来测试 Viewport 布局：

        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

        中文测试：这是一段长文本，用来测试在中文环境下的编辑效果。你可以尝试输入中文字符，测试输入法的兼容性。还可以选择、复制、粘贴文本，检查功能是否正常工作。

        更多的测试内容...
        """
        
        let attributedText = NSMutableAttributedString(string: testText)
        
        // 添加一些基本的属性
        let titleRange = (testText as NSString).range(of: "BSText 3.0 测试")
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: titleRange)
        
        // 设置文本
        textView.attributedText = attributedText
        
        // 滚动到底部
        let endLocation = attributedText.length
        textView.selectedRange = NSRange(location: endLocation, length: 0)
    }
    
    // MARK: - Actions
    
    @objc private func debugSwitchToggled() {
        if debugSwitch.isOn {
            textView.debugOptions.insert(.showFragments)
        } else {
            textView.debugOptions.remove(.showFragments)
        }
        textView.setNeedsDisplay()
        updateFragmentCount()
    }
    
    private func updateFragmentCount() {
        let count = textView.visibleFragmentCount
        fragmentCountLabel.text = "Fragments: \(count)"
        fragmentCountLabel.sizeToFit()
        fragmentCountLabel.frame.origin.x = view.bounds.width - fragmentCountLabel.bounds.width - 15
    }
}

