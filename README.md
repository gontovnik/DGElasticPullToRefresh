# DGElasticPullToRefresh
Elastic pull to refresh compontent developed in Swift

Inspired by this Dribbble post: [Pull Down to Refresh](https://dribbble.com/shots/2232385-Pull-Down-to-Refresh) by [Hoang Nguyen](https://dribbble.com/Hoanguyen)

Tutorial on how this bounce effect was achieved can be found [here](http://iostuts.io/2015/10/17/elastic-bounce-using-uibezierpath-and-pan-gesture/).

![](https://raw.githubusercontent.com/gontovnik/DGElasticPullToRefresh/master/DGElasticPullToRefreshPreview1.gif)
![](https://raw.githubusercontent.com/gontovnik/DGElasticPullToRefresh/master/DGElasticPullToRefreshPreview2.gif)

## Requirements
* Xcode 7 or higher
* iOS 8.0 or higher (may work on previous versions, just did not test it)
* ARC
* Swift 2.0

## Demo

Open and run the DGElasticPullToRefreshExample project in Xcode to see DGElasticPullToRefresh in action.

## Installation

### Cocoapods

``` ruby
pod "DGElasticPullToRefresh"
```

### Manual

Add DGElasticPullToRefresh folder into your project.

## Example usage

``` swift
// Initialize tableView
let loadingView = DGElasticPullToRefreshLoadingViewCircle()
loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
    // Add your logic here
    // Do not forget to call dg_stopLoading() at the end 
    self?.tableView.dg_stopLoading()
}, loadingView: loadingView)
tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
```

### Description

Add pull to refresh without loading view:

``` swift
func dg_addPullToRefreshWithActionHandler(actionHandler: () -> Void)
```

Add pull to refresh with loading view:

``` swift
func dg_addPullToRefreshWithActionHandler(actionHandler: () -> Void, loadingView: DGElasticPullToRefreshLoadingView?)
```

You can use built-in *DGElasticPullToRefreshLoadingViewCircle* or create your own by subclassing **DGElasticPullToRefreshLoadingView** and implementing these methods:

``` swift
func setPullProgress(progress: CGFloat) { }
func startAnimating() { }
func stopLoading() { }
```

Remove pull to refresh:

``` swift
func dg_removePullToRefresh()
```

Change pull to refresh background color:

``` swift
func dg_setPullToRefreshBackgroundColor(color: UIColor)
```

Change pull to refresh fill color:

``` swift 
func dg_setPullToRefreshFillColor(color: UIColor)
```

## Contribution

Please feel free to submit pull requests. Cannot wait to see your custom loading views for this pull to refresh.

## Contact

Danil Gontovnik

- https://github.com/gontovnik
- https://twitter.com/gontovnik
- http://gontovnik.com/
- danil@gontovnik.com
- http://iostuts.io/author/danil-gontovnik/

## License

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
