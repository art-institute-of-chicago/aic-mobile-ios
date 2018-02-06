/*
 Abstract:
 Fonts for the app
 */

import UIKit

extension UIFont {
	static let aicSectionBigTitleFont: UIFont = UIFont(name: "IdealSans-Medium", size: 40.0)!
	
	static let aicSectionTitleFont: UIFont = UIFont(name: "IdealSans-Medium", size: 30.0)!.upperCaseNumbers()
	
	static let aicSectionDescriptionFont: UIFont = UIFont(name: "SabonNextLTPro-Regular", size: 16.0)!

	static let aicNumberPadFont: UIFont = UIFont(name: "SourceSansPro-Regular", size: 30.0)!.upperCaseNumbers()

	static let aicHeaderSmallFont: UIFont = UIFont(name: "SourceSansPro-Black", size: 26.0)!

	static let aicFloorSelectorFont: UIFont = UIFont(name: "SourceSansPro-Regular", size: 21.0)!

//    static let aicTitleFont: UIFont = UIFont(name: "SourceSansPro-Bold", size: 22.0)!

	static let aicItalicTextFont: UIFont = UIFont(name: "Lora-Italic", size: 17.0)!

//	static let aicTextFont: UIFont = UIFont(name: "Lora-Regular", size: 17.0)!

	static let aicShortTextFont: UIFont = UIFont(name: "Lora-Regular", size: 17.0)!

	static let aicSystemTextFont: UIFont = UIFont(name: "SourceSansPro-Regular", size: 17.0)!
    
    static let aicDepartmentsFont: UIFont = UIFont(name: "SourceSansPro-Semibold", size: 17.0)!
    
    static let aicSpacesFont: UIFont = UIFont(name: "SourceSansPro-It", size: 17.0)!
    
    static let aicMapSVGTextFont: UIFont = UIFont(name: "SourceSansPro-Regular", size: 9.0)!
    
    static let aicInstructionsSubtitleFont: UIFont = UIFont(name: "SourceSansPro-Regular", size: 19.0)!
    
    static let aicInstructionsTitleFont: UIFont = UIFont(name: "SourceSansPro-Black", size: 30.0)!
    
    static let aicMapSVGTextFontFont: UIFont = UIFont(name: "SourceSansPro-Regular", size: 9.0)!
	
	static let aicTitleFont: UIFont = UIFont(name: "IdealSans-Medium", size: 21.0)!
	
	static let aicTextFont: UIFont = UIFont(name: "IdealSans-Book", size: 16.0)!
	
	static let aicButtonFont: UIFont = UIFont(name: "IdealSans-Medium", size: 13.0)!
	
	static let aicPotionCreditsFont: UIFont = UIFont(name: "IdealSans-Book", size: 13.0)!
	
	static let aicHomeCollectionTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 21.0)!
	
	static let aicHomeSeeAllFont: UIFont = UIFont(name: "IdealSans-Book", size: 13.0)!
	
	static let aicHomeTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 21.0)!
	
	static let aicHomeSmallTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 17.0)!
	
	static let aicHomeShortTextFont: UIFont = UIFont(name: "SabonNextLTPro-Regular", size: 14)!
	
	static let aicSearchBarFont: UIFont = UIFont(name: "IdealSans-Book", size: 17.0)!
	
	static let aicSearchResultsFilterFont: UIFont = UIFont(name: "IdealSans-Book", size: 18.0)!
	
	static let aicSearchResultsSectionTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 13.0)!
	
	static let aicInfoSectionTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 28.0)!
	
	static let aicInfoSectionTextFont: UIFont = UIFont(name: "IdealSans-Book", size: 16.0)!
	
	static let aicCardTitleFont: UIFont = UIFont(name: "IdealSans-Medium", size: 21.0)!
	
	static let aicCardDescriptionFont: UIFont = UIFont(name: "SabonNextLTPro-Regular", size: 16.0)!
	
	static let aicSeeAllHeaderFont: UIFont = UIFont(name: "IdealSans-Medium", size: 21.0)!
	
	static let aicLanguageSelectionTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 28.0)!
	
	static let aicLanguageSelectionTextFont: UIFont = UIFont(name: "IdealSans-Book", size: 16.0)!
	
	static let aicLoadingWelcomeFont: UIFont = UIFont(name: "IdealSans-Book", size: 45.0)!
    
    static let aicMiniPlayerTrackTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 16.0)!
	
	static let aicAudioPlayerTrackTitleFont: UIFont = UIFont(name: "IdealSans-Medium", size: 21.0)!
	
	static let aicAudioPlayerTimeRemainingFont: UIFont = UIFont(name: "IdealSans-Book", size: 14.0)!
	
	static let aicAudioInfoSectionTitleFont: UIFont = UIFont(name: "IdealSans-Book", size: 21.0)!
	
	static let aicMapCardTitleFont: UIFont = UIFont(name: "IdealSans-Medium", size: 21.0)!
	
	static let aicMapCardBoldTextFont: UIFont = UIFont(name: "IdealSans-Medium", size: 16.0)!
	
	static let aicMapCardTextFont: UIFont = UIFont(name: "IdealSans-Book", size: 16.0)!
	
	func upperCaseNumbers() -> UIFont {
		let originalFontDescriptor = self.fontDescriptor
		
		// Everry Font feature has a specific identifier (ex: "Number Case" is 21)
		// Full list of font features identifiers and values here: https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html#Type1
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
