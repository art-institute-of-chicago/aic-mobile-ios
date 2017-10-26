/*
 Abstract:
 Section View controller for Tours Section
*/

import UIKit

class ToursSectionStopsScrollerView: NewsToursRevealView {
    
    // Delegate
    var delegate:ToursSectionViewControllerDelegate?
    
    // Associated data model
    var tourModel:AICTourModel? = nil
    
    // Layout
    let height = 185
    let stopsMargins = UIEdgeInsetsMake(20, 0, 10, 0)
    
    let focusedStopLabelMargins = UIEdgeInsetsMake(0, 30, 10, -30)
    
    let thumbnailWidthRatio:CGFloat = 0.71 // The ratio of the screen width to the image width
    let thumbnailHeightRatio:CGFloat = 0.55 // The ratio of the height of the image to the width
    let thumbnailSize:CGSize
    let thumbnailMargin:CGFloat = 25
    
    let stopsScrollViewSideMargin:CGFloat
    
    // Views
    let focusedStopLabel = UILabel()
    
    var overviewView:ToursSectionStopView? = nil
    var stopViews:[Int : ToursSectionStopView] = [:]
    
    let stopsScrollView = UIScrollView()
    let stopsScrollViewContentView = UIView()
    
    private var focusedItem:Int = -1
    
