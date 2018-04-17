/*
 Abstract:
 Fonts for the app
 */

import UIKit

extension UIFont {
	static let aicHomeSectionTitleFont: UIFont = UIFont(name: SansSerif_Medium, size: 40.0)!.upperCaseNumbers()
	
	static let aicSectionTitleFont: UIFont = UIFont(name: SansSerif_Medium, size: 30.0)!.upperCaseNumbers()
	
	static let aicSectionDescriptionFont: UIFont = UIFont(name: Serif_Regular, size: 16.0)!.upperCaseNumbers()
	
	static let aicTitleFont: UIFont = UIFont(name: SansSerif_Medium, size: 21.0)!.upperCaseNumbers()
	
	static let aicTextFont: UIFont = UIFont(name: Serif_Regular, size: 16.0)!.upperCaseNumbers()
	
	static let aicTextBoldFont: UIFont = UIFont(name: Serif_Bold, size: 16.0)!.upperCaseNumbers()
	
	static let aicTextItalicFont: UIFont = UIFont(name: Serif_Italic, size: 16.0)!.upperCaseNumbers()
	
	static let aicPageTitleFont: UIFont = UIFont(name: SansSerif_Book, size: 28.0)!.upperCaseNumbers()
	
	static let aicPageTextFont: UIFont = UIFont(name: SansSerif_Book, size: 16.0)!.upperCaseNumbers()
	
	static let aicButtonFont: UIFont = UIFont(name: SansSerif_Medium, size: 13.0)!.upperCaseNumbers()

	static let aicNumberPadFont: UIFont = UIFont(name: SansSerif_Book, size: 30.0)!.upperCaseNumbers()
    
    static let aicMapSpacesFont: UIFont = UIFont(name: SansSerif_Medium, size: 16.0)!.upperCaseNumbers()
	
	static let aicMapTextFont: UIFont = UIFont(name: SansSerif_Medium, size: 15.0)!.upperCaseNumbers()
	
	static let aicMapDepartmentTextFont: UIFont = UIFont(name: SansSerif_Book, size: 16.0)!.upperCaseNumbers()
	
	static let aicMapObjectTextFont: UIFont = UIFont(name: SansSerif_Book, size: 15.0)!.upperCaseNumbers()
	
	static let aicPotionCreditsFont: UIFont = UIFont(name: SansSerif_Book, size: 13.0)!.upperCaseNumbers()
	
	static let aicContentTitleFont: UIFont = UIFont(name: SansSerif_Book, size: 21.0)!.upperCaseNumbers()
	
	static let aicHomeSeeAllFont: UIFont = UIFont(name: SansSerif_Book, size: 13.0)!.upperCaseNumbers()
	
	static let aicHomeTitleFont: UIFont = UIFont(name: SansSerif_Book, size: 21.0)!.upperCaseNumbers()
	
	static let aicHomeSmallTitleFont: UIFont = UIFont(name: SansSerif_Book, size: 17.0)!.upperCaseNumbers()
	
	static let aicHomeShortTextFont: UIFont = UIFont(name: Serif_Regular, size: 14)!.upperCaseNumbers()
	
	static let aicSearchBarFont: UIFont = UIFont(name: SansSerif_Book, size: 17.0)!.upperCaseNumbers()
	
	static let aicSearchResultsFilterFont: UIFont = UIFont(name: SansSerif_Book, size: 18.0)!.upperCaseNumbers()
	
	static let aicSearchResultsSectionTitleFont: UIFont = UIFont(name: SansSerif_Book, size: 13.0)!.upperCaseNumbers()
	
	static let aicSearchNoResultsMessageFont: UIFont = UIFont(name: SansSerif_BookItalic, size: 16.0)!.upperCaseNumbers()
	
	static let aicSearchNoResultsWebsiteFont: UIFont = UIFont(name: SansSerif_BookItalic, size: 13.0)!.upperCaseNumbers()
	
	static let aicLoadingWelcomeFont: UIFont = UIFont(name: SansSerif_Book, size: 45.0)!.upperCaseNumbers()
	
	static let aicAudioPlayerTimeRemainingFont: UIFont = UIFont(name: SansSerif_Book, size: 14.0)!.upperCaseNumbers()
	
	static let aicAudioInfoSectionTitleFont: UIFont = UIFont(name: SansSerif_Book, size: 21.0)!.upperCaseNumbers()
	
	static let aicContentButtonTitleFont: UIFont = UIFont(name: SansSerif_Medium, size: 16.0)!.upperCaseNumbers()
	
	static let aicContentButtonSubtitleFont: UIFont = UIFont(name: SansSerif_Book, size: 16.0)!.upperCaseNumbers()
	
	static let aicMemberCardLoginFieldFont: UIFont = UIFont(name: SansSerif_Book, size: 17.0)!.upperCaseNumbers()
	
	static let aicMapDepartmentLabelFont: UIFont = UIFont(name: SansSerif_Book, size: 13.0)!.upperCaseNumbers()
	
	static let aicTooltipDismissFont: UIFont = UIFont(name: SansSerif_Book, size: 13.0)!.upperCaseNumbers()
	
	static let aicInfoOverlayFont: UIFont = UIFont(name: SansSerif_Book, size: 13.0)!.upperCaseNumbers()
	
	static let aicSeeAllTitleFont: UIFont = UIFont(name: SansSerif_Medium, size: 17.0)!.upperCaseNumbers()
	
	static let aicSeeAllInfoFont: UIFont = UIFont(name: SansSerif_Book, size: 12.0)!.upperCaseNumbers()
	
	/// Font modified to use uppercase numbers
	///
	/// Every Font feature has a specific identifier (ex: "Number Case" is 21).
	/// Full list of font features identifiers and values here:
	/// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html#Type1
	/// Implementation based on:
	/// https://stackoverflow.com/questions/46450875/ios-opentype-font-features-in-swift
	///
	func upperCaseNumbers() -> UIFont {
		let originalFontDescriptor = self.fontDescriptor
		
		let numberCaseFeatureIdentifier = 21
		let upperCaseSelectorValue = 1
		let featureSettings = [
			[ UIFontDescriptor.FeatureKey.featureIdentifier: numberCaseFeatureIdentifier,
			  UIFontDescriptor.FeatureKey.typeIdentifier: upperCaseSelectorValue]
		]
		
		let attributes = [UIFontDescriptor.AttributeName.featureSettings: featureSettings]
		let fontDescriptor =  originalFontDescriptor.addingAttributes(attributes)
		let font = UIFont(descriptor: fontDescriptor, size: 0)
		
		return font
	}
}
