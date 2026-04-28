//
//  MuseumInfoView.swift
//  aic
//
//  Created by David Bireta on 2/20/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct MuseumInfoView: View {
    let buildingHours: AICBuildingHours
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(.Info.museumInfoAction)
                    .aicOldFontStyle(.audioButton)
                    .frame(maxWidth: .infinity)
                
                Divider()
                
                Label("Hours", systemImage: "clock")
                    .aicOldFontStyle(.infoMenuText)
                
                Text(buildingHours.data.first?.additional_text ?? "no hours")
                    .foregroundStyle(.secondary)

                VStack {
                    HStack {
                        Text(weekdayNames[1])
                        Spacer()
                        Text(buildingHours.displayString(for: .monday))
                    }
                    Divider()

                    HStack {
                        Text(weekdayNames[2])
                        Spacer()
                        Text(buildingHours.displayString(for: .tuesday))
                    }
                    .foregroundStyle(.secondary)
                    Divider()

                    HStack {
                        Text(weekdayNames[3])
                        Spacer()
                        Text(buildingHours.displayString(for: .wednesday))
                    }
                    Divider()

                    HStack {
                        Text(weekdayNames[4])
                        Spacer()
                        Text(buildingHours.displayString(for: .thursday))
                    }
                    Divider()

                    HStack {
                        Text("\(weekdayNames[5]) - \(weekdayNames[0])")
                        Spacer()
                        Text(buildingHours.displayString(for: .friday))
                    }
                }
                
                // TODO: This is not included in the /hours response
                Text("The museum is closed Thanksgiving, Christmas, and New Year's Day.")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 48)
                
                // Map Info
                VStack(alignment: .leading, spacing: 12) {
                    Label("Location and Directions", systemImage: "location.circle")
                        .aicOldFontStyle(.infoMenuText)
                    
                    VStack(alignment: .leading) {
                        Text("**Michigan Avenue Entrance**")
                        Button {
                            let mapURL = URL(string: "http://maps.apple.com/?address=111,S,Michigan,Ave,Chicago,IL,60603")!
                            UIApplication.shared.open(mapURL)
                        } label: {
                            VStack(alignment: .leading) {
                                Text("111 S Michigan Ave")
                                Text("Chicago, IL 60603")
                            }
                            .aicOldFontStyle(.infoMenuText)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    VStack(alignment: .leading) {
                        Text("**Modern Wing Entrance**")
                        Button {
                            let mapURL = URL(string: "http://maps.apple.com/?address=159,East,Monroe,Street")!
                            UIApplication.shared.open(mapURL)
                        } label: {
                            VStack(alignment: .leading) {
                                Text("159 East Monroe Street")
                                Text("Chicago, IL 60603")
                            }
                            .aicOldFontStyle(.infoMenuText)
                        }
                    }
                }
                
                Spacer()
            }
            .aicOldFontStyle(.infoMenuText)
            .padding()
            .toolbarBackground(.infoBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

extension MuseumInfoView {
    private var weekdayNames: [String] {
        let cal = Calendar.current
        return cal.weekdaySymbols
    }
}

#Preview {
    MuseumInfoView(buildingHours: .preview)
}
