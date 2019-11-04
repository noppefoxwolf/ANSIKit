//
//  ANSI.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/02/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public struct AnsiHelper {
    public var defaultStringColor: UIColor
    public var font: UIFont
    
    public init(color: UIColor, font: UIFont) {
        self.defaultStringColor = color
        self.font = font
    }
}

struct HSB {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    
    init (hue: CGFloat, saturation: CGFloat, brightness: CGFloat)
    {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
    }
}

enum AttributeKeys: String {
    case name = "attributeName"
    case value = "attributeValue"
    case range = "range"
    case code = "code"
    case location = "location"
}

func getHSBFromColor(color: UIColor) -> HSB {
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    
    color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
    
    return HSB(hue: hue, saturation: saturation, brightness: brightness)
}


public func ansiEscapedAttributedString(helper: AnsiHelper, ansi: String) -> NSAttributedString? {
    let string: NSAttributedString? = attributedStringWithANSIEscapedString(helper: helper, aString: ansi)
    
    return string
}

func attributedStringWithANSIEscapedString(helper: AnsiHelper, aString: String) -> NSAttributedString? {
    if (aString == "") {
        return nil
    }
    
    
    var cleanString: String?
    let attributesAndRanges = attributesForString(helper: helper, aString: aString, aCleanString: &cleanString)
    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: cleanString!, attributes: [.font: helper.font, .foregroundColor: helper.defaultStringColor])
    
    for thisAttributeDict: [AttributeKeys: Any] in attributesAndRanges {
        if let attributeValue: Any = thisAttributeDict[AttributeKeys.value],
            let attributeName: NSAttributedString.Key = thisAttributeDict[AttributeKeys.name] as? NSAttributedString.Key,
           let range = thisAttributeDict[AttributeKeys.range] as? NSRange {
                attributedString.addAttribute(attributeName, value: attributeValue, range: range)
        }
    }
    
    return attributedString;
}

