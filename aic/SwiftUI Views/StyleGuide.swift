//
//  StyleGuide.swift
//  aic
//
//  Created by David Bireta on 2/17/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct StyleGuide {
    struct Fonts {
        enum OldStyle {
            case title, subtitle, overlay, sectionHeader, bigTitle, audioButton, actionButton, infoMenuText
            
            var size: Double {
                switch self {
                    case .title:
                        21
                    case .subtitle:
                        17
                    case .overlay:
                        13
                    case .sectionHeader:
                        21
                    case .bigTitle:
                        30
                    case .audioButton:
                        30
                    case .actionButton:
                        13
                    case .infoMenuText:
                        16
                }
            }
            
            var fontName: String {
                switch self {
                    case .title:
                        "IdealSans-Medium"
                    case .subtitle:
                        "Amiri-Regular"
                    case .overlay:
                        "IdealSans-Book"
                    case .sectionHeader:
                        "IdealSans-Book"
                    case .bigTitle:
                        "IdealSans-Medium"
                    case .audioButton:
                        "IdealSans-Book"
                    case .actionButton:
                        "IdealSans-Medium"
                    case .infoMenuText:
                        "IdealSans-Book"
                }
            }
            
            var correspondingDynamicTypeStyle: Font.TextStyle {
                switch self {
                    case .title:
                            .title2
                    case .subtitle:
                            .headline
                    case .overlay:
                            .body
                    case .sectionHeader:
                            .headline
                    case .bigTitle:
                            .title
                    case .audioButton:
                            .title
                    case .actionButton:
                            .body
                    case .infoMenuText:
                            .title3
                }
            }
        }
    }
}

extension View {
    func aicOldFontStyle(_ style: StyleGuide.Fonts.OldStyle) -> some View {
        self.modifier(AICOldFontModifier(aicOldStyle: style))
    }
}

struct AICOldFontModifier: ViewModifier {
    let aicOldStyle: StyleGuide.Fonts.OldStyle
    
    @ScaledMetric private var scaledSize: CGFloat
    
    init(aicOldStyle: StyleGuide.Fonts.OldStyle) {
        self.aicOldStyle = aicOldStyle
        self._scaledSize = ScaledMetric(wrappedValue: aicOldStyle.size, relativeTo: aicOldStyle.correspondingDynamicTypeStyle)
    }
    
    func body(content: Content) -> some View {
        content.font(liningFiguresFont)
    }
    
    private var liningFiguresFont: Font {
        guard let baseFont = UIFont(name: aicOldStyle.fontName, size: scaledSize) else {
            return .custom(aicOldStyle.fontName, size: scaledSize)
        }
        
        let fontDescriptor = baseFont.fontDescriptor.addingAttributes([
            .featureSettings: [
                [UIFontDescriptor.FeatureKey.type: kNumberCaseType, UIFontDescriptor.FeatureKey.selector: kUpperCaseNumbersSelector]
            ]
        ])
        
        let modifiedFont = UIFont(descriptor: fontDescriptor, size: scaledSize)
        return Font(modifiedFont as CTFont)
    }
}
