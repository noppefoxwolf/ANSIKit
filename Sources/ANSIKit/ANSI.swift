//
//  ANSI.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/02/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public enum ANSI {
    
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
}

enum AttributeKeys: String {
    case name = "attributeName"
    case value = "attributeValue"
    case range = "range"
    case code = "code"
    case location = "location"
}

public extension NSAttributedString {
    convenience init(ansiString: String, options: ANSI.Options) {
        self.init(attributedString: attributedString(withANSIEscapedString: ansiString, options: options))
    }
}

func attributedString(withANSIEscapedString aString: String, options: ANSI.Options) -> NSAttributedString {
    guard !aString.isEmpty else { return .init() }
    
    
    var cleanString: String?
    let attributesAndRanges = attributes(for: aString, options: options, aCleanString: &cleanString)
    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: cleanString!, attributes: [.font: options.font, .foregroundColor: options.foregroundColor])
    
    for thisAttributeDict: [AttributeKeys: Any] in attributesAndRanges {
        if let attributeValue: Any = thisAttributeDict[AttributeKeys.value],
            let attributeName: NSAttributedString.Key = thisAttributeDict[AttributeKeys.name] as? NSAttributedString.Key,
            let range = thisAttributeDict[AttributeKeys.range] as? NSRange {
            attributedString.addAttribute(attributeName, value: attributeValue, range: range)
        }
    }
    
    return attributedString;
}

func attributes(for aString: String, options: ANSI.Options, aCleanString: inout String?) -> [[AttributeKeys: Any]] {
    if (aString == "") {
        return []
    }
    
    if (aString.count <= EscapeCharacters.CSI.count) {
        if (aCleanString != nil) {
            aCleanString = aString
        }
        return []
    }
    
    var attrsAndRanges = [[AttributeKeys: Any]]()
    
    var cleanString: String? = ""
    let formatCodes: [[AttributeKeys: Any]] = escapeCodes(for: aString, cleanString: &cleanString)
    let foundCodes = formatCodes.count
    var startIndex = 0
    var range: NSRange
    
    for (index, thisCodeDict) in formatCodes.enumerated() {
        let thisCode = thisCodeDict[AttributeKeys.code] as! Int
        let code = SGRCode(rawValue: thisCode)
        
        if let attributeName = attributeName(for: code!) {
            if let attributeValue: Any = attributeValue(for: code!, options: options) {
                startIndex = index + 1
                range = _range(of: cleanString!, startCode: thisCodeDict, codes: Array(formatCodes[startIndex..<foundCodes]))
                attrsAndRanges.append([
                    AttributeKeys.range: range,
                    AttributeKeys.name: attributeName,
                    AttributeKeys.value: attributeValue
                ])
            }
        }
    }
    
    if (cleanString != nil) {
        aCleanString = cleanString
    }
    
    return attrsAndRanges
}

func _range(of string: String, startCode: [AttributeKeys: Any], codes: [[AttributeKeys: Any]]) -> NSRange {
    var formattingRunEndLocation = -1
    let formattingRunStartLocation = startCode[AttributeKeys.location] as! Int
    let formattingRunStartCode = SGRCode(rawValue: startCode[AttributeKeys.code] as! Int)
    
    for endCode: [AttributeKeys: Any] in codes {
        let theEndCode = endCode[AttributeKeys.code] as! Int
        if (shouldEndFormattingIntroduced(endCode: SGRCode(rawValue: theEndCode)!, startCode: formattingRunStartCode!)) {
            formattingRunEndLocation = endCode[AttributeKeys.location] as! Int
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
        traits = [traits, .traitBold]
        if let boldDescriptor: UIFontDescriptor = descriptor.withSymbolicTraits(traits) {
            let boldFont: UIFont = UIFont(descriptor: boldDescriptor, size: options.font.pointSize)
            return boldFont
        }
    } else if code.isIntensity {
        traits = [traits, .traitMonoSpace]
        if let newDescriptor: UIFontDescriptor = descriptor.withSymbolicTraits(traits) {
            let unboldFont = UIFont(descriptor: newDescriptor, size: options.font.pointSize)
            return unboldFont
        }
    } else if code == SGRCode.underlineSingle {
        return NSUnderlineStyle.single
    } else if code == SGRCode.underlineDouble {
        return NSUnderlineStyle.double
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

func escapeCodes(for escapedString: String, cleanString: inout String?) -> [[AttributeKeys: Any]] {
    let aString = escapedString as NSString
    if (aString == "") {
        return []
    }
    
    if (aString.length <= EscapeCharacters.CSI.count) {
        return []
    }
    
    var formatCodes = [[AttributeKeys: Any]]()
    
    let aStringLength = aString.length
    var coveredLength = 0
    
    var searchRange = NSMakeRange(0, aStringLength)
    var sequenceRange: NSRange
    var thisCoveredLength: Int = 0
    var searchStart: Int = 0
    
    repeat {
        sequenceRange = aString.range(of: EscapeCharacters.CSI, options: NSString.CompareOptions.literal, range: searchRange)
        
        if (sequenceRange.location != NSNotFound) {
            
            thisCoveredLength = sequenceRange.location - searchRange.location
            coveredLength += thisCoveredLength
            
            formatCodes += codes(for: &sequenceRange, string: aString).map { code in
                [AttributeKeys.code: code, AttributeKeys.location: coveredLength]
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

