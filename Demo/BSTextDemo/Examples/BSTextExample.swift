//
//  BSTextExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

private var kExampleCellReuseId = "kExampleCellReuseId"

class BSTextExample: UITableViewController {

    private var titles: [String] = []
    private var classNames: [UIViewController.Type] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "✎      BSText Demo       ✎"
        
        addCell("Text Attributes 1", class: BSTextAttributeExample.self)
        addCell("Text Attributes 2", class: BSTextTagExample.self)
        addCell("Text Attachments", class: BSTextAttachmentExample.self)
        addCell("Text Edit", class: BSTextEditExample.self)
        addCell("Text Parser (Markdown)", class: BSTextMarkdownExample.self)
        addCell("Text Parser (Emoticon)", class: BSTextEmoticonExample.self)
        addCell("Text Binding", class: BSTextBindingExample.self)
        addCell("Copy and Paste", class: BSTextCopyPasteExample.self)
        addCell("Undo and Redo", class: BSTextUndoRedoExample.self)
        addCell("Ruby Annotation", class: BSTextRubyExample.self)
        addCell("Async Display", class: BSTextAsyncExample.self)
        addCell("My Example Demo", class: MyExample.self)
        
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kExampleCellReuseId)
        
        tableView.reloadData()
    }
    
    func addCell(_ title: String, class: UIViewController.Type) {
        titles.append(title)
        classNames.append(`class`)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kExampleCellReuseId) else {
            fatalError("have not register cell class")
        }
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cls = classNames[indexPath.row]
        let ctrl = cls.init()
        
        ctrl.title = titles[indexPath.row]
        navigationController?.pushViewController(ctrl, animated: true)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
