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
import ObjectiveC

// MARK: -
// MARK: (NSObject) Extension

public extension NSObject {
    
    // MARK: -
    // MARK: Vars
    
    private struct dg_associatedKeys {
        static var observersArray = "observers"
    }
    
    private var dg_observers: [[String : NSObject]] {
        get {
            if let observers = objc_getAssociatedObject(self, &dg_associatedKeys.observersArray) as? [[String : NSObject]] {
                return observers
            } else {
                let observers = [[String : NSObject]]()
                self.dg_observers = observers
                return observers
            }
        } set {
            objc_setAssociatedObject(self, &dg_associatedKeys.observersArray, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: -
    // MARK: Methods
    
    public func dg_addObserver(observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath : observer]
        
        if dg_observers.indexOf({ $0 == observerInfo }) == nil {
            dg_observers.append(observerInfo)
            addObserver(observer, forKeyPath: keyPath, options: .New, context: nil)
        }
    }
    
    public func dg_removeObserver(observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath : observer]
        
        if let index = dg_observers.indexOf({ $0 == observerInfo}) {
            dg_observers.removeAtIndex(index)
            removeObserver(observer, forKeyPath: keyPath)
        }
    }
    
}

// MARK: -
// MARK: (UIScrollView) Extension

public extension UIScrollView {
    
    // MARK: -
    // MARK: Vars
    
    private struct dg_associatedKeys {
        static var pullToRefreshView = "pullToRefreshView"
    }
    
    private var _pullToRefreshView: DGElasticPullToRefreshView? {
        get {
            if let pullToRefreshView = objc_getAssociatedObject(self, &dg_associatedKeys.pullToRefreshView) as? DGElasticPullToRefreshView {
                return pullToRefreshView
            }
            
            return nil
        }
        set {
            objc_setAssociatedObject(self, &dg_associatedKeys.pullToRefreshView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var pullToRefreshView: DGElasticPullToRefreshView! {
        get {
            if let pullToRefreshView = _pullToRefreshView {
                return pullToRefreshView
            } else {
                let pullToRefreshView = DGElasticPullToRefreshView()
                _pullToRefreshView = pullToRefreshView
                return pullToRefreshView
            }
        }
    }
    
    // MARK: -
    // MARK: Methods (Public)
    
    public func dg_addPullToRefreshWithActionHandler(actionHandler: () -> Void) {
        dg_addPullToRefreshWithActionHandler(actionHandler, loadingView: nil)
    }
    
    public func dg_addPullToRefreshWithActionHandler(actionHandler: () -> Void, loadingView: DGElasticPullToRefreshLoadingView?) {
        multipleTouchEnabled = false
        panGestureRecognizer.maximumNumberOfTouches = 1
        
        pullToRefreshView.actionHandler = actionHandler
        pullToRefreshView.loadingView = loadingView
        addSubview(pullToRefreshView)
        
        pullToRefreshView.observing = true
    }
    
    public func dg_removePullToRefresh() {
        pullToRefreshView.observing = false
        pullToRefreshView.removeFromSuperview()
    }
    
    public func dg_setPullToRefreshBackgroundColor(color: UIColor) {
        pullToRefreshView.backgroundColor = color
    }
    
    public func dg_setPullToRefreshFillColor(color: UIColor) {
        pullToRefreshView.fillColor = color
    }
    
    public func dg_stopLoading() {
        pullToRefreshView.stopLoading()
    }
    
    func dg_stopScrollingAnimation() {
        if let superview = self.superview, let index = superview.subviews.indexOf({ $0 == self }) as Int! {
            removeFromSuperview()
            superview.insertSubview(self, atIndex: index)
        }
    }
    
}

// MARK: -
// MARK: (UIView) Extension

public extension UIView {
    func dg_center(usePresentationLayerIfPossible: Bool) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = layer.presentationLayer() as? CALayer {
            // Position can be used as a center, because anchorPoint is (0.5, 0.5)
            return presentationLayer.position
        }
        return center
    }
}

// MARK: -
// MARK: (UIPanGestureRecognizer) Extension

public extension UIPanGestureRecognizer {
    func dg_resign() {
        enabled = false
        enabled = true
    }
}

// MARK: -
// MARK: (UIGestureRecognizerState) Extension

public extension UIGestureRecognizerState {
    func dg_isAnyOf(values: [UIGestureRecognizerState]) -> Bool {
        return values.contains({ $0 == self })
    }
}
