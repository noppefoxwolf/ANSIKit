//
//  ANSI.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/02/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public struct ANSI {
    let string: String
    let options: Options
    let boldFont: UIFont
    let unboldFont: UIFont
    
    init(string: String, options: Options) {
        self.string = string
        self.options = options
        let descriptor: UIFontDescriptor = options.font.fontDescriptor
        bold: do {
            let traits: UIFontDescriptor.SymbolicTraits = [descriptor.symbolicTraits, .traitBold]
            boldFont = UIFont(descriptor: descriptor.withSymbolicTraits(traits) ?? UIFontDescriptor(), size: options.font.pointSize)
        }
        unbold: do {
            let traits: UIFontDescriptor.SymbolicTraits = [descriptor.symbolicTraits, .traitMonoSpace]
            unboldFont = UIFont(descriptor: descriptor.withSymbolicTraits(traits) ?? UIFontDescriptor(), size: options.font.pointSize)
        }
    }
}

public extension ANSI {
    struct Options {
        public var foregroundColor: UIColor
        public var font: UIFont
        
        public init(color: UIColor, font: UIFont) {
            self.foregroundColor = color
            self.font = font
        }
    }
    
    struct Attribute {
        let name: NSAttributedString.Key
        let value: Any
        let range: NSRange
    }
    
    struct Code {
        let code: Int
        let location: Int
    }
}


public extension NSAttributedString {
    convenience init(ansiString: String, options: ANSI.Options) {
        self.init(attributedString: ANSI(string: ansiString, options: options).attributedString)
    }
}


extension ANSI {
    var attributedString: NSAttributedString {
        guard !string.isEmpty else { return .init() }
        
        var cleanString: String?
        let attributesAndRanges = attributes(for: string, options: options, aCleanString: &cleanString)
        let attributedString: NSMutableAttributedString = .init(string: cleanString!, attributes: [
            .font: options.font,
            .foregroundColor: options.foregroundColor
        ])
        
        for thisAttributeDict in attributesAndRanges {
            let attributeValue = thisAttributeDict.value
            let attributeName = thisAttributeDict.name
            let range = thisAttributeDict.range
            attributedString.addAttribute(attributeName, value: attributeValue, range: range)
        }
        
        return attributedString
    }

    func attributes(for aString: String, options: ANSI.Options, aCleanString: inout String?) -> [Attribute] {
        if (aString.isEmpty) {
            return []
        }
        
        if (aString.count <= EscapeCharacters.csi.count) {
            if (aCleanString != nil) {
                aCleanString = aString
            }
            return []
        }
        
        var attrsAndRanges: [Attribute] = []
        
        var cleanString: String? = ""
        let formatCodes: [Code] = escapeCodes(for: aString, cleanString: &cleanString)
        let foundCodes = formatCodes.count
        var startIndex = 0
        var range: NSRange
        
        for (index, code) in formatCodes.enumerated() {
            let thisCode = code.code
            let sgrCode = SGRCode(rawValue: thisCode)
            
            if let attributeName = attributeName(for: sgrCode!) {
                if let attributeValue: Any = attributeValue(for: sgrCode!, options: options) {
                    startIndex = index + 1
                    range = _range(of: cleanString!, startCode: code, codes: Array(formatCodes[startIndex..<foundCodes]))
                    attrsAndRanges.append(.init(name: attributeName, value: attributeValue, range: range))
                }
            }
        }
        
        if (cleanString != nil) {
            aCleanString = cleanString
        }
        
        return attrsAndRanges
    }

    func _range(of string: String, startCode: Code, codes: [Code]) -> NSRange {
        var formattingRunEndLocation = -1
        let formattingRunStartLocation = startCode.location
        let formattingRunStartCode = SGRCode(rawValue: startCode.code)
        
        for endCode in codes {
            let theEndCode = endCode.code
            if (shouldEndFormattingIntroduced(endCode: SGRCode(rawValue: theEndCode)!, startCode: formattingRunStartCode!)) {
                formattingRunEndLocation = endCode.location
                break
            }
        }
        if (formattingRunEndLocation == -1) {
            formattingRunEndLocation = string.count
        }
        
        let range = NSMakeRange(formattingRunStartLocation, (formattingRunEndLocation-formattingRunStartLocation))
        
        return range
    }

    func attributeName(for code: SGRCode) -> NSAttributedString.Key? {
        if code.isFgColor {
            return .foregroundColor
        } else if code.isBgColor {
            return .backgroundColor
        } else if code.isIntensity {
            return .font
        } else if code.isUnderline {
            return .underlineStyle
        }
        return nil
    }

