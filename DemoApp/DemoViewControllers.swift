import UIKit
import BSText

class RichTextDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "Bold Text\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)]))
        attributedText.append(NSAttributedString(string: "Italic Text\n", attributes: [.font: UIFont.italicSystemFont(ofSize: 16)]))
        attributedText.append(NSAttributedString(string: "Colored Text\n", attributes: [.foregroundColor: UIColor.systemBlue]))
        attributedText.append(NSAttributedString(string: "Underlined Text", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]))
        textView.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}

class MarkdownDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 15)
        view.addSubview(textView)
        
        let markdown = """
# Heading Level 1

**Bold text** and *italic text* supported.

- List item 1
- List item 2
- List item 3

> Blockquote example

`Code snippet`

---

## Heading Level 2

[Link text](https://example.com)
"""
        let parser = BSTextMarkdownParser()
        textView.attributedText = parser.parse(markdown)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

class CodeEditorDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let codeEditor = BSTextCodeEditor()
        codeEditor.translatesAutoresizingMaskIntoConstraints = false
        codeEditor.layer.borderColor = UIColor.systemGray3.cgColor
        codeEditor.layer.borderWidth = 1
        codeEditor.layer.cornerRadius = 8
        codeEditor.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        codeEditor.language = .swift
        view.addSubview(codeEditor)
        
        let code = """
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Hello, BSText!"
        view.addSubview(label)
    }
}
"""
        codeEditor.text = code
        
        NSLayoutConstraint.activate([
            codeEditor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            codeEditor.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            codeEditor.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            codeEditor.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

class SyntaxHighlightDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        let languages = [("Swift", "swift", "let x = 5"),
                         ("Python", "python", "x = 5"),
                         ("JavaScript", "javascript", "const x = 5"),
                         ("JSON", "json", "{\"key\": \"value\"}")]
        
        for (name, lang, code) in languages {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = name
            label.font = .boldSystemFont(ofSize: 14)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let textView = UITextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
            textView.backgroundColor = .systemGray5
            textView.layer.cornerRadius = 4
            textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            textView.translatesAutoresizingMaskIntoConstraints = false
            
            let parser = BSTextSyntaxParser()
            let langIndex = ["swift", "python", "javascript", "json"].firstIndex(of: lang) ?? 0
            parser.language = BSTextSyntaxLanguage(rawValue: langIndex) ?? .swift
            textView.attributedText = parser.parse(code)
            
            container.addSubview(label)
            container.addSubview(textView)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: container.topAnchor),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                
                textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
                textView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                textView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                textView.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            stackView.addArrangedSubview(container)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

class ResizeDemoViewController: UIViewController {
    private let textView = BSTextView()
    private let resizeHandle = UIView()
    private var minHeight: CGFloat = 60
    private var maxHeight: CGFloat = 200
    private var startY: CGFloat = 0
    private var startHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 32, right: 12)
        textView.text = "拖拽底部滑块调整文本框大小..."
        view.addSubview(textView)
        
        resizeHandle.translatesAutoresizingMaskIntoConstraints = false
        resizeHandle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        resizeHandle.heightAnchor.constraint(equalToConstant: 6).isActive = true
        resizeHandle.backgroundColor = .systemGray4
        resizeHandle.layer.cornerRadius = 3
        resizeHandle.isUserInteractionEnabled = true
        view.addSubview(resizeHandle)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        resizeHandle.addGestureRecognizer(panGesture)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            resizeHandle.centerXAnchor.constraint(equalTo: textView.centerXAnchor),
            resizeHandle.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            startY = gesture.location(in: view).y
            startHeight = textView.frame.height
            
        case .changed:
            let deltaY = gesture.location(in: view).y - startY
            var newHeight = startHeight + deltaY
            newHeight = max(minHeight, min(newHeight, maxHeight))
            
            textView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
            view.layoutIfNeeded()
            
        case .ended, .cancelled:
            break
            
        default:
            break
        }
    }
}

class EmojiDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 24)
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        let emojis = ["🎉", "🚀", "💡", "🎯", "🌟", "💪", "🔥", "✨"]
        for (index, emoji) in emojis.enumerated() {
            let attachment = BSTextAttachment.emojiAttachment(emoji: emoji)
            attributedText.append(NSAttributedString(attachment: attachment))
            if index < emojis.count - 1 {
                attributedText.append(NSAttributedString(string: "  "))
            }
        }
        textView.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

class MentionDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "Hello "))
        
        let mentionAttachment = BSTextAttachment.mentionAttachment(username: "BSText")
        attributedText.append(NSAttributedString(attachment: mentionAttachment))
        
        attributedText.append(NSAttributedString(string: ", welcome to the demo!"))
        
        textView.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

class SearchDemoViewController: UIViewController {
    let searchField = UITextField()
    let textView = BSTextView()
    let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        searchField.placeholder = "搜索文本..."
        searchField.borderStyle = .roundedRect
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.addTarget(self, action: #selector(searchText), for: .editingChanged)
        view.addSubview(searchField)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 14)
        textView.text = """
This is a sample text for search testing.
The BSText framework supports powerful search functionality.
You can search for keywords like "search", "text", or "framework".
Try typing in the search field above!
"""
        view.addSubview(textView)
        
        resultLabel.text = "搜索结果：0 个匹配"
        resultLabel.font = .systemFont(ofSize: 14)
        resultLabel.textColor = .secondaryLabel
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            resultLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 12),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    @objc private func searchText() {
        guard let searchText = searchField.text, !searchText.isEmpty else {
            resultLabel.text = "搜索结果：0 个匹配"
            textView.attributedText = NSAttributedString(string: textView.text)
            return
        }
        
        let indexer = BSTextSearchIndexer()
        indexer.indexText(textView.text)
        let results = indexer.search(searchText)
        
        resultLabel.text = "搜索结果：\(results.count) 个匹配"
        
        if results.count > 0 {
            let attributedText = NSMutableAttributedString(string: textView.text)
            for result in results {
                attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: result.range)
            }
            textView.attributedText = attributedText
        } else {
            textView.attributedText = NSAttributedString(string: textView.text)
        }
    }
}
