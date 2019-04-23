//
//  NSBundleExtension.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

extension Bundle {
    
    static var scales: [CGFloat] = {
        let scale = UIScreen.main.scale
        if scale <= 1 {
            return [1, 2, 3]
        } else if scale <= 2 {
            return [2, 3, 1]
        } else {
            return [3, 2, 1]
        }
    }()
    
    class func path(forScaledResource name: String?, ofType ext: String?, inDirectory bundlePath: String?) -> String? {
        guard let name = name, name != "" else {
            return nil
        }
        let bundlePath = bundlePath ?? ""
        if name.hasSuffix("/") {
            return self.path(forResource: name, ofType: ext, inDirectory: bundlePath)
        }
        
        var path: String? = nil
        
        for scale in scales {
            
            let scaledName = (ext?.count ?? 0) != 0 ? name.string(byAppendingNameScale: scale) : name.string(byAppendingPathScale: scale)
            path = self.path(forResource: scaledName, ofType: ext, inDirectory: bundlePath)
            if path != nil {
                break
            }
        }
        
        return path
    }
    
    func path(forScaledResource name: String?, ofType ext: String?) -> String? {
        guard let name = name, name != "" else {
            return nil
        }
        if name.hasSuffix("/") {
            return self.path(forResource: name, ofType: ext)
        }
        
        var path: String? = nil
        
        for scale in Bundle.scales {
            
            let scaledName = (ext?.count ?? 0) != 0 ? name.string(byAppendingNameScale: scale) : name.string(byAppendingPathScale: scale)
            path = self.path(forResource: scaledName, ofType: ext)
            if path != nil {
                break
            }
        }
        
        return path
    }
    
    func path(forScaledResource name: String?, ofType ext: String?, inDirectory subpath: String?) -> String? {
        guard let name = name, name != "" else {
            return nil
        }
        if name.hasSuffix("/") {
            return self.path(forResource: name, ofType: ext)
        }
        
        var path: String? = nil
        
        for scale in Bundle.scales {
            
            let scaledName = (ext?.count ?? 0) != 0 ? name.string(byAppendingNameScale: scale) : name.string(byAppendingPathScale: scale)
            path = self.path(forResource: scaledName, ofType: ext, inDirectory: subpath ?? "")
            if path != nil {
                break
            }
        }
        
        return path
    }
}
