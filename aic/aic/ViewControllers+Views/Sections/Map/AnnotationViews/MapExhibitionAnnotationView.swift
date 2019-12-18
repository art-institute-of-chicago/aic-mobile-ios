//
//  MapExhibitionAnnotationView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/22/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import Kingfisher

class MapExhibitionAnnotationView: MapAnnotationView {
	static let reuseIdentifier: String = "mapExhibition"

	private let thumbImageView = AICImageView()
	private let thumbHolderView = UIView() // Circle frame with tail
	private let thumbHolderTailView = UIImageView()

	private let thumbHolderWidth: CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2
	private let thumbHolderHeight: CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		guard let exhibitionAnnotation = annotation as? MapExhibitionAnnotation else {
			super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
			return
		}
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		// Configure
		backgroundColor = .clear
		layer.zPosition = Common.Map.AnnotationZPosition.objectsSelected.rawValue + CGFloat(exhibitionAnnotation.floor)

		//        self.layer.masksToBounds = false
		//        self.layer.shadowOffset = CGSizeMake(0, 0)
		//        self.layer.shadowRadius = 5
		//        self.layer.shadowOpacity = 0.5
		self.layer.drawsAsynchronously = true
		//self.layer.shouldRasterize = true

		thumbHolderView.frame = CGRect(x: 0, y: 0, width: thumbHolderWidth, height: thumbHolderHeight)
		//		thumbHolderView.layer.cornerRadius = thumbHolderWidth/2.0
		thumbHolderView.backgroundColor = .white

		thumbHolderTailView.image = #imageLiteral(resourceName: "calloutTail")
		thumbHolderTailView.sizeToFit()
		thumbHolderTailView.frame.origin = CGPoint(x: thumbHolderWidth/2 - thumbHolderTailView.frame.width/2, y: thumbHolderView.frame.height - thumbHolderTailView.frame.height/2)

		thumbImageView.contentMode = .scaleAspectFill
		//		thumbImageView.layer.cornerRadius = Common.Map.thumbSize/2
		thumbImageView.layer.masksToBounds = true
		thumbImageView.frame.origin = CGPoint(x: Common.Map.thumbHolderMargin, y: Common.Map.thumbHolderMargin)
		thumbImageView.frame.size = CGSize(width: Common.Map.thumbSize, height: Common.Map.thumbSize)
		thumbImageView.isUserInteractionEnabled = false

		// Add Subviews
		addSubview(thumbHolderTailView)
		addSubview(thumbHolderView)
		addSubview(thumbImageView)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var exhibitionModel: AICExhibitionModel? = nil {
		didSet {
			guard let exhibitionModel = self.exhibitionModel else {
				return
			}

			thumbImageView.kf.setImage(with: exhibitionModel.imageUrl)
			self.bounds = self.thumbHolderView.frame.union(self.thumbHolderTailView.frame)
			let transformedBounds = self.bounds.applying(transform)
			centerOffset = CGPoint(x: 0, y: -transformedBounds.height/2)
		}
	}
}
