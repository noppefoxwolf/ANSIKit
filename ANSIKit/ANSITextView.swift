//
//  ANSITextView.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/03/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public class ANSITextView: UITextView {

  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    let textStorage = ANSITextStorage()
    
    let layoutManager = NSLayoutManager()
    
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
  }
  
}
