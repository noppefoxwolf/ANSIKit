//
//  ANSITextStorage.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/03/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public class ANSITextStorage: NSTextStorage {
  let backingStore = NSMutableAttributedString()
  
  override public var string: String {
    return backingStore.string
  }
  
  override public func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
    return backingStore.attributesAtIndex(location, effectiveRange: range)
  }
  
  override public func replaceCharactersInRange(range: NSRange, withString str: String) {
    beginEditing()
    backingStore.replaceCharactersInRange(range, withString:str)
    edited(.EditedCharacters | .EditedAttributes, range: range, changeInLength: (str as NSString).length - range.length)
    endEditing()
  }
  
  override public func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
    beginEditing()
    backingStore.setAttributes(attrs, range: range)
    edited(.EditedAttributes, range: range, changeInLength: 0)
    endEditing()
  }
}
