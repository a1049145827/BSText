//
//  BSTextObjC.h
//  BSText
//
//  Objective-C bridge header for BSText 3 public API.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// The main text view class. See BSTextView.swift for full documentation.
@interface BSTextView : UITextView

/// The content storage managing attributed text.
@property (nonatomic, strong, readonly) NSTextContentStorage *contentStorage;

/// The layout manager managing text layout and rendering.
@property (nonatomic, strong, readonly) NSTextLayoutManager *layoutManager;

@end

NS_ASSUME_NONNULL_END
