//
//  Array+AIC.swift
//  aic
//
//  Created by David Bireta on 3/15/25.
//  Copyright © 2025 Art Institute of Chicago. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else { return nil }

        return self[index]
    }
}
