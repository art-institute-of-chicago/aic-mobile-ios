//
//  LAContext+BiometryType.swift
//  aic
//
//  Copyright © 2024 Art Institute of Chicago. All rights reserved.
//

import LocalAuthentication

extension LAContext {
    var biometricType: LABiometryType {
        var error: NSError?

        guard canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            return .none
        }
        
        return self.biometryType
    }
}