func attributesForString(helper: AnsiHelper, aString: String, aCleanString: inout String?) -> [[AttributeKeys: Any]] {
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
    let formatCodes: [[AttributeKeys: Any]] = escapeCodesForString(escapedString: aString, cleanString: &cleanString)
    let foundCodes = formatCodes.count
    var startIndex = 0
    var range: NSRange
    
    for (index, thisCodeDict) in formatCodes.enumerated() {
        let thisCode = thisCodeDict[AttributeKeys.code] as! Int
        let code = SGRCode(rawValue: thisCode)
        
        if let attributeName = attributeNameForCode(code: code!) {
            if let attributeValue: Any = attributeValueForCode(code: code!, helper: helper) {
                startIndex = index + 1
                range = rangeOfString(string: cleanString!, startCode: thisCodeDict, codes: Array(formatCodes[startIndex..<foundCodes]))
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

func rangeOfString(string: String, startCode: [AttributeKeys: Any], codes: [[AttributeKeys: Any]]) -> NSRange {
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

func attributeNameForCode(code: SGRCode) -> NSAttributedString.Key? {
    if codeIsFgColor(code: code) {
        return .foregroundColor
    } else if codeIsBgColor(code: code) {
        return .backgroundColor
    } else if codeIsIntensity(code: code) {
        return .font
    } else if codeIsUnderline(code: code) {
        return .underlineStyle
    }
    return nil
}

func attributeValueForCode(code: SGRCode, helper: AnsiHelper) -> Any? {
    let descriptor: UIFontDescriptor = helper.font.fontDescriptor
    var traits: UIFontDescriptor.SymbolicTraits = descriptor.symbolicTraits
    if codeIsColor(code: code) {
        return code.color
    } else if code == SGRCode.IntensityBold {
        traits = [traits, .traitBold]
        if let boldDescriptor: UIFontDescriptor = descriptor.withSymbolicTraits(traits) {
            let boldFont: UIFont = UIFont(descriptor: boldDescriptor, size: helper.font.pointSize)
            return boldFont
        }
    } else if codeIsIntensity(code: code) {
        traits = [traits, .traitMonoSpace]
        if let newDescriptor: UIFontDescriptor = descriptor.withSymbolicTraits(traits) {
            let unboldFont = UIFont(descriptor: newDescriptor, size: helper.font.pointSize)
            return unboldFont
        }
    } else if code == SGRCode.UnderlineSingle {
        return NSUnderlineStyle.single
    } else if code == SGRCode.UnderlineDouble {
        return NSUnderlineStyle.double
    } else if code == SGRCode.UnderlineNone {
        return nil //none
    }
    
    return nil
}

func codeIsFgColor(code: SGRCode) -> Bool {
    return (code.rawValue >= SGRCode.FgBlack.rawValue && code.rawValue <= SGRCode.FgWhite.rawValue) ||
        (code.rawValue >= SGRCode.FgBrightBlack.rawValue && code.rawValue <= SGRCode.FgBrightWhite.rawValue)
}

func codeIsBgColor(code: SGRCode) -> Bool {
    return (code.rawValue >= SGRCode.BgBlack.rawValue && code.rawValue <= SGRCode.BgWhite.rawValue) ||
        (code.rawValue >= SGRCode.BgBrightBlack.rawValue && code.rawValue <= SGRCode.BgBrightWhite.rawValue)
}

func codeIsIntensity(code: SGRCode) -> Bool {
    return code.rawValue == SGRCode.IntensityNormal.rawValue || code.rawValue == SGRCode.IntensityBold.rawValue || code.rawValue == SGRCode.IntensityFaint.rawValue
}

func codeIsUnderline(code: SGRCode) -> Bool {
    return code.rawValue == SGRCode.UnderlineNone.rawValue || code.rawValue == SGRCode.UnderlineSingle.rawValue || code.rawValue == SGRCode.UnderlineDouble.rawValue
}

func codeIsColor(code: SGRCode) -> Bool {
    return codeIsFgColor(code: code) || codeIsBgColor(code: code)
}

func shouldEndFormattingIntroduced(endCode: SGRCode, startCode: SGRCode) -> Bool {
    if codeIsFgColor(code: startCode) {
        return endCode.rawValue == SGRCode.AllReset.rawValue ||
            (endCode.rawValue >= SGRCode.FgBlack.rawValue && endCode.rawValue <= SGRCode.FgReset.rawValue) ||
            (endCode.rawValue >= SGRCode.FgBrightBlack.rawValue && endCode.rawValue <= SGRCode.FgBrightWhite.rawValue)
    } else if codeIsBgColor(code: startCode) {
        return endCode.rawValue == SGRCode.AllReset.rawValue ||
            (endCode.rawValue >= SGRCode.BgBlack.rawValue && endCode.rawValue <= SGRCode.BgReset.rawValue) ||
            (endCode.rawValue >= SGRCode.BgBrightBlack.rawValue && endCode.rawValue <= SGRCode.BgBrightWhite.rawValue)
    } else if codeIsIntensity(code: startCode) {
        return (endCode.rawValue == SGRCode.AllReset.rawValue || endCode.rawValue == SGRCode.IntensityNormal.rawValue ||
            endCode.rawValue == SGRCode.IntensityBold.rawValue || endCode.rawValue == SGRCode.IntensityFaint.rawValue);
    } else if codeIsUnderline(code: startCode) {
        return (endCode.rawValue == SGRCode.AllReset.rawValue || endCode.rawValue == SGRCode.UnderlineNone.rawValue ||
            endCode.rawValue == SGRCode.UnderlineSingle.rawValue || endCode.rawValue == SGRCode.UnderlineDouble.rawValue);
    }
    
    return false
}

func escapeCodesForString(escapedString: String, cleanString: inout String?) -> [[AttributeKeys: Any]] {
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
    
    repeat
    {
        sequenceRange = aString.range(of: EscapeCharacters.CSI, options: NSString.CompareOptions.literal, range: searchRange)
        
        if (sequenceRange.location != NSNotFound) {
            
            thisCoveredLength = sequenceRange.location - searchRange.location
            coveredLength += thisCoveredLength
            
            formatCodes += codesForSequence(sequenceRange: &sequenceRange, string: aString).map { code in
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

func codesForSequence( sequenceRange: inout NSRange, string: NSString) -> [Int] {
    var codes = [Int]()
    var code = 0
    var lengthAddition = 1
    var thisIndex: Int
    
    while(true)
    {
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

