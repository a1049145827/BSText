//
//  BSText.h
//  BSText
//
//  Created by BlueSky on 2018/10/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for BSText.
FOUNDATION_EXPORT double BSTextVersionNumber;

//! Project version string for BSText.
FOUNDATION_EXPORT const unsigned char BSTextVersionString[];

// To Bridge Objective-C

/**
 The tap/long press action callback defined in BSText.
 
 @param containerView The text container view (such as BSLabel/BSTextView).
 @param text          The whole text.
 @param range         The text range in `text` (if no range, the range.location is NSNotFound).
 @param rect          The text frame in `containerView` (if no data, the rect is CGRectNull).
 */
typedef void(^TextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);

#import <CoreText/CoreText.h>
