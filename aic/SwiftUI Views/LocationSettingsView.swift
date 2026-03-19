//
//  LocationSettingsView.swift
//  aic
//
//  Created by David Bireta on 2/20/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import CoreLocation
import SwiftUI

struct LocationSettingsView: View {
    @Environment(\.openURL) private var openURL
    
    // TODO: Refactor this out to a separate class
    private let locationManager = CLLocationManager()
    
    var body: some View {
        VStack(spacing: 24) {
            Text(.Location.locationSettingsHeader)
                .aicOldFontStyle(.audioButton)
            
            Divider()
            
            Text(.Location.locationSettingsBody)
                .aicOldFontStyle(.infoMenuText)
                .padding(.bottom)
            
            Button(buttonTitle) {
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                } else if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .buttonStyle(AICButtonStyle())
            
            Spacer()
        }
        .padding()
        .toolbarBackground(.infoBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension LocationSettingsView {
    private var buttonTitle: LocalizedStringResource {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
                case .notDetermined:
                    return .Location.locationSettingsTitle
                case .restricted, .denied:
                    return .Location.locationsSettingsLocationDisabled
                case .authorizedAlways, .authorizedWhenInUse:
                    return .Location.locationsSettingsLocationEnabled
                @unknown default:
                    return .Location.locationSettingsTitle
            }
        } else {
            return .Location.locationsSettingsLocationDisabled
        }
    }
}

#Preview {
    LocationSettingsView()
}

struct AICButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .aicOldFontStyle(.actionButton)
            .padding()
            .padding(.horizontal)
            .foregroundStyle(.white)
            .background(Color.infoBackground)
    }
}
