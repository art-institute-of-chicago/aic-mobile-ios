/*
 Abstract:
 The view that shows the loading bar
 */

import UIKit

class LoadingView: UIView {
    let progressMarginTop = UIScreen.main.bounds.height * CGFloat(0.42)
    let progressSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(0.45), height: 1)

    let loadingImage = UIImageView()
    let progressBackgroundView = UIView()
    let progressHighlightView = UIView()
    let progressView = UIView()
    
    init() {
        super.init(frame:UIScreen.main.bounds)
        
        // Configure
        if let image = splashImage(forOrientation: UIApplication.shared.statusBarOrientation, screenSize: UIScreen.main.bounds.size) {
            loadingImage.image = UIImage(named: image)
        }
        
        //progressHighlightView.layer.cornerRadius = progressSize.height
        progressBackgroundView.backgroundColor = .lightGray
        progressHighlightView.backgroundColor = .white
        
        // Add Subviews
        progressView.addSubview(progressBackgroundView)
        progressView.addSubview(progressHighlightView)
        
        addSubview(loadingImage)
        addSubview(progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgressBarPct(_ pct:Float) {
        progressHighlightView.snp.updateConstraints { (make) -> Void in
            make.width.equalTo((progressSize.width * CGFloat(pct)))
        }
        
        layoutIfNeeded()
    }
    
    override func updateConstraints() {
        loadingImage.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview!)
        }
        
        progressView.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(progressMarginTop)
            make.centerX.equalTo(progressView.superview!)
            make.width.equalTo(progressSize.width)
            make.height.equalTo(progressSize.height)
        }
        
        progressBackgroundView.snp.makeConstraints { (make) -> Void in
            make.top.left.equalTo(progressBackgroundView.superview!)
            make.size.equalTo(progressSize)
        }
        
        progressHighlightView.snp.makeConstraints { (make) -> Void in
            make.top.left.equalTo(progressHighlightView.superview!)
            make.width.equalTo(0)
            make.height.equalTo(progressSize.height)
        }
        
        super.updateConstraints()
    }
}