    func attributeValue(for code: SGRCode, options: ANSI.Options) -> Any? {
        let descriptor: UIFontDescriptor = options.font.fontDescriptor
        var traits: UIFontDescriptor.SymbolicTraits = descriptor.symbolicTraits
        if code.isColor {
            return code.color
        } else if code == SGRCode.intensityBold {
            return boldFont
        } else if code.isIntensity {
            return unboldFont
        } else if code == SGRCode.underlineSingle {
            // <NSATSTypesetter: 0x600003705c80>: Exception -[__SwiftValue _getValue:forType:]: unrecognized selector sent to instance 0x600000c5cc00 raised during typesetting layout manager <NSLayoutManager: 0x1007240d0>
            return NSUnderlineStyle.single.rawValue
        } else if code == SGRCode.underlineDouble {
            return NSUnderlineStyle.double.rawValue
        } else if code == SGRCode.underlineNone {
            return nil //none
        }
        
        return nil
    }


    func shouldEndFormattingIntroduced(endCode: SGRCode, startCode: SGRCode) -> Bool {
        if startCode.isFgColor {
            return endCode.rawValue == SGRCode.allReset.rawValue ||
                (endCode.rawValue >= SGRCode.fgBlack.rawValue && endCode.rawValue <= SGRCode.fgReset.rawValue) ||
                (endCode.rawValue >= SGRCode.fgBrightBlack.rawValue && endCode.rawValue <= SGRCode.fgBrightWhite.rawValue)
        } else if startCode.isBgColor {
            return endCode.rawValue == SGRCode.allReset.rawValue ||
                (endCode.rawValue >= SGRCode.bgBlack.rawValue && endCode.rawValue <= SGRCode.bgReset.rawValue) ||
                (endCode.rawValue >= SGRCode.bgBrightBlack.rawValue && endCode.rawValue <= SGRCode.bgBrightWhite.rawValue)
        } else if startCode.isIntensity {
            return (endCode.rawValue == SGRCode.allReset.rawValue || endCode.rawValue == SGRCode.intensityNormal.rawValue ||
                endCode.rawValue == SGRCode.intensityBold.rawValue || endCode.rawValue == SGRCode.intensityFaint.rawValue);
        } else if startCode.isUnderline {
            return (endCode.rawValue == SGRCode.allReset.rawValue || endCode.rawValue == SGRCode.underlineNone.rawValue ||
                endCode.rawValue == SGRCode.underlineSingle.rawValue || endCode.rawValue == SGRCode.underlineDouble.rawValue);
        }
        
        return false
    }
    
    func escapeCodes(for escapedString: String, cleanString: inout String?) -> [Code] {
        let aString = escapedString as NSString
        if (aString == "") {
            return []
        }
        
        if (aString.length <= EscapeCharacters.csi.count) {
            return []
        }
        
        var formatCodes: [Code] = []
        
        let aStringLength = aString.length
        var coveredLength = 0
        
        var searchRange = NSMakeRange(0, aStringLength)
        var sequenceRange: NSRange
        var thisCoveredLength: Int = 0
        var searchStart: Int = 0
        
        repeat {
            sequenceRange = aString.range(of: EscapeCharacters.csi, options: NSString.CompareOptions.literal, range: searchRange)
            
            if (sequenceRange.location != NSNotFound) {
                
                thisCoveredLength = sequenceRange.location - searchRange.location
                coveredLength += thisCoveredLength
                
                formatCodes += codes(for: &sequenceRange, string: aString).map { code in
                    Code(code: code, location: coveredLength)
                }
                
                if (thisCoveredLength > 0) {
                    cleanString = cleanString?.appending(aString.substring(with: NSMakeRange(searchRange.location, thisCoveredLength)))
                }
                
                searchStart = NSMaxRange(sequenceRange)
                searchRange = NSMakeRange(searchStart, aStringLength - searchStart)
            }
        } while(sequenceRange.location != NSNotFound)
        
        if (searchRange.length > 0) {
            cleanString = cleanString?.appending(aString.substring(with: searchRange))
        }
        
        return formatCodes
    }

    func codes(for sequenceRange: inout NSRange, string: NSString) -> [Int] {
        var codes = [Int]()
        var code = 0
        var lengthAddition = 1
        var thisIndex: Int
        
        while (true) {
            thisIndex = (NSMaxRange(sequenceRange) + lengthAddition - 1)
            
            if (thisIndex >= string.length) {
                break
            }
            
            
            let c: Int = Int(string.character(at: thisIndex))
            
            if ((48 <= c) && (c <= 57))
            {
                let digit: Int = c - 48
                code = (code == 48) ? digit : code * 10 + digit
            }
            
            if (c == 109)
            {
                codes.append(code)
                break
            } else if ((64 <= c) && (c <= 126)) {
                codes.removeAll(keepingCapacity: false)
                break
            } else if (c == 59) {
                codes.append(code)
                code = 0
            }
            
            lengthAddition += 1
        }
        
        sequenceRange.length += lengthAddition
        
        return codes
    }
}
