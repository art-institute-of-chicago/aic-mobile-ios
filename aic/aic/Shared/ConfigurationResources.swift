//
//  ConfigurationResources.swift
//  aic
//
//  Copyright © 2024 Art Institute of Chicago. All rights reserved.
//

import Foundation

struct ConfigurationResources {
    private enum Root: String {
        case test = "Testing"
        case dataConstants = "DataConstants"
        var key: String { self.rawValue }

        enum Test: String {
            case printDataErrors = "printDataErrors"
            var key: String { self.rawValue }
        }

        enum DataConstants: String {
            case appDataURL = "appDataJSON"
            case memberCardSOAPRequestURL = "memberCardSOAPRequestURL"
            case ignoreOverrideImageCrop = "ignoreOverrideImageCrop"
            case iiifUserAgentHeaderValue = "iiifUserAgentHeaderValue"
            var key: String { self.rawValue }
        }
    }

    private let plistFile: PlistFile

    init(plistFile: PlistFile) {
        self.plistFile = plistFile
    }

    func enableErrorConsoleOutput() -> Bool {
        guard let result = try? value(
            in: .test,
            key: Root.Test.printDataErrors.key
        ) as? Bool else { return false }
        return result
    }

    func appDataURL() -> String? {
        let result = try? value(
            in: .dataConstants,
            key: Root.DataConstants.appDataURL.key
        ) as? String
        return result
    }

    func memberCardSOAPRequestURL() -> String? {
        let result = try? value(
            in: .dataConstants,
            key: Root.DataConstants.memberCardSOAPRequestURL.key
        ) as? String
        return result
    }

    func iiifUserAgentHeaderValue() -> String? {
        let result = try? value(
            in: .dataConstants,
            key: Root.DataConstants.iiifUserAgentHeaderValue.key
        ) as? String
        return result
    }

    func enableIgnoreOverrideImageCrop() -> Bool {
        guard let result = try? value(
            in: .dataConstants,
            key: Root.DataConstants.ignoreOverrideImageCrop.key
        ) as? Bool else { return false }
        return result
    }

    private func value(in container: Root, key: String) throws -> Any {
        let content = try plistFile.content()
        guard let value = content[container.key] as? [String: Any] else {
            throw CocoaError(.keyValueValidation)
        }

        if let result = value[key] {
            return result
        } else {
            throw CocoaError(.keyValueValidation)
        }
    }
}
