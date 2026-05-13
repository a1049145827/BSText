import UIKit
import BSText

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let demos = [
        ("Rich Text", "富文本编辑", "richtext"),
        ("Markdown", "Markdown 解析", "markdown"),
        ("Code Editor", "代码编辑器", "code"),
        ("Syntax Highlight", "语法高亮", "syntax"),
        ("Resize Handle", "拖拽调整大小", "resize"),
        ("Emoji", "表情支持", "emoji"),
        ("Mention", "@提及", "mention"),
        ("Search", "文本搜索", "search")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        title = "BSText 3.0 Demo"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = demos[indexPath.row].0
        cell.detailTextLabel?.text = demos[indexPath.row].1
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let demoType = demos[indexPath.row].2
        var viewController: UIViewController
        
        switch demoType {
        case "richtext":
            viewController = RichTextDemoViewController()
        case "markdown":
            viewController = MarkdownDemoViewController()
        case "code":
            viewController = CodeEditorDemoViewController()
        case "syntax":
            viewController = SyntaxHighlightDemoViewController()
        case "resize":
            viewController = ResizeDemoViewController()
        case "emoji":
            viewController = EmojiDemoViewController()
        case "mention":
            viewController = MentionDemoViewController()
        case "search":
            viewController = SearchDemoViewController()
        default:
            viewController = UIViewController()
            viewController.view.backgroundColor = .systemBackground
        }
        
        viewController.title = demos[indexPath.row].0
        navigationController?.pushViewController(viewController, animated: true)
    }
}
