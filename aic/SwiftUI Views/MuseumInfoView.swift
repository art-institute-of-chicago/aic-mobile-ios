//
//  MuseumInfoView.swift
//  aic
//
//  Created by David Bireta on 2/20/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct MuseumInfoView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text(.Info.museumInfoAction)
                .aicOldFontStyle(.audioButton)
            
            Divider()
            
            Text(.Info.infoMuseumHours)
                .aicOldFontStyle(.infoMenuText)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            Text("111 S Michigan Ave")
                .aicOldFontStyle(.infoMenuText)
            
            Text("Chicago, IL 60603")
                .aicOldFontStyle(.infoMenuText)
                .padding(.bottom)
            
            Text("+1 312 443 3600")
                .aicOldFontStyle(.infoMenuText)
            
            Spacer()
        }
        .padding()
        .toolbarBackground(.infoBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    MuseumInfoView()
}
