import UIKit
import ImageIO
import MobileCoreServices

@objcMembers
open class BSTextAttachment: NSTextAttachment {
    
    public var attachmentType: BSTextAttachmentType = .image
    
    public var displaySize: CGSize = CGSize(width: 0, height: 0)
    
    public var state: State = .placeholder
    
    public var cacheKey: String?
    
    public var url: URL?
    
    public var placeholderImage: UIImage?
    
    public var failureImage: UIImage?
    
    public var tintColor: UIColor?
    
    public weak var delegate: BSTextAttachmentDelegate?
    
    private var loadingTask: Task<Void, Never>?
    
    @objc public enum State: Int {
        case placeholder = 0
        case loading = 1
        case loaded = 2
        case failed = 3
    }
    
    public override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        commonInit()
    }
    
    public init(type: BSTextAttachmentType) {
        super.init(data: nil, ofType: nil)
        self.attachmentType = type
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        if attachmentType == .image {
            displaySize = CGSize(width: 200, height: 200)
        }
    }
    
    open override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        guard state != .failed else {
            return failureImage ?? placeholderImage
        }
        
        if let image = super.image(forBounds: imageBounds, textContainer: textContainer, characterIndex: charIndex) {
            return applyTint(to: image)
        }
        
        if state == .placeholder || state == .loading {
            return applyTint(to: placeholderImage)
        }
        
        return nil
    }
    
    open override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if displaySize.width > 0 && displaySize.height > 0 {
            return CGRect(origin: .zero, size: displaySize)
        }
        
        if let image = image(forBounds: .zero, textContainer: textContainer, characterIndex: charIndex) {
            return CGRect(origin: .zero, size: image.size)
        }
        
        return super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
    }
    
    open func load() {
        cancelLoad()
        state = .loading
        delegate?.attachmentDidStartLoading?(self)
        
        loadingTask = Task { [weak self] in
            guard let self = self, let url = self.url else {
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if Task.isCancelled { return }
                
                if self.attachmentType == .image || self.attachmentType == .animatedImage {
                    if let image = UIImage(data: data) {
                        await self.completeLoading(with: image)
                    } else {
                        await self.completeLoading(with: nil)
                    }
                } else {
                    await self.completeLoading(with: nil)
                }
            } catch {
                await self.completeLoading(with: nil)
            }
        }
    }
    
    open func cancelLoad() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    private func completeLoading(with image: UIImage?) async {
        if let image = image {
            self.image = image
            self.state = .loaded
            self.delegate?.attachmentDidFinishLoading?(self)
        } else {
            self.state = .failed
            self.delegate?.attachmentDidFailLoading?(self)
        }
    }
    
    private func applyTint(to image: UIImage?) -> UIImage? {
        guard let image = image, let tintColor = tintColor else {
            return image
        }
        
        return image.withTintColor(tintColor)
    }
    
    deinit {
        cancelLoad()
    }
}

@objcMembers
open class BSTextAnimatedImageAttachment: BSTextAttachment {
    
    public private(set) var animatedImage: UIImage?
    public private(set) var totalDuration: TimeInterval = 0
    
    private var animator: BSTextAnimatedImageAnimator?
    
