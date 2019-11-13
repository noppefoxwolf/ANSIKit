//
//  Characters.swift
//  ANSIKit
//
//  Created by Matthew Delves on 18/02/2015.
//  Copyright (c) 2015 Matthew Delves. All rights reserved.
//

import UIKit

public enum SGRCode: Int {
  case noneOrInvalid = -1
  case allReset = 0

  case intensityBold = 1
  case intensityFaint = 2
  case intensityNormal = 22

  case italicOn = 3

  case underlineSingle = 4
  case underlineDouble = 21
  case underlineNone  = 24

  case fgBlack = 30
  case fgRed = 31
  case fgGreen = 32
  case fgYellow = 33
  case fgBlue = 34
  case fgMagenta = 35
  case fgCyan = 36
  case fgWhite = 37
  case fgReset = 39

  case bgBlack = 40
  case bgRed = 41
  case bgGreen = 42
  case bgYellow = 43
  case bgBlue = 44
  case bgMagenta = 45
  case bgCyan = 46
  case bgWhite = 47
  case bgReset = 49

  case fgBrightBlack = 90
  case fgBrightRed = 91
  case fgBrightGreen = 92
  case fgBrightYellow = 93
  case fgBrightBlue = 94
  case fgBrightMagenta = 95
  case fgBrightCyan = 96
  case fgBrightWhite = 97

  case bgBrightBlack = 100
  case bgBrightRed = 101
  case bgBrightGreen = 102
  case bgBrightYellow = 103
  case bgBrightBlue = 104
  case bgBrightMagenta = 105
  case bgBrightCyan = 106
  case bgBrightWhite = 107
}

public struct EscapeCharacters {
  static let csi: String = "["
  static let sgrEnd = "m"
}

protocol Color {
  var color: UIColor { get }
}

extension SGRCode: Color {
  var color: UIColor {
    switch self {
    case SGRCode.fgBlack:
      return Colors.Fg.black
    case SGRCode.fgRed:
      return Colors.Fg.red
    case SGRCode.fgGreen:
      return Colors.Fg.green
    case SGRCode.fgYellow:
      return Colors.Fg.yellow
    case SGRCode.fgBlue:
      return Colors.Fg.blue
    case SGRCode.fgMagenta:
      return Colors.Fg.magenta
    case SGRCode.fgCyan:
      return Colors.Fg.cyan
    case SGRCode.fgWhite:
      return Colors.Fg.white
    case SGRCode.fgBrightBlack:
      return Colors.Fg.brightBlack
    case SGRCode.fgBrightRed:
      return Colors.Fg.brightRed
    case SGRCode.fgBrightGreen:
      return Colors.Fg.brightGreen
    case SGRCode.fgBrightYellow:
      return Colors.Fg.brightYellow
    case SGRCode.fgBrightBlue:
      return Colors.Fg.brightBlue
    case SGRCode.fgBrightMagenta:
      return Colors.Fg.brightMagenta
    case SGRCode.fgBrightCyan:
      return Colors.Fg.brightCyan
    case SGRCode.fgBrightWhite:
      return Colors.Fg.brightWhite
    case SGRCode.bgBlack:
      return Colors.Bg.black
    case SGRCode.bgRed:
      return Colors.Bg.red
    case SGRCode.bgGreen:
      return Colors.Bg.green
    case SGRCode.bgYellow:
      return Colors.Bg.yellow
    case SGRCode.bgBlue:
      return Colors.Bg.blue
    case SGRCode.bgMagenta:
      return Colors.Bg.magenta
    case SGRCode.bgCyan:
      return Colors.Bg.cyan
    case SGRCode.bgWhite:
      return Colors.Bg.white
    case SGRCode.bgBrightBlack:
      return Colors.Bg.brightBlack
    case SGRCode.bgBrightRed:
      return Colors.Bg.brightRed
    case SGRCode.bgBrightGreen:
      return Colors.Bg.brightGreen
    case SGRCode.bgBrightYellow:
      return Colors.Bg.brightYellow
    case SGRCode.bgBrightBlue:
      return Colors.Bg.brightBlue
    case SGRCode.bgBrightMagenta:
      return Colors.Bg.brightMagenta
    case SGRCode.bgBrightCyan:
      return Colors.Bg.brightCyan
    case SGRCode.bgBrightWhite:
      return Colors.Bg.brightWhite
    default:
      break
    }
    
    return Colors.Fg.black
  }
}

extension SGRCode {
    var isFgColor: Bool {
        return (rawValue >= SGRCode.fgBlack.rawValue && rawValue <= SGRCode.fgWhite.rawValue) ||
            (rawValue >= SGRCode.fgBrightBlack.rawValue && rawValue <= SGRCode.fgBrightWhite.rawValue)
    }

    var isBgColor: Bool {
        return (rawValue >= SGRCode.bgBlack.rawValue && rawValue <= SGRCode.bgWhite.rawValue) ||
            (rawValue >= SGRCode.bgBrightBlack.rawValue && rawValue <= SGRCode.bgBrightWhite.rawValue)
    }

    var isIntensity: Bool {
        return rawValue == SGRCode.intensityNormal.rawValue || rawValue == SGRCode.intensityBold.rawValue || rawValue == SGRCode.intensityFaint.rawValue
    }

    var isUnderline: Bool {
        return rawValue == SGRCode.underlineNone.rawValue || rawValue == SGRCode.underlineSingle.rawValue || rawValue == SGRCode.underlineDouble.rawValue
    }

    var isColor: Bool {
        return isFgColor || isBgColor
    }

}
