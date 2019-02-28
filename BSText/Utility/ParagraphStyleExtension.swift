//
//  ParagraphStyleExtension.swift
//  BSText
//
//  Created by BlueSky on 2018/10/23.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

/**
 Provides extensions for `NSParagraphStyle` to work with CoreText.
 */
public extension NSParagraphStyle {
    /**
     Creates a new NSParagraphStyle object from the CoreText Style.
     
     @param ctStyle CoreText Paragraph Style.
     
     @return a new NSParagraphStyle
     */
    @objc(bs_styleWithCTStyle:)
    class func bs_styleWith(ctStyle: CTParagraphStyle) -> NSParagraphStyle {
        
        let style = NSMutableParagraphStyle()
        
        var lineSpacing: CGFloat = 0
        
        // MARK: - YYText 中用的是 kCTParagraphStyleSpecifierLineSpacing
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.lineSpacingAdjustment, MemoryLayout<CGFloat>.size, &lineSpacing) {
            style.lineSpacing = lineSpacing
        }
        
        var paragraphSpacing: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.paragraphSpacing, MemoryLayout<CGFloat>.size, &paragraphSpacing) {
            style.paragraphSpacing = paragraphSpacing
        }
        var alignment: CTTextAlignment?
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.alignment, MemoryLayout<CTTextAlignment>.size, &alignment) {
            style.alignment = NSTextAlignment(alignment!)
        }
        var firstLineHeadIndent: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.firstLineHeadIndent, MemoryLayout<CGFloat>.size, &firstLineHeadIndent) {
            style.firstLineHeadIndent = firstLineHeadIndent
        }
        var headIndent: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.headIndent, MemoryLayout<CGFloat>.size, &headIndent) {
            style.headIndent = headIndent
        }
        var tailIndent: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.tailIndent, MemoryLayout<CGFloat>.size, &tailIndent) {
            style.tailIndent = tailIndent
        }
        var lineBreakMode: CTLineBreakMode?
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.lineBreakMode, MemoryLayout<CTLineBreakMode>.size, &lineBreakMode) {
            if let aMode = NSLineBreakMode(rawValue: Int(lineBreakMode!.rawValue)) {
                style.lineBreakMode = aMode
            }
        }
        var minimumLineHeight: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.minimumLineHeight, MemoryLayout<CGFloat>.size, &minimumLineHeight) {
            style.minimumLineHeight = minimumLineHeight
        }
        var maximumLineHeight: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.maximumLineHeight, MemoryLayout<CGFloat>.size, &maximumLineHeight) {
            style.maximumLineHeight = maximumLineHeight
        }
        var baseWritingDirection: CTWritingDirection?
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.baseWritingDirection, MemoryLayout<CTWritingDirection>.size, &baseWritingDirection) {
            if let aDirection = NSWritingDirection(rawValue: Int(baseWritingDirection!.rawValue)) {
                style.baseWritingDirection = aDirection
            }
        }
        var lineHeightMultiple: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.lineHeightMultiple, MemoryLayout<CGFloat>.size, &lineHeightMultiple) {
            style.lineHeightMultiple = lineHeightMultiple
        }
        var paragraphSpacingBefore: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.paragraphSpacingBefore, MemoryLayout<CGFloat>.size, &paragraphSpacingBefore) {
            style.paragraphSpacingBefore = paragraphSpacingBefore
        }
        
        var tabStops: CFArray?
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.tabStops, MemoryLayout<CFArray?>.size, &tabStops) {
            
            var tabs = [AnyHashable]()
            (((tabStops) as? [Any]) as NSArray?)?.enumerateObjects({ obj, idx, stop in
                let ctTab = obj
                var tab: NSTextTab? = nil
                if let aTab = CTTextTabGetOptions(ctTab as! CTTextTab) as? [NSTextTab.OptionKey : Any] {
                    tab = NSTextTab(textAlignment: NSTextAlignment(CTTextTabGetAlignment(ctTab as! CTTextTab)), location: CGFloat(CTTextTabGetLocation(ctTab as! CTTextTab)), options: aTab)
                }
                if let aTab = tab {
                    tabs.append(aTab)
                }
            })
            if tabs.count != 0 {
                if let aTabs = tabs as? [NSTextTab] {
                    style.tabStops = aTabs
                }
            }
        }
        
        var defaultTabInterval: CGFloat = 0
        if CTParagraphStyleGetValueForSpecifier(ctStyle, CTParagraphStyleSpecifier.defaultTabInterval, MemoryLayout<CGFloat>.size, &defaultTabInterval) {
            
            style.defaultTabInterval = defaultTabInterval
        }
        
        return style
    }
    /**
     Creates and returns a CoreText Paragraph Style. (need call CFRelease() after used)
     */
    @objc func bs_CTStyle() -> CTParagraphStyle {
        
        var settings = [CTParagraphStyleSetting]()
        
        var lineSpacing: CGFloat = self.lineSpacing
        settings.append(CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing))
        
        var paragraphSpacing: CGFloat = self.paragraphSpacing
        settings.append(CTParagraphStyleSetting(spec: .paragraphSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpacing))
        
        var alignment = CTTextAlignment(self.alignment)
        settings.append(CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: &alignment))
        
        var firstLineHeadIndent: CGFloat = self.firstLineHeadIndent
        settings.append(CTParagraphStyleSetting(spec: .firstLineHeadIndent, valueSize: MemoryLayout<CGFloat>.size, value: &firstLineHeadIndent))
        
        var headIndent: CGFloat = self.headIndent
        settings.append(CTParagraphStyleSetting(spec: .headIndent, valueSize: MemoryLayout<CGFloat>.size, value: &headIndent))
        
        var tailIndent: CGFloat = self.tailIndent
        settings.append(CTParagraphStyleSetting(spec: .tailIndent, valueSize: MemoryLayout<CGFloat>.size, value: &tailIndent))

        var paraLineBreak = CTLineBreakMode(rawValue: UInt8(self.lineBreakMode.rawValue))
        settings.append(CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: &paraLineBreak))
        
        var minimumLineHeight: CGFloat = self.minimumLineHeight
        settings.append(CTParagraphStyleSetting(spec: .minimumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &minimumLineHeight))
        
        var maximumLineHeight: CGFloat = self.maximumLineHeight
        settings.append(CTParagraphStyleSetting(spec: .maximumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &maximumLineHeight))
        
        var paraWritingDirection = CTWritingDirection(rawValue: Int8(self.baseWritingDirection.rawValue))
        settings.append(CTParagraphStyleSetting(spec: .baseWritingDirection, valueSize: MemoryLayout<CTWritingDirection>.size, value: &paraWritingDirection))
        
        var lineHeightMultiple: CGFloat = self.lineHeightMultiple
        settings.append(CTParagraphStyleSetting(spec: .lineHeightMultiple, valueSize: MemoryLayout<CGFloat>.size, value: &lineHeightMultiple))
        
        var paragraphSpacingBefore: CGFloat = self.paragraphSpacingBefore
        settings.append(CTParagraphStyleSetting(spec: .paragraphSpacingBefore, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpacingBefore))

        if self.responds(to: #selector(getter: self.tabStops)) {
            var tabs: [AnyHashable] = []
            
            let numTabs: Int = self.tabStops.count
            if numTabs != 0 {
                (self.tabStops as NSArray).enumerateObjects({ tab, idx, stop in
                    let tab_: NSTextTab = tab as! NSTextTab
                    
                    let ctTab = CTTextTabCreate(CTTextAlignment.init(tab_.alignment), Double(tab_.location), tab_.options as CFDictionary)
                    
                    tabs.append(ctTab)
                })
                var tabStops = tabs
                settings.append(CTParagraphStyleSetting(spec: .tabStops, valueSize: MemoryLayout<CFArray>.size, value: &tabStops))
            }
            
            if self.responds(to: #selector(getter: self.defaultTabInterval)) {
                var defaultTabInterval: CGFloat = self.defaultTabInterval
                settings.append(CTParagraphStyleSetting(spec: .defaultTabInterval, valueSize: MemoryLayout<CGFloat>.size, value: &defaultTabInterval))
            }
        }
        
        let style = CTParagraphStyleCreate(settings, settings.count)
        return style
    }
}
