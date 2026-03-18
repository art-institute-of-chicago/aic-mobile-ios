//
//  AudioScreen.swift
//  aic
//
//  Created by David Bireta on 2/6/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI
import Localize_Swift

struct AudioScreen: View {
    let selectedTourAction: (AICTourModel, Int) -> Void
    let selectedObjectAction: (AICObjectModel, Int) -> Void
    
    @State private var code = ""
    @State private var attempts = 0
    @ScaledMetric private var leading = 20
    @ScaledMetric private var spacing = 16
    
    var body: some View {
            ScrollView {
                VStack {
                    Image(.iconNumPad)
                        .frame(height: 32)

                    if code.isEmpty {
                        Text(AppDataManager.sharedInstance.app.generalInfo.audioTitle)
                            .aicOldFontStyle(.bigTitle)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(code)
                            .aicOldFontStyle(.bigTitle)
                            .modifier(ShakeEffect(animatableData: CGFloat(attempts)))
                    }
                        
                    Text(AppDataManager.sharedInstance.app.generalInfo.audioSubtitle)
                        .aicOldFontStyle(.subtitle)
                        .requestTightLineHeight(points: leading)
                        .padding(.horizontal)
                        .padding(.bottom, 48)

                    Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
                        GridRow {
                            CircleButton(text: "1") { code.append($0) }
                            CircleButton(text: "2") { code.append($0) }
                            CircleButton(text: "3") { code.append($0) }
                        }
                        
                        GridRow {
                            CircleButton(text: "4") { code.append($0) }
                            CircleButton(text: "5") { code.append($0) }
                            CircleButton(text: "6") { code.append($0) }
                        }
                        
                        GridRow {
                            CircleButton(text: "7") { code.append($0) }
                            CircleButton(text: "8") { code.append($0) }
                            CircleButton(text: "9") { code.append($0) }
                        }
                        
                        GridRow {
                            Button {
                                if code.isEmpty == false {
                                    code.removeLast()
                                }
                            } label: {
                                Image(.deleteButton)
                            }
                            
                            CircleButton(text: "0") { code.append($0) }
                            
                            CircleButton(text: goString) { _ in handleCode() }
                                .disabled(code.isEmpty)
                        }
                    }
                    
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding()
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .frame(maxWidth: .infinity)
            .background(Color.audioBackground)
    }
}

extension AudioScreen {
    private var goString: String {
        var resource = LocalizedStringResource("Go", table: "Audio")
        resource.locale = Locale(identifier: Localize.currentLanguage())
        let translatedString = String(localized: resource)
        
        return translatedString
    }
    
    private func handleCode() {
        guard let codeValue = Int(code) else { return }
        
        if let tour = AppDataManager.sharedInstance.getTour(forSelectorNumber: codeValue) {
            selectedTourAction(tour, codeValue)
        } else if let object = AppDataManager.sharedInstance.getObject(forSelectorNumber: codeValue) {
            selectedObjectAction(object, codeValue)
        } else {
            withAnimation(.easeInOut(duration: 0.7)) {
                attempts += 1
            }
            
            AICAnalytics.sendErrorAudioGuideBadNumberEvent(number: codeValue)
        }
    }
    
    private struct CircleButton: View {
        let text: String
        let action: (String) -> Void
        
        var pad = 64.0
        
        var body: some View {
            Button(action: { action(text) }) {
                Circle()
                    .stroke(.white.opacity(0.5), lineWidth: 2)
                    .frame(width: pad, height: pad)
                    .overlay (
                        Text(text)
                            .aicOldFontStyle(.audioButton)
                    )
            }
        }
    }
}

#Preview {
    Localize.setCurrentLanguage("es")
    
    return AudioScreen { _, _ in } selectedObjectAction: { _, _ in }
}