    public override init(type: BSTextAttachmentType) {
        super.init(type: type)
        if type == .animatedImage {
            displaySize = CGSize(width: 200, height: 200)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func loadAnimatedImage(from data: Data) {
        guard let image = UIImage(data: data), image.images?.count ?? 0 > 1 else {
            if let staticImage = UIImage(data: data) {
                self.image = staticImage
                self.animatedImage = staticImage
                self.state = .loaded
                delegate?.attachmentDidFinishLoading?(self)
            } else {
                self.state = .failed
                delegate?.attachmentDidFailLoading?(self)
            }
            return
        }
        
        self.animatedImage = image
        self.totalDuration = image.duration > 0 ? image.duration : Double(image.images?.count ?? 1) * 0.1
        self.image = image
        self.state = .loaded
        
        delegate?.attachmentDidFinishLoading?(self)
    }
    
    public func startAnimating() {
        guard let image = animatedImage, image.images?.count ?? 0 > 1 else { return }
        
        if animator == nil {
            animator = BSTextAnimatedImageAnimator(image: image)
        }
        animator?.start()
    }
    
    public func stopAnimating() {
        animator?.stop()
    }
    
    deinit {
        stopAnimating()
    }
}

class BSTextAnimatedImageAnimator {
    private weak var image: UIImage?
    private var displayLink: CADisplayLink?
    private var currentIndex: Int = 0
    private var elapsedTime: TimeInterval = 0
    
    init(image: UIImage) {
        self.image = image
    }
    
    func start() {
        guard displayLink == nil else { return }
        
        currentIndex = 0
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        currentIndex = 0
        elapsedTime = 0
    }
    
    @objc private func tick(_ displayLink: CADisplayLink) {
        guard let image = image, let frames = image.images, frames.count > 0 else {
            stop()
            return
        }
        
        let frameDuration = image.duration / Double(frames.count)
        elapsedTime += displayLink.duration
        
        if elapsedTime >= frameDuration {
            elapsedTime = 0
            currentIndex = (currentIndex + 1) % frames.count
        }
    }
}

@objc public protocol BSTextAttachmentDelegate: NSObjectProtocol {
    @objc optional func attachmentDidStartLoading(_ attachment: BSTextAttachment)
    @objc optional func attachmentDidFinishLoading(_ attachment: BSTextAttachment)
    @objc optional func attachmentDidFailLoading(_ attachment: BSTextAttachment)
}

public extension BSTextAttachment {
    
    static func imageAttachment(url: URL, displaySize: CGSize? = nil) -> BSTextAttachment {
        let attachment = BSTextAttachment(type: .image)
        attachment.url = url
        attachment.displaySize = displaySize ?? CGSize(width: 200, height: 200)
        return attachment
    }
    
    static func animatedImageAttachment(url: URL, displaySize: CGSize? = nil) -> BSTextAnimatedImageAttachment {
        let attachment = BSTextAnimatedImageAttachment(type: .animatedImage)
        attachment.url = url
        attachment.displaySize = displaySize ?? CGSize(width: 200, height: 200)
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                attachment.loadAnimatedImage(from: data)
                attachment.startAnimating()
            } catch {
                attachment.state = .failed
            }
        }
        
        return attachment
    }
    
    static func animatedImageAttachment(data: Data, displaySize: CGSize? = nil) -> BSTextAnimatedImageAttachment {
        let attachment = BSTextAnimatedImageAttachment(type: .animatedImage)
        attachment.displaySize = displaySize ?? CGSize(width: 200, height: 200)
        attachment.loadAnimatedImage(from: data)
        return attachment
    }
    
    static func emojiAttachment(emoji: String) -> BSTextAttachment {
        let attachment = BSTextAttachment(type: .image)
        let font = UIFont.systemFont(ofSize: 32)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let text = NSAttributedString(string: emoji, attributes: attributes)
        
        let size = text.size()
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        text.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        attachment.image = image
        attachment.state = .loaded
        attachment.displaySize = size
        
        return attachment
    }
    
    static func mentionAttachment(username: String, color: UIColor = .systemBlue) -> BSTextAttachment {
        let attachment = BSTextAttachment(type: .image)
        
        let text = "@\(username)"
        let font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .backgroundColor: color.withAlphaComponent(0.1)
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let size = attributedText.size()
        
        let insets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        let paddedSize = CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
        
        UIGraphicsBeginImageContextWithOptions(paddedSize, false, UIScreen.main.scale)
        color.withAlphaComponent(0.1).setFill()
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: paddedSize), cornerRadius: 4).fill()
        attributedText.draw(at: CGPoint(x: insets.left, y: insets.top))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        attachment.image = image
        attachment.state = .loaded
        attachment.displaySize = paddedSize
        
        return attachment
    }
    
    static func fileAttachment(filename: String, fileType: String) -> BSTextAttachment {
        let attachment = BSTextAttachment(type: .image)
        
        let text = "\(filename).\(fileType)"
        let font = UIFont.systemFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.systemBlue
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let size = attributedText.size()
        
        let insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        let paddedSize = CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
        
        UIGraphicsBeginImageContextWithOptions(paddedSize, false, UIScreen.main.scale)
        UIColor.systemGray5.setFill()
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: paddedSize), cornerRadius: 4).fill()
        attributedText.draw(at: CGPoint(x: insets.left, y: insets.top))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        attachment.image = image
        attachment.state = .loaded
        attachment.displaySize = paddedSize
        
        return attachment
    }
}
