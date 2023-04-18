//
//  UIDevice+ModelType.swift
//  aic
//
//  Created by Filippo Vanucci on 11/1/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

public enum Model: String {
  case simulator = "simulator/sandbox"
  case iPhone4 = "iPhone 4"
  case iPhone4S = "iPhone 4S"
  case iPhone5 = "iPhone 5"
  case iPhone5S = "iPhone 5S"
  case iPhone5C = "iPhone 5C"
  case iPhone6 = "iPhone 6"
  case iPhone6plus = "iPhone 6 Plus"
  case iPhone6S = "iPhone 6S"
  case iPhone6Splus = "iPhone 6S Plus"
  case iPhoneSE = "iPhone SE"
  case iPhone7 = "iPhone 7"
  case iPhone7plus = "iPhone 7 Plus"
  case iPhone8 = "iPhone 8"
  case iPhone8plus = "iPhone 8 Plus"
  case iPhoneX = "iPhone X"
  case iPhoneXS = "iPhone XS"
  case iPhoneXSMax = "iPhone XS Max"
  case iPhoneXR = "iPhone XR"
  case iPhone11 = "iPhone 11"
  case iPhone11Pro = "iPhone 11 Pro"
  case iPhone11ProMax = "iPhone 11 Pro Max"
  case iPhoneSE2ndGen = "iPhone SE 2nd Gen"
  case iPhone12Mini = "iPhone 12 Mini"
  case iPhone12 = "iPhone 12"
  case iPhone12Pro = "iPhone 12 Pro"
  case iPhone12ProMax = "iPhone 12 Pro Max"
  case iPhone13Pro = "iPhone 13 Pro"
  case iPhone13ProMax = "iPhone 13 Pro Max"
  case iPhone13Mini = "iPhone 13 Mini"
  case iPhone13 = "iPhone 13"
  case iPhoneSE3rdGen = "iPhone SE 3rd Gen"
  case iPhone14 = "iPhone 14"
  case iPhone14Plus = "iPhone 14 Plus"
  case iPhone14Pro = "iPhone 14 Pro"
  case iPhone14ProMax = "iPhone 14 Pro Max"

  case unrecognized = "?unrecognized?"
}

public extension UIDevice {
  var type: Model {
    var modelCode: String = ""
    if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
      modelCode = simulatorModelIdentifier
    } else {
      var sysinfo = utsname()
      uname(&sysinfo)
      modelCode = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)),
                         encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

    let modelMap: [String: Model] = [
      "i386": .simulator,
      "x86_64": .simulator,
      "iPhone3,1": .iPhone4,
      "iPhone3,2": .iPhone4,
      "iPhone3,3": .iPhone4,
      "iPhone4,1": .iPhone4S,
      "iPhone5,1": .iPhone5,
      "iPhone5,2": .iPhone5,
      "iPhone5,3": .iPhone5C,
      "iPhone5,4": .iPhone5C,
      "iPhone6,1": .iPhone5S,
      "iPhone6,2": .iPhone5S,
      "iPhone7,1": .iPhone6plus,
      "iPhone7,2": .iPhone6,
      "iPhone8,1": .iPhone6S,
      "iPhone8,2": .iPhone6Splus,
      "iPhone8,4": .iPhoneSE,
      "iPhone9,1": .iPhone7,
      "iPhone9,2": .iPhone7plus,
      "iPhone9,3": .iPhone7,
      "iPhone9,4": .iPhone7plus,
      "iPhone10,1": .iPhone8,
      "iPhone10,2": .iPhone8plus,
      "iPhone10,3": .iPhoneX,
      "iPhone10,4": .iPhone8,
      "iPhone10,5": .iPhone8plus,
      "iPhone10,6": .iPhoneX,
      "iPhone11,2": .iPhoneXS,
      "iPhone11,4": .iPhoneXSMax,
      "iPhone11,8": .iPhoneXR,
      "iPhone12,1": .iPhone11,
      "iPhone12,3": .iPhone11Pro,
      "iPhone12,5": .iPhone11ProMax,
      "iPhone12,8": .iPhoneSE2ndGen,
      "iPhone13,1": .iPhone12Mini,
      "iPhone13,2": .iPhone12,
      "iPhone13,3": .iPhone12Pro,
      "iPhone13,4": .iPhone12ProMax,
      "iPhone14,2": .iPhone13Pro,
      "iPhone14,3": .iPhone13ProMax,
      "iPhone14,4": .iPhone13Mini,
      "iPhone14,5": .iPhone13,
      "iPhone14,6": .iPhoneSE3rdGen,
      "iPhone14,7": .iPhone14,
      "iPhone14,8": .iPhone14Plus,
      "iPhone15,2": .iPhone14Pro,
      "iPhone15,3": .iPhone14ProMax
    ]

    if let model = modelMap[modelCode] {
      return model
    }

    return Model.unrecognized
  }
}
