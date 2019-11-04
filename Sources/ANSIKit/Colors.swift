//
//  Colors.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/02/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public struct Colors {

  static let Brightness: CGFloat = 1.0
  static let Saturation: CGFloat = 0.4
  static let Alpha: CGFloat = 1.0

  struct Fg {
    static let Black = UIColor.black
    static let Red = UIColor.red
    static let Green = UIColor.green
    static let Yellow = UIColor.yellow
    static let Blue = UIColor.blue
    static let Magenta = UIColor.magenta
    static let Cyan = UIColor.cyan
    static let White = UIColor.white
    
    static let BrightBlack = UIColor(white: 0.337, alpha: 1.0)
    static let BrightRed = UIColor(hue: 1.0, saturation: Colors.Saturation, brightness: Colors.Brightness, alpha: Colors.Alpha)
    static let BrightGreen = UIColor(hue: 1.0 / 3.0, saturation: Colors.Saturation, brightness: Colors.Brightness, alpha: Colors.Alpha)
    static let BrightYellow = UIColor(hue: 1.0 / 6.0, saturation: Colors.Saturation, brightness: Colors.Brightness, alpha: Colors.Alpha)
    static let BrightBlue = UIColor(hue: 2.0 / 3.0, saturation: Colors.Saturation, brightness: Colors.Brightness, alpha: Colors.Alpha)
    static let BrightMagenta = UIColor(hue: 5.0 / 6.0, saturation: Colors.Saturation, brightness: Colors.Brightness, alpha: Colors.Alpha)
    static let BrightCyan = UIColor(hue: 0.5, saturation: Colors.Saturation, brightness: Colors.Brightness, alpha: Colors.Alpha)
    static let BrightWhite = UIColor.white
  }
  struct Bg {
    static let Black = UIColor.black
    static let Red = UIColor.red
    static let Green = UIColor.green
    static let Yellow = UIColor.yellow
    static let Blue = UIColor.blue
    static let Magenta = UIColor.magenta
    static let Cyan = UIColor.cyan
    static let White = UIColor.white
    
    static let BrightBlack = Colors.Fg.BrightBlack
    static let BrightRed = Colors.Fg.BrightRed
    static let BrightGreen = Colors.Fg.BrightGreen
    static let BrightYellow = Colors.Fg.BrightYellow
    static let BrightBlue = Colors.Fg.BrightBlue
    static let BrightMagenta = Colors.Fg.BrightMagenta
    static let BrightCyan = Colors.Fg.BrightCyan
    static let BrightWhite = UIColor.white
  }
  
}

func SGRCodeForColor(aColor: UIColor?, isForegroundColor: Bool) -> SGRCode
{
  if (isForegroundColor) {
    if (aColor == Colors.Fg.Black) {
      return SGRCode.FgBlack
    } else if (aColor == Colors.Fg.Red) {
      return SGRCode.FgRed
    } else if (aColor == Colors.Fg.Green) {
      return SGRCode.FgGreen
    } else if (aColor == Colors.Fg.Yellow) {
      return SGRCode.FgYellow
    } else if (aColor == Colors.Fg.Blue) {
      return SGRCode.FgBlue
    } else if (aColor == Colors.Fg.Magenta) {
      return SGRCode.FgMagenta
    } else if (aColor == Colors.Fg.Cyan) {
      return SGRCode.FgCyan
    } else if (aColor == Colors.Fg.White) {
      return SGRCode.FgWhite
    } else if (aColor == Colors.Fg.BrightBlack) {
      return SGRCode.FgBrightBlack
    } else if (aColor == Colors.Fg.BrightRed) {
      return SGRCode.FgBrightRed
    } else if (aColor == Colors.Fg.BrightGreen) {
      return SGRCode.FgBrightGreen
    } else if (aColor == Colors.Fg.BrightYellow) {
      return SGRCode.FgBrightYellow
    } else if (aColor == Colors.Fg.BrightBlue) {
      return SGRCode.FgBrightBlue
    } else if (aColor == Colors.Fg.BrightMagenta) {
      return SGRCode.FgBrightMagenta
    } else if (aColor == Colors.Fg.BrightCyan) {
      return SGRCode.FgBrightCyan
    } else if (aColor == Colors.Fg.BrightWhite) {
      return SGRCode.FgBrightWhite
    }
  } else {
    if (aColor == Colors.Bg.Black) {
      return SGRCode.BgBlack
    } else if (aColor == Colors.Bg.Red) {
      return SGRCode.BgRed
    } else if (aColor == Colors.Bg.Green) {
      return SGRCode.BgGreen
    } else if (aColor == Colors.Bg.Yellow) {
      return SGRCode.BgYellow
    } else if (aColor == Colors.Bg.Blue) {
      return SGRCode.BgBlue
    } else if (aColor == Colors.Bg.Magenta) {
      return SGRCode.BgMagenta
    } else if (aColor == Colors.Bg.Cyan) {
      return SGRCode.BgCyan
    } else if (aColor == Colors.Bg.White) {
      return SGRCode.BgWhite
    } else if (aColor == Colors.Bg.BrightBlack) {
      return SGRCode.BgBrightBlack
    } else if (aColor == Colors.Bg.BrightRed) {
      return SGRCode.BgBrightRed
    } else if (aColor == Colors.Bg.BrightGreen) {
      return SGRCode.BgBrightGreen
    } else if (aColor == Colors.Bg.BrightYellow) {
      return SGRCode.BgBrightYellow
    } else if (aColor == Colors.Bg.BrightBlue) {
      return SGRCode.BgBrightBlue
    } else if (aColor == Colors.Bg.BrightMagenta) {
      return SGRCode.BgBrightMagenta
    } else if (aColor == Colors.Bg.BrightCyan) {
      return SGRCode.BgBrightCyan
    } else if (aColor == Colors.Bg.BrightWhite) {
      return SGRCode.BgBrightWhite
    }
  }
  
  return SGRCode.NoneOrInvalid
}
