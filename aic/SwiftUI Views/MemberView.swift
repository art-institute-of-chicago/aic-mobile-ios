//
//  MemberView.swift
//  aic
//
//  Created by David Bireta on 2/20/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct MemberView: View {
    @State private var memberID: String = ""
    @State private var zipCode: String = ""
    
    @StateObject private var memberManager = MemberDataManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            if let currentMemberCard = memberManager.currentMemberCard {
                Text(currentMemberCard.memberNames[safeIndex: memberManager.currentMemberNameIndex] ?? "")
                
                Text(.AccessCard.memberCardMemberId(currentMemberCard.cardId))
                
                Text(currentMemberCard.memberLevel)
                
                Text(.AccessCard.memberCardExpires(currentMemberCard.expirationDate.formatted(date: .numeric, time: .omitted)))
                    .padding(.bottom)
                
                if let barcodeImage {
                    barcodeImage
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .border(.black)
                }
                
                if currentMemberCard.isReciprocalMember {
                    Image(.reciprocalLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                }
                
                Button(.AccessCard.memberCardChangeInformationAction) {
                    handleChange()
                }
                .buttonStyle(AICButtonStyle())
                
                if currentMemberCard.memberNames.count > 1 {
                    Button(.AccessCard.memberCardSwitchCardholderAction) {
                        handleSwitchMember()
                    }
                    .buttonStyle(AICButtonStyle())
                }
            } else {
                Text(.AccessCard.signInMemberIdHeader)
                
                TextField(text: $memberID) {
                    Text(.AccessCard.signInMemberIdPlaceholder)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                
                Text(.AccessCard.signInZipCodeHeader)
                
                TextField(text: $zipCode) {
                    Text(.AccessCard.signInZipCodePlaceholder)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                
                Button(.AccessCard.signInAction) {
                    handleSignIn()
                }
                .buttonStyle(AICButtonStyle())
                
                Spacer()
                
                Text(.AccessCard.infoQuickActionPrompt)
                    .italic()
                    .padding(.bottom)
            }
        }
        .aicOldFontStyle(.infoMenuText)
        .padding()
        .navigationTitle("Member Card")
        .toolbarBackground(.infoBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension MemberView {
    private func handleSignIn() {
        memberManager.validateMember(memberID: memberID, zipCode: zipCode)
    }
    
    private func handleChange() {
        memberManager.deleteSavedMember()
    }
    
    private func handleSwitchMember() {
        memberManager.switchMember()
    }
    
    private var barcodeImage: Image? {
        guard let currentMemberCard = memberManager.currentMemberCard else { return nil }
        
        let context = CIContext()
        let filter = CIFilter.pdf417BarcodeGenerator()
        filter.message = Data(currentMemberCard.cardId.utf8)
        
        if let barcodeCIImage = filter.outputImage {
            if let cgImage = context.createCGImage(barcodeCIImage, from: barcodeCIImage.extent) {
                let barcodeImage = UIImage(cgImage: cgImage)
                return Image(uiImage: barcodeImage)
            }
        }
        
        return nil
    }
}

#Preview {
    NavigationStack {
        MemberView()
    }
}
