import UIKit
import BSText

class ResizeDemoViewController: UIViewController {
    private let containerView = UIView()
    private let textView = BSTextView()
    private let resizeHandle = UIView()
    private let cornerHandles = UIView()
    private var minWidth: CGFloat = 100
    private var minHeight: CGFloat = 100
    private var maxWidth: CGFloat = 400
    private var maxHeight: CGFloat = 600
    private var startPoint: CGPoint = .zero
    private var startFrame: CGRect = .zero
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Resize"
        
        setupContainer()
        setupTextView()
        setupResizeHandle()
        setupComplexContent()
    }
    
    private func setupContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 8
        view.addSubview(containerView)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        containerView.addGestureRecognizer(longPress)
        
        widthConstraint = containerView.widthAnchor.constraint(equalToConstant: 280)
        heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 200)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            widthConstraint,
            heightConstraint
        ])
    }
    
    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 14)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        containerView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupResizeHandle() {
        cornerHandles.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cornerHandles)
        
        let handleSize: CGFloat = 30
        
        let topLeft = createCornerHandle()
        let topRight = createCornerHandle()
        let bottomLeft = createCornerHandle()
        let bottomRight = createCornerHandle()
        
        cornerHandles.addSubview(topLeft)
        cornerHandles.addSubview(topRight)
        cornerHandles.addSubview(bottomLeft)
        cornerHandles.addSubview(bottomRight)
        
        NSLayoutConstraint.activate([
            cornerHandles.topAnchor.constraint(equalTo: containerView.topAnchor),
            cornerHandles.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cornerHandles.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cornerHandles.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            topLeft.topAnchor.constraint(equalTo: cornerHandles.topAnchor),
            topLeft.leadingAnchor.constraint(equalTo: cornerHandles.leadingAnchor),
            topLeft.widthAnchor.constraint(equalToConstant: handleSize),
            topLeft.heightAnchor.constraint(equalToConstant: handleSize),
            
            topRight.topAnchor.constraint(equalTo: cornerHandles.topAnchor),
            topRight.trailingAnchor.constraint(equalTo: cornerHandles.trailingAnchor),
            topRight.widthAnchor.constraint(equalToConstant: handleSize),
            topRight.heightAnchor.constraint(equalToConstant: handleSize),
            
            bottomLeft.bottomAnchor.constraint(equalTo: cornerHandles.bottomAnchor),
            bottomLeft.leadingAnchor.constraint(equalTo: cornerHandles.leadingAnchor),
            bottomLeft.widthAnchor.constraint(equalToConstant: handleSize),
            bottomLeft.heightAnchor.constraint(equalToConstant: handleSize),
            
            bottomRight.bottomAnchor.constraint(equalTo: cornerHandles.bottomAnchor),
            bottomRight.trailingAnchor.constraint(equalTo: cornerHandles.trailingAnchor),
            bottomRight.widthAnchor.constraint(equalToConstant: handleSize),
            bottomRight.heightAnchor.constraint(equalToConstant: handleSize)
        ])
        
        let topLeftPan = UIPanGestureRecognizer(target: self, action: #selector(handleTopLeftPan(_:)))
        topLeft.addGestureRecognizer(topLeftPan)
        
        let topRightPan = UIPanGestureRecognizer(target: self, action: #selector(handleTopRightPan(_:)))
        topRight.addGestureRecognizer(topRightPan)
        
        let bottomLeftPan = UIPanGestureRecognizer(target: self, action: #selector(handleBottomLeftPan(_:)))
        bottomLeft.addGestureRecognizer(bottomLeftPan)
        
        let bottomRightPan = UIPanGestureRecognizer(target: self, action: #selector(handleBottomRightPan(_:)))
        bottomRight.addGestureRecognizer(bottomRightPan)
    }
    
    private func createCornerHandle() -> UIView {
        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = .systemBlue
        
        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.backgroundColor = .white
        innerCircle.layer.cornerRadius = 4
        handle.addSubview(innerCircle)
        
        NSLayoutConstraint.activate([
            innerCircle.centerXAnchor.constraint(equalTo: handle.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: handle.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 8),
            innerCircle.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        return handle
    }
    
    private func setupComplexContent() {
        let content = NSMutableAttributedString()
        
        let title = NSAttributedString(string: "📝 BSText Demo\n\n", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ])
        content.append(title)
        
        let codeBlock = """
        ```swift
        let text = "Hello"
        print(text)
        ```
        
        **Bold text** and *italic text* supported.
        
        > This is a blockquote with important information.
        
        - List item 1
        - List item 2
        - List item 3
        
        ~~Strikethrough text~~
        
        Links: [BSText](https://github.com)
        
        🎉 🚀 💡 🎯 🌟 💪 🔥 ✨ ❤️ 😊
        """
        
        let parser = BSTextMarkdownParser()
        content.append(parser.parse(codeBlock))
        
        textView.attributedText = content
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.containerView.layer.shadowColor = UIColor.black.cgColor
                self.containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
                self.containerView.layer.shadowRadius = 8
                self.containerView.layer.shadowOpacity = 0.3
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = .identity
                self.containerView.layer.shadowOpacity = 0
            }
        default:
            break
        }
    }
    
    @objc private func handleTopLeftPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startPoint = gesture.location(in: view)
            startFrame = containerView.frame
            
        case .changed:
            let currentPoint = gesture.location(in: view)
            let deltaX = currentPoint.x - startPoint.x
            let deltaY = currentPoint.y - startPoint.y
            
            var newWidth = startFrame.width - deltaX
            var newHeight = startFrame.height - deltaY
            
            newWidth = max(minWidth, min(newWidth, maxWidth))
            newHeight = max(minHeight, min(newHeight, maxHeight))
            
            widthConstraint.constant = newWidth
            heightConstraint.constant = newHeight
            
            let newX = startFrame.maxX - newWidth
            let newY = startFrame.maxY - newHeight
            containerView.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
            view.layoutIfNeeded()
            
        default:
            break
        }
    }
    
    @objc private func handleTopRightPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startPoint = gesture.location(in: view)
            startFrame = containerView.frame
            
        case .changed:
            let currentPoint = gesture.location(in: view)
            let deltaX = currentPoint.x - startPoint.x
            let deltaY = currentPoint.y - startPoint.y
            
            var newWidth = startFrame.width + deltaX
            var newHeight = startFrame.height - deltaY
            
            newWidth = max(minWidth, min(newWidth, maxWidth))
            newHeight = max(minHeight, min(newHeight, maxHeight))
            
            widthConstraint.constant = newWidth
            heightConstraint.constant = newHeight
            
            let newY = startFrame.maxY - newHeight
            containerView.frame = CGRect(x: startFrame.minX, y: newY, width: newWidth, height: newHeight)
            view.layoutIfNeeded()
            
        default:
            break
        }
    }
    
    @objc private func handleBottomLeftPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startPoint = gesture.location(in: view)
            startFrame = containerView.frame
            
        case .changed:
            let currentPoint = gesture.location(in: view)
            let deltaX = currentPoint.x - startPoint.x
            let deltaY = currentPoint.y - startPoint.y
            
            var newWidth = startFrame.width - deltaX
            var newHeight = startFrame.height + deltaY
            
            newWidth = max(minWidth, min(newWidth, maxWidth))
            newHeight = max(minHeight, min(newHeight, maxHeight))
            
            widthConstraint.constant = newWidth
            heightConstraint.constant = newHeight
            
            let newX = startFrame.maxX - newWidth
            containerView.frame = CGRect(x: newX, y: startFrame.minY, width: newWidth, height: newHeight)
            view.layoutIfNeeded()
            
        default:
            break
        }
    }
    
    @objc private func handleBottomRightPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startPoint = gesture.location(in: view)
            startFrame = containerView.frame
            
        case .changed:
            let currentPoint = gesture.location(in: view)
            let deltaX = currentPoint.x - startPoint.x
            let deltaY = currentPoint.y - startPoint.y
            
            var newWidth = startFrame.width + deltaX
            var newHeight = startFrame.height + deltaY
            
            newWidth = max(minWidth, min(newWidth, maxWidth))
            newHeight = max(minHeight, min(newHeight, maxHeight))
            
            widthConstraint.constant = newWidth
            heightConstraint.constant = newHeight
            containerView.frame = CGRect(x: startFrame.minX, y: startFrame.minY, width: newWidth, height: newHeight)
            view.layoutIfNeeded()
            
        default:
            break
        }
    }
}
