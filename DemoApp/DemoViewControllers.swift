import UIKit
import BSText

class AttributeDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        attributedText.append(NSAttributedString(string: "Bold Text\n", attributes: boldAttributes))
        
        let italicAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 16)
        ]
        attributedText.append(NSAttributedString(string: "Italic Text\n", attributes: italicAttributes))
        
        let colorAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue
        ]
        attributedText.append(NSAttributedString(string: "Colored Text\n", attributes: colorAttributes))
        
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        attributedText.append(NSAttributedString(string: "Underlined Text\n", attributes: underlineAttributes))
        
        let strikethroughAttributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        attributedText.append(NSAttributedString(string: "Strikethrough Text\n", attributes: strikethroughAttributes))
        
        let shadowAttributes: [NSAttributedString.Key: Any] = [
            .shadow: NSShadow()
        ]
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        shadow.shadowColor = UIColor.gray
        let shadowAttrs: [NSAttributedString.Key: Any] = [.shadow: shadow]
        attributedText.append(NSAttributedString(string: "Shadow Text", attributes: shadowAttrs))
        
        textView.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

class EditDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "在此输入文本..."
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        
        let boldButton = UIBarButtonItem(title: "B", style: .plain, target: self, action: #selector(toggleBold))
        boldButton.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        
        let italicButton = UIBarButtonItem(title: "I", style: .plain, target: self, action: #selector(toggleItalic))
        italicButton.setTitleTextAttributes([.font: UIFont.italicSystemFont(ofSize: 16)], for: .normal)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [boldButton, flexibleSpace, italicButton]
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func toggleBold() {}
    @objc func toggleItalic() {}
}

class EmoticonDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 32)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        let emojis = ["🎉", "🚀", "💡", "🎯", "🌟", "💪", "🔥", "✨", "❤️", "😊"]
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

class TagDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "Tags: "))
        
        let tags = ["#iOS", "#Swift", "#BSText", "#TextKit"]
        for (index, tag) in tags.enumerated() {
            let mentionAttachment = BSTextAttachment.mentionAttachment(username: tag)
            attributedText.append(NSAttributedString(attachment: mentionAttachment))
            if index < tags.count - 1 {
                attributedText.append(NSAttributedString(string: " "))
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

class MarkdownDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 15)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
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

class HighlightDemoViewController: UIViewController {
    let searchField = UITextField()
    let textView = BSTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        searchField.placeholder = "Search..."
        searchField.borderStyle = .roundedRect
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.addTarget(self, action: #selector(searchText), for: .editingChanged)
        view.addSubview(searchField)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = """
This is a sample text for search testing.
The BSText framework supports powerful search functionality.
You can search for keywords like "search", "text", or "framework".
Try typing in the search field above!
"""
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc func searchText() {
        guard let searchText = searchField.text, !searchText.isEmpty else {
            textView.attributedText = NSAttributedString(string: textView.text)
            return
        }
        
        let indexer = BSTextSearchIndexer()
        indexer.indexText(textView.text)
        let results = indexer.search(searchText)
        
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

class CopyPasteDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "Try copying and pasting text here..."
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

class UndoRedoDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "Type something and try undo/redo..."
        view.addSubview(textView)
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: nil, action: nil)
        let redoButton = UIBarButtonItem(barButtonSystemItem: .redo, target: nil, action: nil)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [undoButton, flexibleSpace, redoButton]
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            toolbar.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

class AsyncDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        var largeText = ""
        for i in 1...100 {
            largeText += "Line \(i): This is a test line for asynchronous rendering performance.\n"
        }
        textView.text = largeText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

class ResizeDemoViewController: UIViewController {
    private let textView = BSTextView()
    private let resizeHandle = UIView()
    private var minHeight: CGFloat = 60
    private var maxHeight: CGFloat = 600
    private var startY: CGFloat = 0
    private var startHeight: CGFloat = 0
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        maxHeight = view.safeAreaLayoutGuide.layoutFrame.height - 60
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 32, right: 12)
        textView.text = "Drag the handle below to resize..."
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        resizeHandle.translatesAutoresizingMaskIntoConstraints = false
        resizeHandle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        resizeHandle.heightAnchor.constraint(equalToConstant: 6).isActive = true
        resizeHandle.backgroundColor = UIColor.lightGray
        resizeHandle.layer.cornerRadius = 3
        resizeHandle.isUserInteractionEnabled = true
        view.addSubview(resizeHandle)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        resizeHandle.addGestureRecognizer(panGesture)
        
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 100)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textViewHeightConstraint,
            
            resizeHandle.centerXAnchor.constraint(equalTo: textView.centerXAnchor),
            resizeHandle.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startY = gesture.location(in: view).y
            startHeight = textViewHeightConstraint.constant
            
        case .changed:
            let deltaY = gesture.location(in: view).y - startY
            var newHeight = startHeight + deltaY
            newHeight = max(minHeight, min(newHeight, maxHeight))
            textViewHeightConstraint.constant = newHeight
            view.layoutIfNeeded()
            
        case .ended, .cancelled:
            break
            
        default:
            break
        }
    }
}
