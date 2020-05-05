# CPTPhotoMontageView

The CPTPhotoMontageView is built around the CPTMontageFlowLayout class which is a [UICollectionViewLayout](http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UICollectionViewLayout_class/Reference/Reference.html#//apple_ref/occ/cl/UICollectionViewLayout) subclass. 

It is designed to display photos within the bounds of a [UICollectionView](http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UICollectionView_class/Reference/Reference.html). Within the provided space, the layout will determine the appropriate cell size to maximize the space usage for the given number of photos. 

Cells are arranged in rows & columns. Row height is consistent, but column width per row will vary depending on the number of cells to be displayed in the row. The effect is a fully utilized collectionView bounds area whether you are displaying 1 or 100 photos. 

##Limitations:
* The Layout currently supports a single section only. 
* Header & Footer views are not supported.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

You can experiment with a collectionView using from 1 to 24 photos arranged in either a Vertical or Horizontal orientation.

![Demo1](https://imgur.com/JcOe1Nj.jpg)
![Demo2](https://imgur.com/Q1UAa4L.jpg)
![Demo3](https://imgur.com/kJBRCBK.jpg)

## Requirements

* UICollectionView with layout set to CPTMontageFlowLayout.
* Set a sectionInset to define outer border width
* Set a minimumLineSpacing to define the border between rows
* Set a minimumInteritemSpacing to define the border between items
* Set scrollDirection to determine orientation of the rows/columns

## Installation

CPTPhotoMontageView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CPTPhotoMontageView'
```

## Author

support@chronicstimulation.com, support@chronicstimulation.com

## License

CPTPhotoMontageView is available under the MIT license. See the LICENSE file for more info.
