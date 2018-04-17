//
//  AudioGuideViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 3/27/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class AudioGuideViewController : UIViewController {
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Log analytics
		AICAnalytics.trackScreenView("Audio Guide", screenClass: "AudioGuideViewController")
	}
}
