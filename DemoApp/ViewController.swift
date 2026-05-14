import UIKit
import BSText

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let demos = [
        ("Attribute", "富文本属性", "attribute"),
        ("Edit", "文本编辑", "edit"),
        ("Emoticon", "表情符号", "emoticon"),
        ("Tag", "标签视图", "tag"),
        ("Markdown", "Markdown", "markdown"),
        ("Table", "表格支持", "table"),
        ("Highlight", "高亮搜索", "highlight"),
        ("CopyPaste", "复制粘贴", "copypaste"),
        ("UndoRedo", "撤销重做", "undoredo"),
        ("Async", "异步渲染", "async"),
        ("Resize", "调整大小", "resize")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        title = "BSText Demo"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DemoCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = .clear
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DemoCell
        cell.titleLabel.text = demos[indexPath.row].0
        cell.subtitleLabel.text = demos[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let demoType = demos[indexPath.row].2
        var viewController: UIViewController
        
        switch demoType {
        case "attribute":
            viewController = AttributeDemoViewController()
        case "edit":
            viewController = EditDemoViewController()
        case "emoticon":
            viewController = EmoticonDemoViewController()
        case "tag":
            viewController = TagDemoViewController()
        case "markdown":
            viewController = MarkdownDemoViewController()
        case "table":
            viewController = TableDemoViewController()
        case "highlight":
            viewController = HighlightDemoViewController()
        case "copypaste":
            viewController = CopyPasteDemoViewController()
        case "undoredo":
            viewController = UndoRedoDemoViewController()
        case "async":
            viewController = AsyncDemoViewController()
        case "resize":
            viewController = ResizeDemoViewController()
        default:
            viewController = UIViewController()
            viewController.view.backgroundColor = .white
        }
        
        viewController.title = demos[indexPath.row].0
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class DemoCell: UITableViewCell {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor(white: 0.5, alpha: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}
