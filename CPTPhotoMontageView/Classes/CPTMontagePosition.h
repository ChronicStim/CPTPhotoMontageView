//
//  CPTMontagePosition.h
//  CPTPhotoMontageView
//
//  Created by Bob Kutschke on 5/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CPTMontageGrid;
@interface CPTMontagePosition : NSObject

/// Weak reference to the montageGrid that is managing this position
@property (nonatomic, weak) CPTMontageGrid *montageGrid;

/// Zero based index of the item within the itemArray
@property (nonatomic, assign) NSUInteger itemIndex;

/// Row index value. Zero indexed.
@property (nonatomic, assign) NSUInteger row;

/// Cell index value for the given row. Zero indexed.
@property (nonatomic, assign) NSUInteger cellInRow;

/// The frame definition for the given item in the layout
@property (nonatomic, assign) CGRect cellFrame;

/// Returns an initialized montage position object with a row & cell index identified.
/// @param row Zero-indexed row index
/// @param cellInRow Zero-indexed cell index within the row
/// @param montageGrid Reference to the montageGrid managing the position
-(instancetype)initMontagePositionWithRow:(NSUInteger)row cellInRow:(NSUInteger)cellInRow forMontageGrid:(CPTMontageGrid *)montageGrid;;

/// Returns an initialized montage position object with an itemIndex identified.
/// @param itemIndex Zero-indexed item index
/// @param montageGrid Reference to the montageGrid managing the position
-(instancetype)initMontagePositionWithItemIndex:(NSUInteger)itemIndex forMontageGrid:(CPTMontageGrid *)montageGrid;

@end

NS_ASSUME_NONNULL_END
