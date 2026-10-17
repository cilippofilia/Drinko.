//
//  RemoveAdsLegalLinks.swift
//  DrinkoPro
//

import Foundation

enum RemoveAdsLegalLinks {
    /// Apple's Standard EULA, since App Store Connect has no custom one.
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    /// Must match the Privacy Policy URL in App Store Connect.
    static let privacyPolicy = URL(string: "https://www.freeprivacypolicy.com/live/7ea5ef2c-3185-4f3e-97af-9db143f825b8")!
}
