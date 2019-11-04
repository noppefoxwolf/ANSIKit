//
//  Colors.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/02/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public struct Colors {

  static let brightness: CGFloat = 1.0
  static let saturation: CGFloat = 0.4
  static let alpha: CGFloat = 1.0

  struct Fg {
    static let black = UIColor.black
    static let red = UIColor.systemRed
    static let green = UIColor.systemGreen
    static let yellow = UIColor.systemYellow
    static let blue = UIColor.systemBlue
    static let magenta = UIColor.systemPurple
    static let cyan = UIColor.systemIndigo
    static let white = UIColor.white
    
    static let brightBlack = UIColor(white: 0.337, alpha: 1.0)
    static let brightRed = UIColor(hue: 1.0, saturation: Colors.saturation, brightness: Colors.brightness, alpha: Colors.alpha)
    static let brightGreen = UIColor(hue: 1.0 / 3.0, saturation: Colors.saturation, brightness: Colors.brightness, alpha: Colors.alpha)
    static let brightYellow = UIColor(hue: 1.0 / 6.0, saturation: Colors.saturation, brightness: Colors.brightness, alpha: Colors.alpha)
    static let brightBlue = UIColor(hue: 2.0 / 3.0, saturation: Colors.saturation, brightness: Colors.brightness, alpha: Colors.alpha)
    static let brightMagenta = UIColor(hue: 5.0 / 6.0, saturation: Colors.saturation, brightness: Colors.brightness, alpha: Colors.alpha)
    static let brightCyan = UIColor(hue: 0.5, saturation: Colors.saturation, brightness: Colors.brightness, alpha: Colors.alpha)
    static let brightWhite = UIColor.white
  }
  struct Bg {
    static let black = UIColor.black
    static let red = UIColor.systemRed
    static let green = UIColor.systemGreen
    static let yellow = UIColor.systemYellow
    static let blue = UIColor.systemBlue
    static let magenta = UIColor.systemPurple
    static let cyan = UIColor.systemIndigo
    static let white = UIColor.white
    
    static let brightBlack = Colors.Fg.brightBlack
    static let brightRed = Colors.Fg.brightRed
    static let brightGreen = Colors.Fg.brightGreen
    static let brightYellow = Colors.Fg.brightYellow
    static let brightBlue = Colors.Fg.brightBlue
    static let brightMagenta = Colors.Fg.brightMagenta
    static let brightCyan = Colors.Fg.brightCyan
    static let brightWhite = UIColor.white
  }
  
}

func SGRCodeForColor(aColor: UIColor?, isForegroundColor: Bool) -> SGRCode
{
  if (isForegroundColor) {
    if (aColor == Colors.Fg.black) {
      return SGRCode.fgBlack
    } else if (aColor == Colors.Fg.red) {
      return SGRCode.fgRed
    } else if (aColor == Colors.Fg.green) {
      return SGRCode.fgGreen
    } else if (aColor == Colors.Fg.yellow) {
      return SGRCode.fgYellow
    } else if (aColor == Colors.Fg.blue) {
      return SGRCode.fgBlue
    } else if (aColor == Colors.Fg.magenta) {
      return SGRCode.fgMagenta
    } else if (aColor == Colors.Fg.cyan) {
      return SGRCode.fgCyan
    } else if (aColor == Colors.Fg.white) {
      return SGRCode.fgWhite
    } else if (aColor == Colors.Fg.brightBlack) {
      return SGRCode.fgBrightBlack
    } else if (aColor == Colors.Fg.brightRed) {
      return SGRCode.fgBrightRed
    } else if (aColor == Colors.Fg.brightGreen) {
      return SGRCode.fgBrightGreen
    } else if (aColor == Colors.Fg.brightYellow) {
      return SGRCode.fgBrightYellow
    } else if (aColor == Colors.Fg.brightBlue) {
      return SGRCode.fgBrightBlue
    } else if (aColor == Colors.Fg.brightMagenta) {
      return SGRCode.fgBrightMagenta
    } else if (aColor == Colors.Fg.brightCyan) {
      return SGRCode.fgBrightCyan
    } else if (aColor == Colors.Fg.brightWhite) {
      return SGRCode.fgBrightWhite
    }
  } else {
    if (aColor == Colors.Bg.black) {
      return SGRCode.bgBlack
    } else if (aColor == Colors.Bg.red) {
      return SGRCode.bgRed
    } else if (aColor == Colors.Bg.green) {
      return SGRCode.bgGreen
    } else if (aColor == Colors.Bg.yellow) {
      return SGRCode.bgYellow
    } else if (aColor == Colors.Bg.blue) {
      return SGRCode.bgBlue
    } else if (aColor == Colors.Bg.magenta) {
      return SGRCode.bgMagenta
    } else if (aColor == Colors.Bg.cyan) {
      return SGRCode.bgCyan
    } else if (aColor == Colors.Bg.white) {
      return SGRCode.bgWhite
    } else if (aColor == Colors.Bg.brightBlack) {
      return SGRCode.bgBrightBlack
    } else if (aColor == Colors.Bg.brightRed) {
      return SGRCode.bgBrightRed
    } else if (aColor == Colors.Bg.brightGreen) {
      return SGRCode.bgBrightGreen
    } else if (aColor == Colors.Bg.brightYellow) {
      return SGRCode.bgBrightYellow
    } else if (aColor == Colors.Bg.brightBlue) {
      return SGRCode.bgBrightBlue
    } else if (aColor == Colors.Bg.brightMagenta) {
      return SGRCode.bgBrightMagenta
    } else if (aColor == Colors.Bg.brightCyan) {
      return SGRCode.bgBrightCyan
    } else if (aColor == Colors.Bg.brightWhite) {
      return SGRCode.bgBrightWhite
    }
  }
  
  return SGRCode.noneOrInvalid
}
