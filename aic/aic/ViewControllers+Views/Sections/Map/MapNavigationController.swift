//
//  MapNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/25/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol MapNavigationControllerDelegate : class {
	
}

class MapNavigationController : SectionNavigationController {
	let mapVC: MapViewController = MapViewController()
	
	weak var sectionDelegate: MapNavigationControllerDelegate? = nil
	
	override init(section: AICSectionModel) {
		super.init(section: section)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		mapVC.delegate = self
		
		self.pushViewController(mapVC, animated: false)
	}
}

