/*
Abstract:
Custom image view that adds
async network loading with indicator
*/

import UIKit
import Alamofire

protocol AICImageViewDelegate: class {
	func aicImageViewDidFinishLoadingImageAsynchronously()
}

class AICImageView: UIImageView {
	static var manager: Alamofire.SessionManager?
	weak var delegate: AICImageViewDelegate?

	private var imageRequest: Alamofire.Request?
	private var loadingIndicatorView = UIActivityIndicatorView()

	init() {
		super.init(frame: CGRect.zero)
		self.backgroundColor = .gray

		if AICImageView.manager == nil {
			let configuration = URLSessionConfiguration.default
			configuration.httpMaximumConnectionsPerHost =  5
			configuration.timeoutIntervalForRequest = 30
			AICImageView.manager = Alamofire.SessionManager(configuration: configuration)
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.backgroundColor = .gray

		if AICImageView.manager == nil {
			let configuration = URLSessionConfiguration.default
			configuration.httpMaximumConnectionsPerHost =  5
			configuration.timeoutIntervalForRequest = 30
			AICImageView.manager = Alamofire.SessionManager(configuration: configuration)
		}
	}

	override func layoutSubviews() {
		if self.image == nil {
			let centeredX = frame.size.width/2 - loadingIndicatorView.frame.size.width/2
			let centeredY = frame.size.height/2 - loadingIndicatorView.frame.size.height/2

			loadingIndicatorView.frame.origin = CGPoint(x: centeredX, y: centeredY)

			if let topView = subviews.last {
				insertSubview(loadingIndicatorView, aboveSubview: topView)
			}
		} else {
			super.layoutSubviews()
		}
	}

	func loadImageAsynchronously(fromUrl url: URL, withCropRect cropRect: CGRect?) {
		// Clear our current image and cancel any pending image loads
		image = nil
		if let request = self.imageRequest {
			request.cancel()
		}

		loadingIndicatorView.startAnimating()
		addSubview(loadingIndicatorView)

		self.imageRequest = AICImageView.manager!.request(url).responseData { [weak self] (response) in
			if cropRect == nil {
				self?.image = UIImage(data: NSData(data: response.data!) as Data)
			} else {
				let uncroppedImage = UIImage(data: NSData(data: response.data!) as Data)
				if uncroppedImage != nil {
					let imageCropRect = CGRect(x: cropRect!.origin.x * uncroppedImage!.size.width, y: cropRect!.origin.y * uncroppedImage!.size.height, width: cropRect!.width * uncroppedImage!.size.width, height: cropRect!.height * uncroppedImage!.size.height)
					self?.image = UIImage(cgImage: (uncroppedImage!.cgImage!.cropping(to: imageCropRect))!)
					//If you'd like to verify the crops set a breakpoint here and
					//take a look at uncroppedImage vs croppedImage
					//let croppedImage = self?.image
				}
			}
			self?.imageRequest = nil

			self?.loadingIndicatorView.removeFromSuperview()

			self?.updateConstraints()
			self?.delegate?.aicImageViewDidFinishLoadingImageAsynchronously()
		}
	}

	func cancelLoading() {
		imageRequest?.cancel()
	}
}
