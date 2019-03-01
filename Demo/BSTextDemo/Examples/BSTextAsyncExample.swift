//
//  BSTextAsyncExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage

private var kAsyncExampleCellId = "kAsyncExampleCellId"
private let kCellHeight: CGFloat = 34

class BSTextAsyncExample: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var async = false {
        didSet {
            (tableView.visibleCells as NSArray).enumerateObjects({ cell, idx, stop in
                guard let cell = cell as? BSTextAsyncExampleCell else {
                    return
                }
                cell.async = async
                
                if let indexPath = self.tableView.indexPath(for: cell) {
                    if self.async {
                        cell.setAyncText(self.layouts[indexPath.row])
                    } else {
                        cell.setAyncText(self.strings[indexPath.row])
                    }
                }
            })
        }
    }
    private var strings: [NSMutableAttributedString] = []
    private var layouts: [TextLayout] = []
    private var tableView = UITableView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BSTextAsyncExampleCell.self, forCellReuseIdentifier: kAsyncExampleCellId)
        view.addSubview(tableView)
        
        
        for i in 0..<300 {
            let str = "\(i) Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫 Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫"
            
            let text = NSMutableAttributedString(string: str)
            text.bs_font = UIFont.systemFont(ofSize: 10)
            text.bs_lineSpacing = 0
            text.bs_strokeWidth = NSNumber(value: -3)
            text.bs_strokeColor = UIColor.red
            text.bs_lineHeightMultiple = 1
            text.bs_maximumLineHeight = 12
            text.bs_minimumLineHeight = 12
            
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 1
            shadow.shadowColor = UIColor.red
            shadow.shadowOffset = CGSize(width: 0, height: 1)
            strings.append(text)
            
            // it better to do layout in background queue...
            let container = TextContainer.container(with: CGSize(width: Screen.width, height: kCellHeight))
            let layout = TextLayout(container: container, text: text)
            layouts.append(layout!)
        }
        
        let toolbar = UIView()
        toolbar.backgroundColor = UIColor.white
        
        toolbar.size = CGSize(width: Screen.width, height: 40)
        toolbar.top = kNavHeight
        
        view.addSubview(toolbar)
        
        
        let fps = BSFPSLabel()
        fps.centerY = toolbar.height / 2.0
        fps.left = 5
        toolbar.addSubview(fps)
        
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.text = "UILabel/BSLabel(Async): "
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.centerY = toolbar.height / 2.0
        label.left = fps.right + 10
        toolbar.addSubview(label)
        
        let switcher = UISwitch()
        switcher.sizeToFit()
        switcher.centerY = toolbar.height / 2.0
        switcher.left = label.right + 10
        switcher.layer.transformScale = 0.7
        weak var _self = self
        switcher.addBlock(forControlEvents: UIControl.Event.valueChanged, block: { switcher in
            guard let switcher = switcher as? UISwitch else {
                return
            }
            if let `self` = _self {
                self.async = switcher.isOn
            }
        })
        
        toolbar.addSubview(switcher)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kAsyncExampleCellId, for: indexPath) as! BSTextAsyncExampleCell
        
        cell.async = async
        if async {
            cell.setAyncText(layouts[indexPath.row])
        } else {
            cell.setAyncText(strings[indexPath.row])
        }
        
        return cell
    }
}

class BSTextAsyncExampleCell: UITableViewCell {
    
    private var uiLabel = UILabel()
    private var bsLabel = BSLabel()
    
    var async: Bool = false {
        didSet {
            if async == oldValue {
                return
            }
            uiLabel.isHidden = async
            bsLabel.isHidden = !async
        }
    }
    
    func setAyncText(_ text: Any) {
        if async {
            bsLabel.layer.contents = nil
            bsLabel.textLayout = text as? TextLayout
        } else {
            uiLabel.attributedText = text as? NSAttributedString
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        uiLabel.font = UIFont.systemFont(ofSize: 8)
        uiLabel.numberOfLines = 0
        uiLabel.size = CGSize(width: Screen.width, height: CGFloat(kCellHeight))
        
        
        bsLabel.font = uiLabel.font
        bsLabel.numberOfLines = uiLabel.numberOfLines
        bsLabel.size = uiLabel.size
        bsLabel.displaysAsynchronously = true /// enable async display
        bsLabel.isHidden = true
        
        contentView.addSubview(uiLabel)
        contentView.addSubview(bsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
