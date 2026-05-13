import UIKit
import BSText

class AsyncDemoViewController: UIViewController {
    
    let tableView = UITableView()
    let switchButton = UIButton(type: .system)
    var useAsyncRendering = true
    var fpsLabel = UILabel()
    var frameCount = 0
    var lastTime = Date()
    var displayLink: CADisplayLink?
    
    let dataSource = AsyncDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupFPSLabel()
        setupSwitchButton()
        setupTableView()
        startFPSMonitoring()
    }
    
    func setupNavigationBar() {
        title = "Async Rendering"
    }
    
    func setupFPSLabel() {
        fpsLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        fpsLabel.textColor = .systemGreen
        fpsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fpsLabel)
        
        NSLayoutConstraint.activate([
            fpsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            fpsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func setupSwitchButton() {
        switchButton.setTitle("Switch to Sync", for: .normal)
        switchButton.addTarget(self, action: #selector(toggleRenderMode), for: .touchUpInside)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchButton)
        
        NSLayoutConstraint.activate([
            switchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            switchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AsyncCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: switchButton.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.reloadData()
    }
    
    @objc func toggleRenderMode() {
        useAsyncRendering.toggle()
        if useAsyncRendering {
            switchButton.setTitle("Switch to Sync", for: .normal)
        } else {
            switchButton.setTitle("Switch to Async", for: .normal)
        }
        tableView.reloadData()
    }
    
    func startFPSMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc func updateFPS() {
        frameCount += 1
        let currentTime = Date()
        let elapsed = currentTime.timeIntervalSince(lastTime)
        
        if elapsed >= 1.0 {
            let fps = Double(frameCount) / elapsed
            fpsLabel.text = String(format: "%.1f FPS", fps)
            frameCount = 0
            lastTime = currentTime
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

extension AsyncDemoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AsyncCell
        cell.configure(with: dataSource.items[indexPath.row], useAsync: useAsyncRendering)
        return cell
    }
}

class AsyncDataSource {
    struct Item {
        let title: NSAttributedString
        let content: NSAttributedString
        let timestamp: String
        let avatar: String
    }
    
    let items: [Item]
    
    init() {
        var tempItems: [Item] = []
        
        let titles = [
            "Introduction to BSText",
            "Advanced Text Layout",
            "Performance Optimization",
            "Rich Text Features",
            "Syntax Highlighting",
            "Async Rendering Demo",
            "Memory Management",
            "Custom Attachments",
            "TextKit 2 Integration",
            "Layout Algorithms"
        ]
        
        for i in 0..<200 {
            let title = NSAttributedString(string: titles[i % titles.count], attributes: [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ])
            
            let content = AsyncDataSource.generateComplexContent(index: i)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let timestamp = dateFormatter.string(from: Date())
            
            let avatarEmojis = ["👨‍💻", "👩‍💻", "🧑‍💻", "👨‍🔬", "👩‍🔬", "👨‍🎨", "👩‍🎨", "🧑‍🎨", "👨‍💼", "👩‍💼"]
            let avatar = avatarEmojis[i % avatarEmojis.count]
            
            tempItems.append(Item(
                title: title,
                content: content,
                timestamp: timestamp,
                avatar: avatar
            ))
        }
        
        items = tempItems
    }
    
    private static func generateComplexContent(index: Int) -> NSAttributedString {
        let content = NSMutableAttributedString()
        
        let paragraphs = [
            "This is a **complex text layout demonstration** with *multiple styles* and ~~strikethrough~~ attributes. The BSText framework provides **powerful async rendering capabilities** for smooth scrolling performance even with large amounts of text content that requires complex layout calculations.",
            "Support for **bold text**, *italic text*, and ~~deleted text~~ styles. **Colorful text** can be used to highlight important information and improve readability. This paragraph contains various inline styles to stress test the text rendering engine with mixed formatting.",
            "Numbered lists are also supported:\n1. First item with important details and **bold keywords**\n2. Second item with additional information including *italic notes*\n3. Third item with special formatting like ~~crossed out text~~\n4. Fourth item demonstrating complex nested formatting scenarios",
            "Long text content that spans multiple lines to test the layout engine's ability to handle complex text flow and line breaking algorithms efficiently. This paragraph is intentionally long to create multiple lines of text that require careful layout computation and rendering optimization.",
            "Mixed content with various font sizes and weights creates a rich visual experience while maintaining smooth rendering performance. The combination of different text styles, font sizes, and formatting options puts significant stress on the text layout system."
        ]
        
        let paragraph = paragraphs[index % paragraphs.count]
        
        let repeatedParagraph = String(repeating: paragraph + "\n\n", count: 3)
        
        let parser = BSTextMarkdownParser()
        content.append(parser.parse(repeatedParagraph))
        
        return content
    }
}

class AsyncCell: UITableViewCell {
    let avatarView = UILabel()
    let titleLabel = UILabel()
    let contentLabel = UITextView()
    let timestampLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        selectionStyle = .none
        
        avatarView.font = .systemFont(ofSize: 32)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.layer.cornerRadius = 20
        avatarView.layer.masksToBounds = true
        avatarView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        avatarView.textAlignment = .center
        
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentLabel.isEditable = false
        contentLabel.isScrollEnabled = false
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.backgroundColor = .clear
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timestampLabel.font = .systemFont(ofSize: 12)
        timestampLabel.textColor = .secondaryLabel
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        container.addSubview(contentLabel)
        container.addSubview(timestampLabel)
        
        contentView.addSubview(avatarView)
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            timestampLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            timestampLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    func configure(with item: AsyncDataSource.Item, useAsync: Bool) {
        avatarView.text = item.avatar
        titleLabel.attributedText = item.title
        contentLabel.attributedText = item.content
        timestampLabel.text = item.timestamp
        
        if !useAsync {
            forceSyncLayout()
        }
    }
    
    private func forceSyncLayout() {
        contentView.layoutIfNeeded()
        Thread.sleep(forTimeInterval: 0.02)
    }
}
