//
//  GeneralCrashlyticsReport.swift
//  aic
//
//  Created by David Bireta on 5/17/25.
//  Copyright © 2025 Art Institute of Chicago. All rights reserved.
//

import Foundation

struct GeneralCrashlyticsReport: CrashlyticsReport {
    var error: any Error
    var log: String
    
    
}

enum GeneralError: Error {
    case general
}
