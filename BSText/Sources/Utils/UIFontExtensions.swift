import UIKit

extension NSString {
    func rangeOfWord(at location: Int) -> NSRange? {
        guard location >= 0 && location <= length else {
            return nil
        }
        
        var start = location
        var end = location
        
        while start > 0 && character(at: start - 1).isWordCharacter {
            start -= 1
        }
        
        while end < length && character(at: end).isWordCharacter {
            end += 1
        }
        
        return NSRange(location: start, length: end - start)
    }
}

extension unichar {
    var isWordCharacter: Bool {
        let character = Character(UnicodeScalar(self) ?? "\0")
        return character.isLetter || character.isNumber || self == 0x27 // apostrophe
    }
}

extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    var bolded: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert(.traitBold)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    var unbolded: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitBold)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    var italicized: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert(.traitItalic)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    var unitalicized: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitItalic)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