    override init() {
        let thumbWidth = UIScreen.main.bounds.width * thumbnailWidthRatio
        let thumbHeight = thumbWidth * thumbnailHeightRatio
        thumbnailSize = CGSize(width: thumbWidth,height: thumbHeight)
        
        stopsScrollViewSideMargin = (UIScreen.main.bounds.width - thumbWidth) / 2.0
        
        super.init()
        
        titleLabel.numberOfLines = 1
        
        backgroundColor = UIColor.white
        
        focusedStopLabel.numberOfLines = 1
        focusedStopLabel.font = UIFont.aicTextFont()
        focusedStopLabel.textColor = UIColor.black
        
        // Add Subviews
        stopsScrollView.addSubview(stopsScrollViewContentView)
        
        titleContentView.addSubview(focusedStopLabel)
        addSubview(stopsScrollView)
        
        stopsScrollView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTour(forTourModel tour:AICTourModel) {
        self.tourModel = tour
        self.overviewView = nil
        self.stopViews = [:]
        
        // Clear out the scroller's existing views
        for view in stopsScrollViewContentView.subviews {
            view.removeFromSuperview()
        }
        
        // Add the overview as the first item in the scroller
        overviewView = ToursSectionStopView(size: thumbnailSize, imageUrl: tour.overview.imageUrl, cropRect: nil)
        overviewView!.delegate = self
        
        stopsScrollViewContentView.addSubview(overviewView!)
        
        // Add the stops as the remaining items
        for (i, stop) in tour.stops.enumerated() {
            let stopView = ToursSectionStopView(size:thumbnailSize, imageUrl: stop.object.imageUrl, cropRect: stop.object.imageCropRect)
            stopView.tag = i
            stopView.delegate = self
            self.stopViews[stop.object.nid] = stopView
            
            stopsScrollViewContentView.addSubview(stopView)
        }
        
        // Reset the scroller
        stopsScrollView.contentOffset.x = 0
        focusedItem = -1
        updateFocusedItem(atIndex: 0)
        
        setNeedsUpdateConstraints()
    }
    
    // Programatically jump to a stop
    func setFocusedStop(forObjectModel stopObject:AICObjectModel) {
        let stopView = stopViews.filter { $0.0 == stopObject.nid }.first
        if let stopForObject = stopView {
            if let stop = stopsScrollViewContentView.subviews.index(of: stopForObject.1) {
                scrollTo(thumbIndex: stop)
                updateFocusedItem(atIndex: stop, andNotifyDelegate: false)
            }
        }
    }
    
    override func updateConstraints() {
        focusedStopLabel.snp.remakeConstraints({ (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            
            make.left.right.equalTo(focusedStopLabel.superview!).inset(focusedStopLabelMargins).priority(Common.Layout.Priority.high.rawValue)
            make.bottom.equalTo(focusedStopLabel.superview!).priority(Common.Layout.Priority.high.rawValue)
            
            focusedStopLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: UILayoutConstraintAxis.horizontal)
        })
        
        stopsScrollView.snp.remakeConstraints { (make) in
            make.top.equalTo(titleContentView.snp.bottom).offset(stopsMargins.top).priority(Common.Layout.Priority.high.rawValue)
            make.left.right.equalTo(stopsScrollView.superview!).priority(Common.Layout.Priority.high.rawValue)
            make.bottom.equalTo(stopsScrollView.superview!).priority(Common.Layout.Priority.high.rawValue)
        }
        
        stopsScrollViewContentView.snp.remakeConstraints({ (make) in
            make.top.equalTo(stopsScrollViewContentView.superview!)
            make.left.right.bottom.equalTo(stopsScrollViewContentView.superview!)
            if stopsScrollViewContentView.subviews.count != 0 {
                make.right.equalTo(stopsScrollViewContentView.subviews.last!).offset(stopsScrollViewSideMargin)
            }
            make.height.equalTo(stopsScrollViewContentView.superview!)
        })
        
        for (i,stop) in stopsScrollViewContentView.subviews.enumerated() {
            stop.snp.remakeConstraints({ (make) in
                make.top.equalTo(stop.superview!)
                make.bottom.equalTo(stop.superview!).inset(stopsMargins.bottom)
                
                if stop == stopsScrollViewContentView.subviews.first {
                    make.left.equalTo(stop.superview!).offset(stopsScrollViewSideMargin)
                } else {
                    make.left.equalTo(stopsScrollViewContentView.subviews[i-1].snp.right).offset(thumbnailMargin)
                }
            })
        }
        
        super.updateConstraints()
    }
    
    fileprivate func getFocusedItemIndex(forScrollerOffset xOffset:CGFloat) -> Int {
        let thumbWidth = thumbnailSize.width + thumbnailMargin
        var thumbIndex = floor((xOffset + stopsScrollViewSideMargin) / thumbWidth)
        
        if ((xOffset - (floor((xOffset + stopsScrollViewSideMargin) / thumbWidth) * thumbWidth)) > thumbWidth) {
            thumbIndex = thumbIndex + 1;
        }
        
        thumbIndex = clamp(val: thumbIndex, minVal: 0, maxVal: CGFloat(stopsScrollViewContentView.subviews.count-1))
        
        return Int(thumbIndex)
    }
    
    /**
     Update selected stop label and notify delegate
    */
    fileprivate func updateFocusedItem(atIndex itemIndex:Int, andNotifyDelegate:Bool = true) {
        if self.focusedItem == itemIndex {
            return
        }
        
        self.focusedItem = itemIndex
        
        if focusedItem <= 0 {
            focusedStopLabel.text = tourModel!.overview.title
        } else {
            focusedStopLabel.text = tourModel!.stops[focusedItem-1].audio.title
        }
        
        if andNotifyDelegate {
            if focusedItem == 0 {
                delegate?.toursSectionDidFocusOnTourOverview(tour: tourModel!)
            } else {
                delegate?.toursSectionDidFocusOnTourStop(tour: tourModel!, stopIndex: focusedItem - 1)
            }
        }
    }
    
    fileprivate func scrollTo(thumbIndex index:Int) {
        var offset = stopsScrollView.contentOffset
        offset.x = getCenteredScrollXOffset(forThumbIndex: index)
        stopsScrollView.setContentOffset(offset, animated: true)
    }
    
    /**
     Calculate the x scroll offset that shows a specific stop centered
    */
    fileprivate func getCenteredScrollXOffset(forThumbIndex index:Int) -> CGFloat {
        let thumbWidth = thumbnailSize.width + thumbnailMargin
        let thumbIndex = CGFloat(index)
        return (thumbIndex * thumbWidth) + stopsScrollViewSideMargin - (UIScreen.main.bounds.width/2 - thumbnailSize.width/2.0)
    }
}

extension ToursSectionStopsScrollerView : ToursSectionStopViewDelegate {
    func stopViewWasSelected(stopView: ToursSectionStopView) {
        let focusedItemIndex = getFocusedItemIndex(forScrollerOffset: stopsScrollView.contentOffset.x)
        if stopsScrollViewContentView.subviews[focusedItemIndex] != stopView {
            let index = stopsScrollViewContentView.subviews.index(of: stopView)
            if let index = index {
                scrollTo(thumbIndex: index)
                updateFocusedItem(atIndex: index)
            }
        }
        
        else {
            if stopView == overviewView {
                delegate?.toursSectionDidSelectTourOverview(tour: tourModel!)
            } else {
                delegate?.toursSectionDidSelectTourStop(tour: tourModel!, stopIndex: stopView.tag)
            }
        }

    }
}

extension ToursSectionStopsScrollerView : UIScrollViewDelegate {
    /**
     Snapping UIScrollView code adapted from: http://stackoverflow.com/questions/20940890/add-snap-to-position-in-a-uitableview-or-uiscrollview
    */
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let thumbIndex = CGFloat(getFocusedItemIndex(forScrollerOffset: targetContentOffset.pointee.x))
        targetContentOffset.pointee.x = getCenteredScrollXOffset(forThumbIndex: Int(thumbIndex))
        //updateFocusedItem(Int(thumbIndex))
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        updateFocusedItem(getFocusedItemIndexForScrollerOffset(scrollView.contentOffset.x))
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let focusedIndex = getFocusedItemIndex(forScrollerOffset: scrollView.contentOffset.x)
        updateFocusedItem(atIndex: focusedIndex)
    }
    
}
