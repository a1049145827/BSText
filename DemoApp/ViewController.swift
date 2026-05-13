import UIKit
import BSText

class ViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
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
        
        var previousView: UIView?
        
        let titleLabel = UILabel()
        titleLabel.text = "BSText 3.0 Demo"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        constrain(view: titleLabel, below: previousView)
        previousView = titleLabel
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Modern Text Editor for iOS"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        constrain(view: subtitleLabel, below: previousView, padding: 4)
        previousView = subtitleLabel
        
        previousView = addSection(title: "Rich Text", subtitle: "富文本编辑", previousView: previousView) { contentView in
            let textView = BSTextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.layer.borderColor = UIColor.systemGray3.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8
            textView.font = .systemFont(ofSize: 16)
            
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: "Bold\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)]))
            attributedText.append(NSAttributedString(string: "Italic\n", attributes: [.font: UIFont.italicSystemFont(ofSize: 16)]))
            attributedText.append(NSAttributedString(string: "Colored Text", attributes: [.foregroundColor: UIColor.systemBlue]))
            textView.attributedText = attributedText
            
            contentView.addSubview(textView)
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                textView.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
        
        previousView = addSection(title: "Markdown", subtitle: "Markdown 解析", previousView: previousView) { contentView in
            let textView = BSTextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.isEditable = false
            textView.layer.borderColor = UIColor.systemGray3.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8
            textView.font = .systemFont(ofSize: 15)
            
            let markdown = "# Heading\n\n**Bold** and *italic* text.\n\n- List 1\n- List 2"
            let parser = BSTextMarkdownParser()
            textView.attributedText = parser.parse(markdown)
            
            contentView.addSubview(textView)
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                textView.heightAnchor.constraint(equalToConstant: 120)
            ])
        }
        
        previousView = addSection(title: "Code Editor", subtitle: "代码编辑器", previousView: previousView) { contentView in
            let codeEditor = BSTextCodeEditor()
            codeEditor.translatesAutoresizingMaskIntoConstraints = false
            codeEditor.layer.borderColor = UIColor.systemGray3.cgColor
            codeEditor.layer.borderWidth = 1
            codeEditor.layer.cornerRadius = 8
            codeEditor.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
            codeEditor.language = .swift
            codeEditor.text = "func hello() {\n    print(\"Hello BSText!\")\n}"
            
            contentView.addSubview(codeEditor)
            NSLayoutConstraint.activate([
                codeEditor.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                codeEditor.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                codeEditor.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                codeEditor.heightAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        previousView = addSection(title: "Resize Handle", subtitle: "拖拽调整大小", previousView: previousView) { contentView in
            let textView = BSTextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.layer.borderColor = UIColor.systemGray3.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8
            textView.font = .systemFont(ofSize: 16)
            textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 32, right: 12)
            textView.text = "Drag bottom handle to resize..."
            
            let resizeHandle = UIView()
            resizeHandle.translatesAutoresizingMaskIntoConstraints = false
            resizeHandle.widthAnchor.constraint(equalToConstant: 30).isActive = true
            resizeHandle.heightAnchor.constraint(equalToConstant: 6).isActive = true
            resizeHandle.backgroundColor = .systemGray4
            resizeHandle.layer.cornerRadius = 3
            
            contentView.addSubview(textView)
            textView.addSubview(resizeHandle)
            
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                textView.heightAnchor.constraint(equalToConstant: 100),
                
                resizeHandle.centerXAnchor.constraint(equalTo: textView.centerXAnchor),
                resizeHandle.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -6)
            ])
        }
        
        let bottomPadding = UIView()
        bottomPadding.translatesAutoresizingMaskIntoConstraints = false
        bottomPadding.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentView.addSubview(bottomPadding)
        constrain(view: bottomPadding, below: previousView)
    }
    
    func constrain(view: UIView, below previousView: UIView?, padding: CGFloat = 16) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: previousView?.bottomAnchor ?? contentView.topAnchor, constant: padding),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @discardableResult
    func addSection(title: String, subtitle: String, previousView: UIView?, content: (UIView) -> Void) -> UIView {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        sectionView.addSubview(titleLabel)
        sectionView.addSubview(subtitleLabel)
        sectionView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            
            contentView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor)
        ])
        
        content(contentView)
        
        self.contentView.addSubview(sectionView)
        constrain(view: sectionView, below: previousView, padding: 24)
        
        return sectionView
    }
}
