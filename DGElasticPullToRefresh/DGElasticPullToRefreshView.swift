/*

The MIT License (MIT)

Copyright (c) 2015 Danil Gontovnik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit

// MARK: -
// MARK: DGElasticPullToRefreshState

public
enum DGElasticPullToRefreshState: Int {
    case Stopped
    case Dragging
    case AnimatingBounce
    case Loading
    case AnimatingToStopped
    
    func isAnyOf(values: [DGElasticPullToRefreshState]) -> Bool {
        return values.contains({ $0 == self })
    }
}

// MARK: -
// MARK: DGElasticPullToRefreshView

public class DGElasticPullToRefreshView: UIView {
    
    // MARK: -
    // MARK: Vars
    
    private var _state: DGElasticPullToRefreshState = .Stopped
    private(set) var state: DGElasticPullToRefreshState {
        get { return _state }
        set {
            let previousValue = state
            _state = newValue
            
            if previousValue == .Dragging && newValue == .AnimatingBounce {
                loadingView?.startAnimating()
                animateBounce()
            } else if newValue == .Loading && actionHandler != nil {
                actionHandler()
            } else if newValue == .AnimatingToStopped {
                resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: true, completion: { [weak self] () -> () in self?.state = .Stopped })
            } else if newValue == .Stopped {
                loadingView?.stopLoading()
            }
        }
    }
    
    private var originalContentInsetTop: CGFloat = 0.0 { didSet { layoutSubviews() } }
    private let shapeLayer = CAShapeLayer()
    
    private var displayLink: CADisplayLink!
    
    var actionHandler: (() -> Void)!
    
    var loadingView: DGElasticPullToRefreshLoadingView? {
        willSet {
            loadingView?.removeFromSuperview()
            if let newValue = newValue {
                addSubview(newValue)
            }
        }
    }
    
    var observing: Bool = false {
        didSet {
            guard let scrollView = scrollView() else { return }
            if observing {
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.Frame)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.PanGestureRecognizerState)
            } else {
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.Frame)
                scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.PanGestureRecognizerState)
            }
        }
    }
    
    var fillColor: UIColor = .clearColor() { didSet { shapeLayer.fillColor = fillColor.CGColor } }
    
    // MARK: Views
    
    private let bounceAnimationHelperView = UIView()
    
    private let cControlPointView = UIView()
    private let l1ControlPointView = UIView()
    private let l2ControlPointView = UIView()
    private let l3ControlPointView = UIView()
    private let r1ControlPointView = UIView()
    private let r2ControlPointView = UIView()
    private let r3ControlPointView = UIView()
    
    // MARK: -
    // MARK: Constructors
    
    init() {
        super.init(frame: CGRect.zero)
        
        displayLink = CADisplayLink(target: self, selector: Selector("displayLinkTick"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.paused = true
        
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        shapeLayer.fillColor = UIColor.blackColor().CGColor
        shapeLayer.actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull()]
        layer.addSublayer(shapeLayer)
        
        addSubview(bounceAnimationHelperView)
        addSubview(cControlPointView)
        addSubview(l1ControlPointView)
        addSubview(l2ControlPointView)
        addSubview(l3ControlPointView)
        addSubview(r1ControlPointView)
        addSubview(r2ControlPointView)
        addSubview(r3ControlPointView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    deinit {
        observing = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: -
    // MARK: Observer
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == DGElasticPullToRefreshConstants.KeyPaths.ContentOffset {
            if let newContentOffsetY = change?[NSKeyValueChangeNewKey]?.CGPointValue.y, let scrollView = scrollView() {
                if state.isAnyOf([.Loading, .AnimatingToStopped]) && newContentOffsetY < -scrollView.contentInset.top {
                    scrollView.dg_stopScrollingAnimation()
                    scrollView.contentOffset.y = -scrollView.contentInset.top
                } else {
                    scrollViewDidChangeContentOffset(dragging: scrollView.dragging)
                }
                layoutSubviews()
            }
        } else if keyPath == DGElasticPullToRefreshConstants.KeyPaths.ContentInset {
            if let newContentInsetTop = change?[NSKeyValueChangeNewKey]?.UIEdgeInsetsValue().top {
                originalContentInsetTop = newContentInsetTop
            }
        } else if keyPath == DGElasticPullToRefreshConstants.KeyPaths.Frame {
            layoutSubviews()
        } else if keyPath == DGElasticPullToRefreshConstants.KeyPaths.PanGestureRecognizerState {
            if let gestureState = scrollView()?.panGestureRecognizer.state where gestureState.dg_isAnyOf([.Ended, .Cancelled, .Failed]) {
                scrollViewDidChangeContentOffset(dragging: false)
            }
        }
    }
    
    // MARK: -
    // MARK: Notifications
    
    func applicationWillEnterForeground() {
        if state == .Loading {
            layoutSubviews()
        }
    }
    
    // MARK: -
    // MARK: Methods (Public)
    
    private func scrollView() -> UIScrollView? {
        return superview as? UIScrollView
    }
    
    func stopLoading() {
        // Prevent stop close animation
        if state == .AnimatingToStopped {
            return
        }
        state = .AnimatingToStopped
    }
    
    // MARK: Methods (Private)
    
    private func isAnimating() -> Bool {
        return state.isAnyOf([.AnimatingBounce, .AnimatingToStopped])
    }
    
    private func actualContentOffsetY() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-scrollView.contentInset.top - scrollView.contentOffset.y, 0)
    }
    
    private func currentHeight() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-originalContentInsetTop - scrollView.contentOffset.y, 0)
    }
    
    private func currentWaveHeight() -> CGFloat {
        return min(bounds.height / 3.0 * 1.6, DGElasticPullToRefreshConstants.WaveMaxHeight)
    }
    
    private func currentPath() -> CGPath {
        let width: CGFloat = scrollView()?.bounds.width ?? 0.0
        
        let bezierPath = UIBezierPath()
        let animating = isAnimating()
        
        bezierPath.moveToPoint(CGPoint(x: 0.0, y: 0.0))
        bezierPath.addLineToPoint(CGPoint(x: 0.0, y: l3ControlPointView.dg_center(animating).y))
        bezierPath.addCurveToPoint(l1ControlPointView.dg_center(animating), controlPoint1: l3ControlPointView.dg_center(animating), controlPoint2: l2ControlPointView.dg_center(animating))
        bezierPath.addCurveToPoint(r1ControlPointView.dg_center(animating), controlPoint1: cControlPointView.dg_center(animating), controlPoint2: r1ControlPointView.dg_center(animating))
        bezierPath.addCurveToPoint(r3ControlPointView.dg_center(animating), controlPoint1: r1ControlPointView.dg_center(animating), controlPoint2: r2ControlPointView.dg_center(animating))
        bezierPath.addLineToPoint(CGPoint(x: width, y: 0.0))
        
        bezierPath.closePath()
        
        return bezierPath.CGPath
    }
    
    private func scrollViewDidChangeContentOffset(dragging dragging: Bool) {
        let offsetY = actualContentOffsetY()
        
        if state == .Stopped && dragging {
            state = .Dragging
        } else if state == .Dragging && dragging == false {
            if offsetY >= DGElasticPullToRefreshConstants.MinOffsetToPull {
                state = .AnimatingBounce
                scrollView()?.dg_stopScrollingAnimation()
            } else {
                state = .Stopped
            }
        } else if state.isAnyOf([.Dragging, .Stopped]) {
            let pullProgress: CGFloat = offsetY / DGElasticPullToRefreshConstants.MinOffsetToPull
            loadingView?.setPullProgress(pullProgress)
        }
    }
    
    private func resetScrollViewContentInset(shouldAddObserverWhenFinished shouldAddObserverWhenFinished: Bool, animated: Bool, completion: (() -> ())?) {
        guard let scrollView = scrollView() else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.top = originalContentInsetTop
        
        if state == .AnimatingBounce {
            contentInset.top += currentHeight()
        } else if state == .Loading {
            contentInset.top += DGElasticPullToRefreshConstants.LoadingContentInset
        }
        
        scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
        
        let animationBlock = { scrollView.contentInset = contentInset }
        let completionBlock = { () -> Void in
            if shouldAddObserverWhenFinished {
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
            }
            completion?()
        }
        
        if animated {
            startDisplayLink()
            UIView.animateWithDuration(0.4, animations: animationBlock, completion: { _ in
                self.stopDisplayLink()
                completionBlock()
            })
        } else {
            animationBlock()
            completionBlock()
        }
    }
    
    private func animateBounce() {
        guard let scrollView = scrollView() else { return }
        
        resetScrollViewContentInset(shouldAddObserverWhenFinished: false, animated: false, completion: nil)
        
        let centerY = DGElasticPullToRefreshConstants.LoadingContentInset
        let duration = 0.9
        
        scrollView.scrollEnabled = false
        startDisplayLink()
        scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
        scrollView.dg_removeObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentInset)
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.43, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            self.cControlPointView.center.y = centerY
            self.l1ControlPointView.center.y = centerY
            self.l2ControlPointView.center.y = centerY
            self.l3ControlPointView.center.y = centerY
            self.r1ControlPointView.center.y = centerY
            self.r2ControlPointView.center.y = centerY
            self.r3ControlPointView.center.y = centerY
            }, completion: { _ in
                self.stopDisplayLink()
                self.resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: false, completion: nil)
                scrollView.dg_addObserver(self, forKeyPath: DGElasticPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.scrollEnabled = true
                self.state = .Loading
        })
        
        bounceAnimationHelperView.center = CGPoint(x: 0.0, y: originalContentInsetTop + currentHeight())
        UIView.animateWithDuration(duration * 0.4, animations: { () -> Void in
            self.bounceAnimationHelperView.center = CGPoint(x: 0.0, y: self.originalContentInsetTop + DGElasticPullToRefreshConstants.LoadingContentInset)
            }, completion: nil)
    }
    
    // MARK: -
    // MARK: CADisplayLink
    
    private func startDisplayLink() {
        displayLink.paused = false
    }
    
    private func stopDisplayLink() {
        displayLink.paused = true
    }
    
    func displayLinkTick() {
        let width = bounds.width
        var height: CGFloat = 0.0
        
        if state == .AnimatingBounce {
            guard let scrollView = scrollView() else { return }
        
            scrollView.contentInset.top = bounceAnimationHelperView.dg_center(isAnimating()).y
            scrollView.contentOffset.y = -scrollView.contentInset.top
            
            height = scrollView.contentInset.top - originalContentInsetTop
            
            frame = CGRect(x: 0.0, y: -height - 1.0, width: width, height: height)
        } else if state == .AnimatingToStopped {
            height = actualContentOffsetY()
        }
    
        shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        shapeLayer.path = currentPath()
        
        layoutLoadingView()
    }
    
    // MARK: -
    // MARK: Layout
    
    private func layoutLoadingView() {
        let width = bounds.width
        let height: CGFloat = bounds.height
        
        let loadingViewSize: CGFloat = DGElasticPullToRefreshConstants.LoadingViewSize
        let minOriginY = (DGElasticPullToRefreshConstants.LoadingContentInset - loadingViewSize) / 2.0
        let originY: CGFloat = max(min((height - loadingViewSize) / 2.0, minOriginY), 0.0)
        
        loadingView?.frame = CGRect(x: (width - loadingViewSize) / 2.0, y: originY, width: loadingViewSize, height: loadingViewSize)
        loadingView?.maskLayer.frame = convertRect(shapeLayer.frame, toView: loadingView)
        loadingView?.maskLayer.path = shapeLayer.path
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let scrollView = scrollView() where state != .AnimatingBounce {
            let width = scrollView.bounds.width
            let height = currentHeight()
            
            frame = CGRect(x: 0.0, y: -height, width: width, height: height)
            
            if state.isAnyOf([.Loading, .AnimatingToStopped]) {
                cControlPointView.center = CGPoint(x: width / 2.0, y: height)
                l1ControlPointView.center = CGPoint(x: 0.0, y: height)
                l2ControlPointView.center = CGPoint(x: 0.0, y: height)
                l3ControlPointView.center = CGPoint(x: 0.0, y: height)
                r1ControlPointView.center = CGPoint(x: width, y: height)
                r2ControlPointView.center = CGPoint(x: width, y: height)
                r3ControlPointView.center = CGPoint(x: width, y: height)
            } else {
                let locationX = scrollView.panGestureRecognizer.locationInView(scrollView).x
                
                let waveHeight = currentWaveHeight()
                let baseHeight = bounds.height - waveHeight
                
                let minLeftX = min((locationX - width / 2.0) * 0.28, 0.0)
                let maxRightX = max(width + (locationX - width / 2.0) * 0.28, width)
                
                let leftPartWidth = locationX - minLeftX
                let rightPartWidth = maxRightX - locationX
                
                cControlPointView.center = CGPoint(x: locationX , y: baseHeight + waveHeight * 1.36)
                l1ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
                l2ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.44, y: baseHeight)
                l3ControlPointView.center = CGPoint(x: minLeftX, y: baseHeight)
                r1ControlPointView.center = CGPoint(x: maxRightX - rightPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
                r2ControlPointView.center = CGPoint(x: maxRightX - (rightPartWidth * 0.44), y: baseHeight)
                r3ControlPointView.center = CGPoint(x: maxRightX, y: baseHeight)
            }
            
            shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            shapeLayer.path = currentPath()
            
            layoutLoadingView()
        }
    }
    
}
