//
//  BSLabel.swift
//  BSText
//
//  Created by BlueSky on 2018/12/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

private let BSLabelGetReleaseQueue = DispatchQueue.global(qos: .default)

/// Time in seconds the fingers must be held down for long press gesture.
fileprivate let kLongPressMinimumDuration = 0.5
/// Maximum movement in points allowed before the long press fails.
fileprivate let kLongPressAllowableMovement: Float = 9
/// Time in seconds for highlight fadeout animation.
fileprivate let kHighlightFadeDuration = 0.15
/// Time in seconds for async display fadeout animation.
fileprivate let kAsyncFadeDuration = 0.08


/**
 The BSLabel class implements a read-only text view.
 
 @discussion The API and behavior is similar to UILabel, but provides more features:
 
 * It supports asynchronous layout and rendering (to avoid blocking UI thread).
 * It extends the CoreText attributes to support more text effects.
 * It allows to add UIImage, UIView and CALayer as text attachments.
 * It allows to add 'highlight' link to some range of text to allow user interact with.
 * It allows to add container path and exclusion paths to control text container's shape.
 * It supports vertical form layout to display CJK text.
 
 See NSAttributedStringExtension.swift for more convenience methods to set the attributes.
 See TextAttribute.swift and TextLayout.swift for more information.
 */
open class BSLabel: UIView, TextDebugTarget, TextAsyncLayerDelegate, NSSecureCoding {
    
    // MARK: - Accessing the Text Attributes
    
    ///=============================================================================
    /// @name Accessing the Text Attributes
    ///=============================================================================
    
    private var _text: String?
    /**
     The text displayed by the label. Default is nil.
     Set a new value to this property also replaces the text in `attributedText`.
     Get the value returns the plain text in `attributedText`.
     */
    @objc open var text: String? {
        set {
            if (_text == newValue) {
                return
            }
            _text = newValue
            let needAddAttributes = (innerText.length == 0 && (text?.length ?? 0) > 0)
            innerText.replaceCharacters(in: NSRange(location: 0, length: innerText.length), with: text != nil ? text! : "")
            innerText.bs_removeDiscontinuousAttributes(in: NSRange(location: 0, length: innerText.length))
            if needAddAttributes {
                innerText.bs_font = font
                innerText.bs_color = textColor
                innerText.bs_shadow = _shadowFromProperties()
                innerText.bs_alignment = textAlignment
                switch lineBreakMode {
                case NSLineBreakMode.byWordWrapping, NSLineBreakMode.byCharWrapping, NSLineBreakMode.byClipping:
                    innerText.bs_lineBreakMode = lineBreakMode
                case NSLineBreakMode.byTruncatingHead, NSLineBreakMode.byTruncatingTail, NSLineBreakMode.byTruncatingMiddle:
                    innerText.bs_lineBreakMode = NSLineBreakMode.byWordWrapping
                default:
                    break
                }
            }
            if let t = textParser, t.parseText(innerText, selectedRange: nil) {
                _updateOuterTextProperties()
            }
            if !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _text
        }
    }
    
    private lazy var _font = BSLabel._defaultFont
    /**
     The font of the text. Default is 17-point system font.
     Set a new value to this property also causes the new font to be applied to the entire `attributedText`.
     Get the value returns the font at the head of `attributedText`.
     */
    @objc open var font: UIFont? {
        set {
            let f = newValue ?? BSLabel._defaultFont
            if _font == f { return }
            _font = f
            innerText.bs_font = _font
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _font
        }
    }
    
    private var _textColor = UIColor.black
    
