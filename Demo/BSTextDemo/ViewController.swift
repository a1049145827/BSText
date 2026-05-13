import UIKit
import BSText

class ViewController: UIViewController {
    
    let textView = BSTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        var previousView: UIView?
        
        let titleLabel = UILabel()
        titleLabel.text = "BSText 3.0 Demo"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        setupConstraints(previousView: previousView, currentView: titleLabel, contentView: contentView)
        previousView = titleLabel
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "A modern, high-performance text editor for iOS"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        setupConstraints(previousView: previousView, currentView: subtitleLabel, contentView: contentView)
        previousView = subtitleLabel
        
        let separator = UIView()
        separator.backgroundColor = .systemGray3
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        previousView = separator
        
        addRichTextDemo(to: contentView, previousView: &previousView)
        addMarkdownDemo(to: contentView, previousView: &previousView)
        addCodeEditorDemo(to: contentView, previousView: &previousView)
        addSyntaxHighlightDemo(to: contentView, previousView: &previousView)
        addAttachmentDemo(to: contentView, previousView: &previousView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupConstraints(previousView: UIView?, currentView: UIView, contentView: UIView) {
        NSLayoutConstraint.activate([
            currentView.topAnchor.constraint(equalTo: previousView?.bottomAnchor ?? contentView.topAnchor, constant: 20),
            currentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func addRichTextDemo(to contentView: UIView, previousView: inout UIView?) {
        let section = createSection(title: "Rich Text Editing", subtitle: "富文本编辑")
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "Bold Text\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)]))
        attributedText.append(NSAttributedString(string: "Italic Text\n", attributes: [.font: UIFont.italicSystemFont(ofSize: 16)]))
        attributedText.append(NSAttributedString(string: "Colored Text\n", attributes: [.foregroundColor: UIColor.systemBlue]))
        attributedText.append(NSAttributedString(string: "Underlined Text", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]))
        
        textView.attributedText = attributedText
        
        section.contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: section.titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: section.contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: section.contentView.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        contentView.addSubview(section.view)
        setupConstraints(previousView: previousView, currentView: section.view, contentView: contentView)
        previousView = section.view
    }
    
    func addMarkdownDemo(to contentView: UIView, previousView: inout UIView?) {
        let section = createSection(title: "Markdown Support", subtitle: "Markdown 解析")
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 15)
        
        let markdown = """
        # Markdown Heading
        
        **Bold** and *italic* text supported.
        
        - List item 1
        - List item 2
        - List item 3
        
        > Blockquote example
        
        `Code snippet`
        """
        
        let parser = BSTextMarkdownParser()
        textView.attributedText = parser.parse(markdown)
        
        section.contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: section.titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: section.contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: section.contentView.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        contentView.addSubview(section.view)
        setupConstraints(previousView: previousView, currentView: section.view, contentView: contentView)
        previousView = section.view
    }
    
    func addCodeEditorDemo(to contentView: UIView, previousView: inout UIView?) {
        let section = createSection(title: "Code Editor", subtitle: "代码编辑器")
        
        let codeEditor = BSTextCodeEditor()
        codeEditor.translatesAutoresizingMaskIntoConstraints = false
        codeEditor.layer.borderColor = UIColor.systemGray3.cgColor
        codeEditor.layer.borderWidth = 1
        codeEditor.layer.cornerRadius = 8
        codeEditor.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        codeEditor.language = .swift
        
        let code = """
        func hello(name: String) {
            print("Hello, \\(name)!")
            let message = "Welcome to BSText"
            return message
        }
        """
        
        codeEditor.text = code
        
        section.contentView.addSubview(codeEditor)
        NSLayoutConstraint.activate([
            codeEditor.topAnchor.constraint(equalTo: section.titleLabel.bottomAnchor, constant: 12),
            codeEditor.leadingAnchor.constraint(equalTo: section.contentView.leadingAnchor),
            codeEditor.trailingAnchor.constraint(equalTo: section.contentView.trailingAnchor),
            codeEditor.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        contentView.addSubview(section.view)
        setupConstraints(previousView: previousView, currentView: section.view, contentView: contentView)
        previousView = section.view
    }
    
    func addSyntaxHighlightDemo(to contentView: UIView, previousView: inout UIView?) {
        let section = createSection(title: "Syntax Highlighting", subtitle: "语法高亮")
        
        let languages = ["Swift", "Python", "JavaScript", "JSON"]
        let languageCodes: [String] = [
            "let x = 5",
            "x = 5",
            "const x = 5",
            "{\"key\": \"value\"}"
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, language) in languages.enumerated() {
            let label = UILabel()
            label.text = language
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textColor = .secondaryLabel
            
            let textView = UITextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.font = .monospacedSystemFont(ofSize: 13)
            textView.backgroundColor = .systemGray5
            textView.layer.cornerRadius = 4
            textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            
            let parser = BSTextSyntaxParser()
            parser.language = BSTextSyntaxLanguage(rawValue: index) ?? .swift
            textView.attributedText = parser.parse(languageCodes[index])
            
            let langStack = UIStackView(arrangedSubviews: [label, textView])
            langStack.axis = .vertical
            langStack.spacing = 4
            
            stackView.addArrangedSubview(langStack)
        }
        
        section.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: section.titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: section.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: section.contentView.trailingAnchor)
        ])
        
        contentView.addSubview(section.view)
        setupConstraints(previousView: previousView, currentView: section.view, contentView: contentView)
        previousView = section.view
    }
    
    func addAttachmentDemo(to contentView: UIView, previousView: inout UIView?) {
        let section = createSection(title: "Attachments", subtitle: "附件支持")
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiAttachment = BSTextAttachment.emojiAttachment(emoji: "🎉")
        let emojiString = NSAttributedString(attachment: emojiAttachment)
        
        let mentionAttachment = BSTextAttachment.mentionAttachment(username: "BSText")
        let mentionString = NSAttributedString(attachment: mentionAttachment)
        
        let fileAttachment = BSTextAttachment.fileAttachment(filename: "Document", fileType: "pdf")
        let fileString = NSAttributedString(attachment: fileAttachment)
        
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(emojiString)
        attributedText.append(NSAttributedString(string: " Emoji support\n\n"))
        attributedText.append(mentionString)
        attributedText.append(NSAttributedString(string: " Mention support\n\n"))
        attributedText.append(fileString)
        attributedText.append(NSAttributedString(string: " File attachment"))
        
        textView.attributedText = attributedText
        
        stackView.addArrangedSubview(textView)
        
        section.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: section.titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: section.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: section.contentView.trailingAnchor)
        ])
        
        contentView.addSubview(section.view)
        setupConstraints(previousView: previousView, currentView: section.view, contentView: contentView)
        previousView = section.view
        
        let bottomPadding = UIView()
        bottomPadding.translatesAutoresizingMaskIntoConstraints = false
        bottomPadding.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentView.addSubview(bottomPadding)
        setupConstraints(previousView: previousView, currentView: bottomPadding, contentView: contentView)
    }
    
    func createSection(title: String, subtitle: String) -> (view: UIView, titleLabel: UILabel, contentView: UIView) {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return (view, titleLabel, contentView)
    }
}