    /**
     The color of the text. Default is black.
     Set a new value to this property also causes the new color to be applied to the entire `attributedText`.
     Get the value returns the color at the head of `attributedText`.
     */
    @objc open var textColor: UIColor {
        set {
            if _textColor == newValue {
                return
            }
            _textColor = newValue
            innerText.bs_color = _textColor
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
            }
        }
        get {
            return _textColor
        }
    }
    
    private var _shadowColor: UIColor?
    
    /**
     The shadow color of the text. Default is nil.
     Set a new value to this property also causes the shadow color to be applied to the entire `attributedText`.
     Get the value returns the shadow color at the head of `attributedText`.
     */
    @objc open var shadowColor: UIColor? {
        set {
            if (_shadowColor == newValue) {
                return
            }
            _shadowColor = newValue
            innerText.bs_shadow = _shadowFromProperties()
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
            }
        }
        get {
            return _shadowColor
        }
    }
    
    private var _shadowOffset = CGSize.zero
    /**
     The shadow offset of the text. Default is CGSizeZero.
     Set a new value to this property also causes the shadow offset to be applied to the entire `attributedText`.
     Get the value returns the shadow offset at the head of `attributedText`.
     */
    @objc open var shadowOffset: CGSize {
        set {
            if _shadowOffset == newValue {
                return
            }
            _shadowOffset = newValue
            innerText.bs_shadow = _shadowFromProperties()
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
            }
        }
        get {
            return _shadowOffset
        }
    }
    
    private var _shadowBlurRadius: CGFloat = 0
    /**
     The shadow blur of the text. Default is 0.
     Set a new value to this property also causes the shadow blur to be applied to the entire `attributedText`.
     Get the value returns the shadow blur at the head of `attributedText`.
     */
    @objc open var shadowBlurRadius: CGFloat {
        set {
            if _shadowBlurRadius == newValue {
                return
            }
            _shadowBlurRadius = newValue
            innerText.bs_shadow = _shadowFromProperties()
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
            }
        }
        get {
            return _shadowBlurRadius
        }
    }
    
    private var _textAlignment = NSTextAlignment.natural
    /**
     The technique to use for aligning the text. Default is NSTextAlignmentNatural.
     Set a new value to this property also causes the new alignment to be applied to the entire `attributedText`.
     Get the value returns the alignment at the head of `attributedText`.
     */
    @objc open var textAlignment: NSTextAlignment {
        set {
            if _textAlignment == newValue {
                return
            }
            _textAlignment = newValue
            innerText.bs_alignment = _textAlignment
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _textAlignment
        }
    }
    /**
     The text vertical aligmnent in container. Default is TextVerticalAlignment.center.
     */
    @objc open var textVerticalAlignment = TextVerticalAlignment.center {
        didSet {
            if self.textVerticalAlignment == oldValue {
                return
            }
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    private var _attributedText: NSAttributedString?
    
    /**
     The styled text displayed by the label.
     Set a new value to this property also replaces the value of the `text`, `font`, `textColor`,
     `textAlignment` and other properties in label.
     
     @discussion It only support the attributes declared in CoreText and TextAttribute.
     See `NSAttributedStringExtension.swift` for more convenience methods to set the attributes.
     */
    @objc open var attributedText: NSAttributedString? {
        set {
            if _attributedText == newValue {
                return
            }
            if let n = newValue, n.length > 0 {
                innerText = NSMutableAttributedString(attributedString: n)
                switch lineBreakMode {
                case NSLineBreakMode.byWordWrapping, NSLineBreakMode.byCharWrapping, NSLineBreakMode.byClipping:
                    innerText.bs_lineBreakMode = lineBreakMode
                case NSLineBreakMode.byTruncatingHead, NSLineBreakMode.byTruncatingTail, NSLineBreakMode.byTruncatingMiddle:
                    innerText.bs_lineBreakMode = NSLineBreakMode.byWordWrapping
                default:
                    break
                }
            } else {
                innerText = NSMutableAttributedString()
            }
            textParser?.parseText(innerText, selectedRange: nil)
            if !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _updateOuterTextProperties()
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _attributedText
        }
    }
    
    private var _lineBreakMode = NSLineBreakMode.byTruncatingTail
    /**
     The technique to use for wrapping and truncating the label's text.
     Default is NSLineBreakByTruncatingTail.
     */
    @objc open var lineBreakMode: NSLineBreakMode {
        set {
            if _lineBreakMode == newValue {
                return
            }
            _lineBreakMode = newValue
            innerText.bs_lineBreakMode = _lineBreakMode
            // allow multi-line break
            switch _lineBreakMode {
            case .byWordWrapping, .byCharWrapping, .byClipping:
                innerContainer.truncationType = .none
                innerText.bs_lineBreakMode = _lineBreakMode
            case .byTruncatingHead:
                innerContainer.truncationType = .start
                innerText.bs_lineBreakMode = NSLineBreakMode.byWordWrapping
            case .byTruncatingTail:
                innerContainer.truncationType = .end
                innerText.bs_lineBreakMode = NSLineBreakMode.byWordWrapping
            case .byTruncatingMiddle:
                innerContainer.truncationType = .middle
                innerText.bs_lineBreakMode = NSLineBreakMode.byWordWrapping
            default:
                break
            }
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _lineBreakMode
        }
    }
    
    private var _truncationToken: NSAttributedString?
    /**
     The truncation token string used when text is truncated. Default is nil.
     When the value is nil, the label use "…" as default truncation token.
     */
    @objc open var truncationToken: NSAttributedString? {
        set {
            if _truncationToken == newValue {
                return
            }
            _truncationToken = newValue
            innerContainer.truncationToken = _truncationToken
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _truncationToken
        }
    }
    
    private var _numberOfLines: Int = 1
    /**
     The maximum number of lines to use for rendering text. Default value is 1.
     0 means no limit.
     */
    @objc open var numberOfLines: Int {
        set {
            if _numberOfLines == newValue {
                return
            }
            _numberOfLines = newValue
            innerContainer.maximumNumberOfRows = _numberOfLines
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _numberOfLines
        }
    }
    /**
     When `text` or `attributedText` is changed, the parser will be called to modify the text.
     It can be used to add code highlighting or emoticon replacement to text view.
     The default value is nil.
     
     See `TextParser` protocol for more information.
     */
    @objc open var textParser: TextParser? {
        didSet {
            if self.textParser === oldValue {
                return
            }
            if self.textParser?.parseText(innerText, selectedRange: nil) ?? false {
                _updateOuterTextProperties()
                if !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }
    /**
     The current text layout in text view. It can be used to query the text layout information.
     Set a new value to this property also replaces most properties in this label, such as `text`,
     `color`, `attributedText`, `lineBreakMode`, `textContainerPath`, `exclusionPaths` and so on.
     */
    @objc open var textLayout: TextLayout? {
        set {
            innerLayout = newValue
            shrinkInnerLayout = nil
            
            if ignoreCommonProperties {
                innerText = newValue!.text as? NSMutableAttributedString ?? NSMutableAttributedString()
                innerContainer = newValue!.container.copy() as! TextContainer
            } else {
                innerText = (newValue?.text != nil) ? NSMutableAttributedString(attributedString: newValue!.text!) : NSMutableAttributedString()
                
                _updateOuterTextProperties()
                
                if let t = newValue?.container.copy() as! TextContainer? {
                    innerContainer = t
                } else {
                    innerContainer = TextContainer()
                    innerContainer.size = bounds.size
                    innerContainer.insets = textContainerInset
                }
                _updateOuterContainerProperties()
            }
            
            if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                _clearContents()
            }
            state.layoutNeedUpdate = false
            _setLayoutNeedRedraw()
            _endTouch()
            invalidateIntrinsicContentSize()
        }
        get {
            _updateIfNeeded()
            return innerLayout
        }
    }
    // MARK: - Configuring the Text Container
    
    ///=============================================================================
    /// @name Configuring the Text Container
    ///=============================================================================
    
    private var _textContainerPath: UIBezierPath?
    /**
     A UIBezierPath object that specifies the shape of the text frame. Default value is nil.
     */
    @objc open var textContainerPath: UIBezierPath? {
        set {
            if _textContainerPath == newValue { return }
            
            _textContainerPath = newValue
            innerContainer.path = _textContainerPath
            if textContainerPath == nil {
                innerContainer.size = bounds.size
                innerContainer.insets = textContainerInset
            }
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _textContainerPath
        }
    }
    
    private var _exclusionPaths: [UIBezierPath]?
    /**
     An array of UIBezierPath objects representing the exclusion paths inside the
     receiver's bounding rectangle. Default value is nil.
     */
    @objc open var exclusionPaths: [UIBezierPath]? {
        set {
            if _exclusionPaths == newValue { return }
            
            _exclusionPaths = newValue
            if let aPaths = _exclusionPaths {
                innerContainer.exclusionPaths = aPaths
            }
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _exclusionPaths
        }
    }
    
    private var _textContainerInset = UIEdgeInsets.zero
    /**
     The inset of the text container's layout area within the text view's content area.
     Default value is UIEdgeInsetsZero.
     */
    @objc open var textContainerInset: UIEdgeInsets {
        set {
            if _textContainerInset == newValue { return }
            
            _textContainerInset = newValue
            innerContainer.insets = _textContainerInset
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _textContainerInset
        }
    }
    
    private var _verticalForm = false
    /**
     Whether the receiver's layout orientation is vertical form. Default is false.
     It may used to display CJK text.
     */
    @objc open var verticalForm: Bool {
        set {
            if _verticalForm == newValue { return }
            
            _verticalForm = newValue
            innerContainer.isVerticalForm = _verticalForm
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _verticalForm
        }
    }
    
    private var _linePositionModifier: TextLinePositionModifier?
    /**
     The text line position modifier used to modify the lines' position in layout.
     Default value is nil.
     See `TextLinePositionModifier` protocol for more information.
     */
    @objc open weak var linePositionModifier: TextLinePositionModifier? {
        set {
            if _linePositionModifier === newValue { return }
            
            _linePositionModifier = newValue
            innerContainer.linePositionModifier = _linePositionModifier
            if innerText.length != 0 && !ignoreCommonProperties {
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedUpdate()
                _endTouch()
                invalidateIntrinsicContentSize()
            }
        }
        get {
            return _linePositionModifier
        }
    }
    
    private var _debugOption: TextDebugOption? = TextDebugOption.shared
    
    /**
     The debug option to display CoreText layout result.
     The default value is TextDebugOption.shared.
     */
    @objc open var debugOption: TextDebugOption? {
        set {
            let needDraw = _debugOption?.needDrawDebug
            _debugOption = newValue?.copy() as? TextDebugOption
            if _debugOption?.needDrawDebug != needDraw {
                _setLayoutNeedRedraw()
            }
        }
        get {
            return _debugOption
        }
    }
    // MARK: - Getting the Layout Constraints
    
    ///=============================================================================
    /// @name Getting the Layout Constraints
    ///=============================================================================
    
    /**
     The preferred maximum width (in points) for a multiline label.
     
     @discussion This property affects the size of the label when layout constraints
     are applied to it. During layout, if the text extends beyond the width
     specified by this property, the additional text is flowed to one or more new
     lines, thereby increasing the height of the label. If the text is vertical
     form, this value will match to text height.
     */
    @objc open var preferredMaxLayoutWidth: CGFloat = 0 {
        didSet {
            if self.preferredMaxLayoutWidth == oldValue {
                return
            }
            invalidateIntrinsicContentSize()
        }
    }
    // MARK: - Interacting with Text Data
    
    ///=============================================================================
    /// @name Interacting with Text Data
    ///=============================================================================
    
    /**
     When user tap the label, this action will be called (similar to tap gesture).
     The default value is nil.
     */
    @objc open var textTapAction: TextAction?
    /**
     When user long press the label, this action will be called (similar to long press gesture).
     The default value is nil.
     */
    @objc open var textLongPressAction: TextAction?
    /**
     When user tap the highlight range of text, this action will be called.
     The default value is nil.
     */
    @objc open var highlightTapAction: TextAction?
    /**
     When user long press the highlight range of text, this action will be called.
     The default value is nil.
     */
    @objc open var highlightLongPressAction: TextAction?
    // MARK: - Configuring the Display Mode
    
    ///=============================================================================
    /// @name Configuring the Display Mode
    ///=============================================================================
    
    /**
     A Boolean value indicating whether the layout and rendering codes are running
     asynchronously on background threads.
     
     The default value is `false`.
     */
    @objc open var displaysAsynchronously = false {
        didSet {
            (layer as? TextAsyncLayer)?.displaysAsynchronously = displaysAsynchronously
        }
    }
    
    /**
     If the value is true, and the layer is rendered asynchronously, then it will
     set label.layer.contents to nil before display.
     
     The default value is `true`.
     
     @discussion When the asynchronously display is enabled, the layer's content will
     be updated after the background render process finished. If the render process
     can not finished in a vsync time (1/60 second), the old content will be still kept
     for display. You may manually clear the content by set the layer.contents to nil
     after you update the label's properties, or you can just set this property to true.
     */
    @objc open var clearContentsBeforeAsynchronouslyDisplay = true
    
    /**
     If the value is true, and the layer is rendered asynchronously, then it will add
     a fade animation on layer when the contents of layer changed.
     
     The default value is `true`.
     */
    @objc open var fadeOnAsynchronouslyDisplay = true
    
    /**
     If the value is true, then it will add a fade animation on layer when some range
     of text become highlighted.
     
     The default value is `true`.
     */
    @objc open var fadeOnHighlight = true
    
    /**
     Ignore common properties (such as text, font, textColor, attributedText...) and
     only use "textLayout" to display content.
     
     The default value is `false`.
     
     @discussion If you control the label content only through "textLayout", then
     you may set this value to true for higher performance.
     */
    @objc open var ignoreCommonProperties = false
    
    /*
     Tips:
     
     1. If you only need a UILabel alternative to display rich text and receive link touch event,
     you do not need to adjust the display mode properties.
     
     2. If you have performance issues, you may enable the asynchronous display mode
     by setting the `displaysAsynchronously` to true.
     
     3. If you want to get the highest performance, you should do text layout with
     `TextLayout` class in background thread. Here's an example:
     
     let label = BSLabel()
     label.displaysAsynchronously = true
     label.ignoreCommonProperties = true
     
     DispatchQueue.global().async(execute: {
     
         // Create attributed string.
         let text = NSMutableAttributedString.init(string: "Some Text")
         text.bs_font = UIFont.systemFont(ofSize: 16)
         text.bs_color = .gray
         text.bs_set(color: .red, range: NSRange(location: 0, length: 4))
     
         // Create text container
         let container = TextContainer()
         container.size = CGSize(width: 100, height: CGFloat.greatestFiniteMagnitude)
         container.maximumNumberOfRows = 0
     
         // Generate a text layout.
         let layout = TextLayout(container: container, text: text)
     
         DispatchQueue.main.async(execute: {
     
             label.size = layout.textBoundingSize
             label.textLayout = layout
         })
     })
     
     */

    private lazy var innerText = NSMutableAttributedString() ///< nonnull
    private var innerLayout: TextLayout?
    private lazy var innerContainer = TextContainer() ///< nonnull
    private lazy var attachmentViews = [UIView]()
    private lazy var attachmentLayers = [CALayer]()
    private lazy var highlightRange = NSRange(location: 0, length: 0) ///< current highlight range
    private var highlight: TextHighlight? ///< highlight attribute in `_highlightRange`
    private var highlightLayout: TextLayout? ///< when _state.showingHighlight=YES, this layout should be displayed
    private var shrinkInnerLayout: TextLayout?
    private var shrinkHighlightLayout: TextLayout?
    private var longPressTimer: Timer?
    private var touchBeganPoint = CGPoint.zero
    
    private lazy var state = State()
    
    private struct State {
        var layoutNeedUpdate : Bool = false
        var showingHighlight : Bool = false
        
        var trackingTouch : Bool = false
        var swallowTouch : Bool = false
        var touchMoved : Bool = false
        
        var hasTapAction : Bool = false
        var hasLongPressAction : Bool = false
        
        var contentsNeedFade : Bool = false
    }
    
    // MARK: - Private
    private func _updateIfNeeded() {
        if state.layoutNeedUpdate {
            state.layoutNeedUpdate = false
            _updateLayout()
            layer.setNeedsDisplay()
        }
    }
    
    private func _updateLayout() {
        innerLayout = TextLayout(container: innerContainer, text: innerText)
        shrinkInnerLayout = BSLabel._shrinkLayout(with: innerLayout)
    }
    
    private func _setLayoutNeedUpdate() {
        state.layoutNeedUpdate = true
        _clearInnerLayout()
        _setLayoutNeedRedraw()
    }
    
    private func _setLayoutNeedRedraw() {
        layer.setNeedsDisplay()
    }
    
    private func _clearInnerLayout() {
        if innerLayout == nil {
            return
        }
        let layout: TextLayout? = innerLayout
        innerLayout = nil
        shrinkInnerLayout = nil
        BSLabelGetReleaseQueue.async(execute: {
            let text: NSAttributedString? = layout?.text // capture to block and release in background
            if let c = layout?.attachments?.count, c != 0 {
                DispatchQueue.main.async(execute: {
                    let _ = text?.length // capture to block and release in main thread (maybe there's UIView/CALayer attachments).
                })
            }
        })
    }
    
    private func _innerLayout() -> TextLayout? {
        return (shrinkInnerLayout != nil) ? shrinkInnerLayout : innerLayout
    }
    
    private func _highlightLayout() -> TextLayout? {
        return (shrinkHighlightLayout != nil) ? shrinkHighlightLayout : highlightLayout
    }
    
    private class func _shrinkLayout(with layout: TextLayout?) -> TextLayout? {
        guard let layout = layout else {
            return nil
        }
        guard let t = layout.text, t.length > 0, layout.lines.count == 0 else {
            return nil
        }
        
        let container = layout.container.copy() as! TextContainer
        container.maximumNumberOfRows = 1
        var containerSize = container.size
        if container.isVerticalForm == false {
            containerSize.height = TextContainer.textContainerMaxSize.height
        } else {
            containerSize.width = TextContainer.textContainerMaxSize.width
        }
        container.size = containerSize
        return TextLayout(container: container, text: layout.text)
    }
    
    private func _startLongPressTimer() {
        longPressTimer?.invalidate()
        
        longPressTimer = Timer.bs_scheduledTimer(with: kLongPressMinimumDuration, target: self, selector: #selector(self._trackDidLongPress), userInfo: nil, repeats: false)
        RunLoop.current.add(longPressTimer!, forMode: .common)
    }
    
    private func _endLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
    
    @objc private func _trackDidLongPress() {
        _endLongPressTimer()
        if state.hasLongPressAction && (textLongPressAction != nil) {
            var range = NSRange(location: NSNotFound, length: 0)
            var rect = CGRect.null
            let point: CGPoint = _convertPoint(toLayout: touchBeganPoint)
            let textRange: TextRange? = innerLayout?.textRange(at: point)
            var textRect: CGRect = innerLayout?.rect(for: textRange) ?? CGRect.zero
            textRect = _convertRect(fromLayout: textRect)
            if textRange != nil {
                if let aRange = textRange?.asRange {
                    range = aRange
                }
                rect = textRect
            }
            textLongPressAction?(self, innerText, range, rect)
        }
        if (highlight != nil) {
            let longPressAction: TextAction? = (highlight!.longPressAction != nil) ? highlight!.longPressAction : highlightLongPressAction
            if longPressAction != nil {
                let start = TextPosition.position(with: highlightRange.location)
                let end = TextPosition.position(with: highlightRange.location + highlightRange.length, affinity: TextAffinity.backward)
                let range = TextRange.range(with: start, end: end)
                var rect: CGRect = innerLayout!.rect(for: range)
                rect = _convertRect(fromLayout: rect)
                longPressAction!(self, innerText, highlightRange, rect)
                _removeHighlight(animated: true)
                state.trackingTouch = false
            }
        }
    }
    
    private func _getHighlight(at point: CGPoint, range: NSRangePointer?) -> TextHighlight? {
        var point = point
        
        guard let c = innerLayout?.containsHighlight, c else {
            return nil
        }
        point = _convertPoint(toLayout: point)
        
        guard let textRange = innerLayout?.textRange(at: point) else {
            return nil
        }
        
        var startIndex = textRange.start.offset
        if startIndex == innerText.length {
            if startIndex > 0 {
                startIndex = startIndex - 1
            }
        }
        let highlightRange = NSRangePointer.allocate(capacity: 1)
        defer {
            highlightRange.deallocate()
        }
        
        guard let highlight = innerText.attribute(NSAttributedString.Key(rawValue: TextAttribute.textHighlightAttributeName), at: startIndex, longestEffectiveRange: highlightRange, in: NSRange(location: 0, length: innerText.length)) as? TextHighlight else {
            return nil
        }
        
        range?.pointee = highlightRange.pointee
        
        return highlight
    }
    
    private func _showHighlight(animated: Bool) {
        if highlight == nil { return }
        if highlightLayout == nil {
            let hiText = innerText.mutableCopy() as! NSMutableAttributedString
            let newAttrs = highlight?.attributes
            for (key, value) in newAttrs ?? [:] {
                hiText.bs_set(attribute: key, value: value, range: highlightRange)
            }
            highlightLayout = TextLayout(container: innerContainer, text: hiText)
            shrinkHighlightLayout = BSLabel._shrinkLayout(with: highlightLayout)
            if highlightLayout == nil {
                highlight = nil
            }
        }
        
        if (highlightLayout != nil) && !state.showingHighlight {
            state.showingHighlight = true
            state.contentsNeedFade = animated
            _setLayoutNeedRedraw()
        }
    }
    
    private func _hideHighlight(animated: Bool) {
        if state.showingHighlight {
            state.showingHighlight = false
            state.contentsNeedFade = animated
            _setLayoutNeedRedraw()
        }
    }
    
    private func _removeHighlight(animated: Bool) {
        _hideHighlight(animated: animated)
        highlight = nil
        highlightLayout = nil
        shrinkHighlightLayout = nil
    }
    
    private func _endTouch() {
        _endLongPressTimer()
        _removeHighlight(animated: true)
        state.trackingTouch = false
    }
    
    private func _convertPoint(toLayout point: CGPoint) -> CGPoint {
        var point = point
        let boundingSize: CGSize = innerLayout!.textBoundingSize
        if let v = innerLayout?.container.isVerticalForm, v {
            var w = innerLayout!.textBoundingSize.width
            if w < bounds.size.width {
                w = bounds.size.width
            }
            point.x += innerLayout!.container.size.width - w
            if textVerticalAlignment == TextVerticalAlignment.center {
                point.x += (bounds.size.width - boundingSize.width) * 0.5
            } else if textVerticalAlignment == TextVerticalAlignment.bottom {
                point.x += bounds.size.width - boundingSize.width
            }
            return point
        } else {
            if textVerticalAlignment == TextVerticalAlignment.center {
                point.y -= (bounds.size.height - boundingSize.height) * 0.5
            } else if textVerticalAlignment == TextVerticalAlignment.bottom {
                point.y -= bounds.size.height - boundingSize.height
            }
            return point
        }
    }
    
    private func _convertPoint(fromLayout point: CGPoint) -> CGPoint {
        var point = point
        let boundingSize: CGSize = innerLayout!.textBoundingSize
        if let v = innerLayout?.container.isVerticalForm, v {
            var w = innerLayout!.textBoundingSize.width
            if w < bounds.size.width {
                w = bounds.size.width
            }
            point.x -= innerLayout!.container.size.width - w
            if boundingSize.width < bounds.size.width {
                if textVerticalAlignment == TextVerticalAlignment.center {
                    point.x -= (bounds.size.width - boundingSize.width) * 0.5
                } else if textVerticalAlignment == TextVerticalAlignment.bottom {
                    point.x -= bounds.size.width - boundingSize.width
                }
            }
            return point
        } else {
            if boundingSize.height < bounds.size.height {
                if textVerticalAlignment == TextVerticalAlignment.center {
                    point.y += (bounds.size.height - boundingSize.height) * 0.5
                } else if textVerticalAlignment == TextVerticalAlignment.bottom {
                    point.y += bounds.size.height - boundingSize.height
                }
            }
            return point
        }
    }
    
    private func _convertRect(toLayout rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin = _convertPoint(toLayout: rect.origin)
        return rect
    }
    
    private func _convertRect(fromLayout rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin = _convertPoint(fromLayout: rect.origin)
        return rect
    }
    
    private static let _defaultFont = UIFont.systemFont(ofSize: 17)
    
    private func _shadowFromProperties() -> NSShadow? {
        if !(shadowColor != nil) || shadowBlurRadius < 0 {
            return nil
        }
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        #if !TARGET_INTERFACE_BUILDER
        shadow.shadowOffset = shadowOffset
        #else
        shadow.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        #endif
        shadow.shadowBlurRadius = shadowBlurRadius
        return shadow
    }
    
    private func _updateOuterLineBreakMode() {
        if innerContainer.truncationType != .none {
            switch innerContainer.truncationType {
            case .start:
                _lineBreakMode = NSLineBreakMode.byTruncatingHead
            case .end:
                _lineBreakMode = NSLineBreakMode.byTruncatingTail
            case .middle:
                _lineBreakMode = NSLineBreakMode.byTruncatingMiddle
            default:
                break
            }
        } else {
            _lineBreakMode = innerText.bs_lineBreakMode
        }
    }
    
    private func _updateOuterTextProperties() {
        
        _text = innerText.bs_plainText(for: NSRange(location: 0, length: innerText.length))
        _font = innerText.bs_font ?? BSLabel._defaultFont
        _textColor = innerText.bs_color ?? UIColor.black
        
        _textAlignment = innerText.bs_alignment
        _lineBreakMode = innerText.bs_lineBreakMode
        let shadow: NSShadow? = innerText.bs_shadow
        _shadowColor = shadow?.shadowColor as! UIColor?
        // TARGET_INTERFACE_BUILDER
        _shadowOffset = shadow?.shadowOffset ?? .zero
        
        _shadowBlurRadius = shadow?.shadowBlurRadius ?? 0
        _attributedText = innerText
        _updateOuterLineBreakMode()
    }
    
    private func _updateOuterContainerProperties() {
        _truncationToken = innerContainer.truncationToken
        _numberOfLines = innerContainer.maximumNumberOfRows
        _textContainerPath = innerContainer.path
        _exclusionPaths = innerContainer.exclusionPaths
        _textContainerInset = innerContainer.insets
        _verticalForm = innerContainer.isVerticalForm
        _linePositionModifier = innerContainer.linePositionModifier
        _updateOuterLineBreakMode()
    }
    
    private func _clearContents() {
        let image = layer.contents as! CGImage?
        layer.contents = nil
        if image != nil {
            BSLabelGetReleaseQueue.async(execute: {
                let _ = image
            })
        }
    }
    
    private func _initLabel() {
        (layer as? TextAsyncLayer)?.displaysAsynchronously = false
        layer.contentsScale = UIScreen.main.scale
        contentMode = .redraw
        
        TextDebugOption.add(self)
        
        innerContainer.truncationType = .end
        innerContainer.maximumNumberOfRows = numberOfLines
        
        isAccessibilityElement = true
    }

    // MARK: - Override
    
    override public init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        isOpaque = false
        _initLabel()
        self.frame = frame
    }
    
    deinit {
        TextDebugOption.remove(self)
        longPressTimer?.invalidate()
    }
    
    override open class var layerClass: AnyClass {
        return TextAsyncLayer.self
    }
    
    open override var frame: CGRect {
        set {
            let oldSize: CGSize = bounds.size
            super.frame = newValue
            let newSize: CGSize = bounds.size
            if oldSize != newSize {
                innerContainer.size = bounds.size
                if !ignoreCommonProperties {
                    state.layoutNeedUpdate = true
                }
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedRedraw()
            }
        }
        get {
            return super.frame
        }
    }
    
    open override var bounds: CGRect {
        set {
            let oldSize: CGSize = self.bounds.size
            super.bounds = newValue
            let newSize: CGSize = self.bounds.size
            if oldSize != newSize {
                innerContainer.size = self.bounds.size
                if !ignoreCommonProperties {
                    state.layoutNeedUpdate = true
                }
                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    _clearContents()
                }
                _setLayoutNeedRedraw()
            }
        }
        get {
            return super.bounds
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        if ignoreCommonProperties {
            return innerLayout!.textBoundingSize
        }
        
        if !verticalForm && size.width <= 0 {
            size.width = TextContainer.textContainerMaxSize.width
        } else if verticalForm && size.height <= 0 {
            size.height = TextContainer.textContainerMaxSize.height
        }
        
        if (!verticalForm && size.width == bounds.size.width) || (verticalForm && size.height == bounds.size.height) {
            _updateIfNeeded()
            let layout: TextLayout? = innerLayout
            var contains = false
            if layout?.container.maximumNumberOfRows == 0 {
                if layout?.truncatedLine == nil {
                    contains = true
                }
            } else {
                if layout?.rowCount ?? 0 <= (layout?.container.maximumNumberOfRows ?? 0) {
                    contains = true
                }
            }
            if contains {
                return layout?.textBoundingSize ?? CGSize.zero
            }
        }
        
        if !verticalForm {
            size.height = TextContainer.textContainerMaxSize.height
        } else {
            size.width = TextContainer.textContainerMaxSize.width
        }
        
        let container = innerContainer.copy() as? TextContainer
        container?.size = size
        
        let layout = TextLayout(container: container, text: innerText)
        return layout?.textBoundingSize ?? .zero
    }
    
    func accessibilityLabel() -> String? {
        return innerLayout?.text?.bs_plainText(for: innerLayout?.text?.bs_rangeOfAll ?? NSRange(location: 0, length: 0))
    }
    
    // MARK: - NSCoding
    
    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(_attributedText, forKey: "attributedText")
        aCoder.encode(innerContainer, forKey: "innerContainer")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _initLabel()
        
        if let innerContainer = aDecoder.decodeObject(forKey: "innerContainer") as? TextContainer {
            self.innerContainer = innerContainer
        } else {
            self.innerContainer.size = bounds.size
        }
        _updateOuterContainerProperties()
        self.attributedText = aDecoder.decodeObject(forKey: "attributedText") as? NSAttributedString
        _setLayoutNeedUpdate()
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - Touches
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _updateIfNeeded()
        let touch = touches.first!
        let point = touch.location(in: self)
        
        highlight = _getHighlight(at: point, range: &highlightRange)
        highlightLayout = nil
        shrinkHighlightLayout = nil
        state.hasTapAction = (textTapAction != nil)
        state.hasLongPressAction = (textLongPressAction != nil)
        
        if (highlight != nil) || (textTapAction != nil) || (textLongPressAction != nil) {
            touchBeganPoint = point
            state.trackingTouch = true
            state.swallowTouch = true
            state.touchMoved = false
            _startLongPressTimer()
            if (highlight != nil) {
                _showHighlight(animated: false)
            }
        } else {
            state.trackingTouch = false
            state.swallowTouch = false
            state.touchMoved = false
        }
        if !state.swallowTouch {
            super.touchesBegan(touches, with: event)
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        _updateIfNeeded()
        
        let touch = touches.first!
        let point = touch.location(in: self)
        
        if state.trackingTouch {
            if !state.touchMoved {
                let moveH = Float(point.x - touchBeganPoint.x)
                let moveV = Float(point.y - touchBeganPoint.y)
                if abs(moveH) > abs(moveV) {
                    if abs(moveH) > kLongPressAllowableMovement {
                        state.touchMoved = true
                    }
                } else {
                    if abs(moveV) > kLongPressAllowableMovement {
                        state.touchMoved = true
                    }
                }
                if state.touchMoved {
                    _endLongPressTimer()
                }
            }
            if state.touchMoved && self.highlight != nil {
                let highlight = _getHighlight(at: point, range: nil)
                if highlight == self.highlight {
                    _showHighlight(animated: fadeOnHighlight)
                } else {
                    _hideHighlight(animated: fadeOnHighlight)
                }
            }
        }
        
        if !state.swallowTouch {
            super.touchesMoved(touches, with: event)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        
        if state.trackingTouch {
            _endLongPressTimer()
            if !state.touchMoved && (textTapAction != nil) {
                var range = NSRange(location: NSNotFound, length: 0)
                var rect = CGRect.null
                let point: CGPoint = _convertPoint(toLayout: touchBeganPoint)
                let textRange: TextRange? = innerLayout?.textRange(at: point)
                var textRect: CGRect = innerLayout!.rect(for: textRange)
                textRect = _convertRect(fromLayout: textRect)
                if textRange != nil {
                    if let aRange = textRange?.asRange {
                        range = aRange
                    }
                    rect = textRect
                }
                textTapAction?(self, innerText, range, rect)
            }
            
            if (highlight != nil) {
                if !state.touchMoved || _getHighlight(at: point, range: nil) == highlight {
                    if let tapAction = highlight?.tapAction != nil ? highlight!.tapAction : highlightTapAction {
                        let start = TextPosition.position(with: highlightRange.location)
                        let end = TextPosition.position(with: highlightRange.location + highlightRange.length, affinity: .backward)
                        let range = TextRange.range(with: start, end: end)
                        var rect: CGRect = innerLayout!.rect(for: range)
                        rect = _convertRect(fromLayout: rect)
                        tapAction(self, innerText, highlightRange, rect)
                    }
                }
                _removeHighlight(animated: fadeOnHighlight)
            }
        }
        
        if !state.swallowTouch {
            super.touchesEnded(touches, with: event)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        _endTouch()
        if !state.swallowTouch {
            super.touchesCancelled(touches, with: event)
        }
    }
    
    // MARK: - AutoLayout
    
    override open var intrinsicContentSize: CGSize {
        if preferredMaxLayoutWidth == 0 {
            let container = innerContainer.copy() as! TextContainer
            container.size = TextContainer.textContainerMaxSize
            
            let layout = TextLayout(container: container, text: innerText)
            return layout!.textBoundingSize
        }
        
        var containerSize: CGSize = innerContainer.size
        if !verticalForm {
            containerSize.height = TextContainer.textContainerMaxSize.height
            containerSize.width = preferredMaxLayoutWidth
            if containerSize.width == 0 {
                containerSize.width = bounds.size.width
            }
        } else {
            containerSize.width = TextContainer.textContainerMaxSize.width
            containerSize.height = preferredMaxLayoutWidth
            if containerSize.height == 0 {
                containerSize.height = bounds.size.height
            }
        }
        
        let container = innerContainer.copy() as! TextContainer
        container.size = containerSize
        
        let layout = TextLayout(container: container, text: innerText)
        return layout!.textBoundingSize
    }
    
    // MARK: - TextAsyncLayerDelegate
    
    public func newAsyncDisplayTask() -> TextAsyncLayerDisplayTask? {
        
        // capture current context
        let contentsNeedFade_ = state.contentsNeedFade
        var text_: NSAttributedString = innerText
        var container_: TextContainer? = innerContainer
        let verticalAlignment_: TextVerticalAlignment = textVerticalAlignment
        let debug_: TextDebugOption? = debugOption
        
        let layoutNeedUpdate_ = state.layoutNeedUpdate
        let fadeForAsync_: Bool = displaysAsynchronously && fadeOnAsynchronouslyDisplay
        var layout_: TextLayout? = (state.showingHighlight && (highlightLayout != nil)) ? _highlightLayout() : _innerLayout()
        var shrinkLayout_: TextLayout? = nil
        var layoutUpdated_ = false
        if layoutNeedUpdate_ {
            text_ = text_.copy() as! NSAttributedString
            container_ = container_?.copy() as! TextContainer?
        }
        
//        weak var weakSelf = self
        
        // create display task
        let task = TextAsyncLayerDisplayTask()
        
        task.willDisplay = { layer in
            layer?.removeAnimation(forKey: "contents")
            
            // If the attachment is not in new layout, or we don't know the new layout currently,
            // the attachment should be removed.
            for view: UIView in self.attachmentViews {
                if layoutNeedUpdate_ || !(layout_?.attachmentContentsSet!.contains(view) ?? false) {
                    if view.superview == self {
                        view.removeFromSuperview()
                    }
                }
            }
            for layer: CALayer in self.attachmentLayers {
                if layoutNeedUpdate_ || !(layout_?.attachmentContentsSet!.contains(layer) ?? false) {
                    if layer.superlayer == self.layer {
                        layer.removeFromSuperlayer()
                    }
                }
            }
            self.attachmentViews.removeAll()
            self.attachmentLayers.removeAll()
        }
        
        task.display = { context, size, isCancelled in
            if isCancelled() {
                return
            }
            guard text_.length > 0 else {
                return
            }
            
            var drawLayout: TextLayout? = layout_
            if layoutNeedUpdate_ {
                layout_ = TextLayout(container: container_, text: text_)
                shrinkLayout_ = BSLabel._shrinkLayout(with: layout_)
                if isCancelled() {
                    return
                }
                layoutUpdated_ = true
                drawLayout = (shrinkLayout_ != nil) ? shrinkLayout_ : layout_
            }
            
            let boundingSize: CGSize = drawLayout?.textBoundingSize ?? .zero
            var point = CGPoint.zero
            if verticalAlignment_ == TextVerticalAlignment.center {
                if let v = drawLayout?.container.isVerticalForm, v {
                    point.x = -(size.width - boundingSize.width) * 0.5
                } else {
                    point.y = (size.height - boundingSize.height) * 0.5
                }
            } else if verticalAlignment_ == TextVerticalAlignment.bottom {
                if let v = drawLayout?.container.isVerticalForm, v {
                    point.x = -(size.width - boundingSize.width)
                } else {
                    point.y = size.height - boundingSize.height
                }
            }
            point = TextUtilities.TextCGPoint(pixelRound: point)
            drawLayout?.draw(in: context, size: size, point: point, view: nil, layer: nil, debug: debug_, cancel: isCancelled)
        }
        
        task.didDisplay = { layer, finished in
            var drawLayout = layout_
            if layoutUpdated_ && (shrinkLayout_ != nil) {
                drawLayout = shrinkLayout_
            }
            if !finished {
                // If the display task is cancelled, we should clear the attachments.
                for a: TextAttachment in drawLayout?.attachments ?? [] {
                    if (a.content is UIView) {
                        if (a.content as? UIView)?.superview === layer.delegate {
                            (a.content as? UIView)?.removeFromSuperview()
                        }
                    } else if (a.content is CALayer) {
                        if (a.content as? CALayer)?.superlayer == layer {
                            (a.content as? CALayer)?.removeFromSuperlayer()
                        }
                    }
                }
                return
            }
            layer.removeAnimation(forKey: "contents")
            
            guard let view = layer.delegate as? BSLabel else {
                return
            }
            if view.state.layoutNeedUpdate && layoutUpdated_ {
                view.innerLayout = layout_
                view.shrinkInnerLayout = shrinkLayout_
                view.state.layoutNeedUpdate = false
            }
            
            let size = layer.bounds.size
            let boundingSize: CGSize = drawLayout?.textBoundingSize ?? .zero
            var point = CGPoint.zero
            if verticalAlignment_ == TextVerticalAlignment.center {
                if let v = drawLayout?.container.isVerticalForm, v {
                    point.x = -(size.width - boundingSize.width) * 0.5
                } else {
                    point.y = (size.height - boundingSize.height) * 0.5
                }
            } else if verticalAlignment_ == TextVerticalAlignment.bottom {
                if let v = drawLayout?.container.isVerticalForm, v {
                    point.x = -(size.width - boundingSize.width)
                } else {
                    point.y = size.height - boundingSize.height
                }
            }
            point = TextUtilities.TextCGPoint(pixelRound: point)
            drawLayout?.draw(in: nil, size: size, point: point, view: view, layer: layer, debug: nil, cancel: nil)
            for a in drawLayout?.attachments ?? [] {
                if (a.content is UIView) {
                    self.attachmentViews.append(a.content as! UIView)
                } else if (a.content is CALayer) {
                    self.attachmentLayers.append(a.content as! CALayer)
                }
            }
            
            if contentsNeedFade_ {
                let transition = CATransition()
                transition.duration = kHighlightFadeDuration
                transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                transition.type = .fade
                layer.add(transition, forKey: "contents")
            } else if fadeForAsync_ {
                let transition = CATransition()
                transition.duration = kAsyncFadeDuration
                transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                transition.type = .fade
                layer.add(transition, forKey: "contents")
            }
        }
        
        return task
    }
}
