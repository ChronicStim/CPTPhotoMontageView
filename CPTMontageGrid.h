//
//  CPTMontageGrid.h
//  CPTPhotoMontageView
//
//  Created by Bob Kutschke on 5/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CPTMontagePosition;
@interface CPTMontageGrid : NSObject

@property (nonatomic, assign, readonly) NSUInteger numberOfItems;
@property (nonatomic, assign, readonly) NSInteger rowCount;
@property (nonatomic, assign, readonly) NSInteger defaultCellsPerRowCount;
@property (nonatomic, strong, readonly) NSDictionary *montagePositions;
@property (nonatomic, assign, readonly) UICollectionViewScrollDirection scrollDirection;

-(instancetype)initMontageGridWithNumberOfItems:(NSUInteger)numberOfItems scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

/// Number of cells in the row given by the rowIndex
/// @param rowIndex Zero-indexed reference to the row.
-(NSUInteger)cellCountForRowIndex:(NSUInteger)rowIndex;

/// Returns a montage position object with row & cell index references for the given itemIndex
/// @param itemIndex A zero-indexed reference for the item within the itemArray
-(CPTMontagePosition *)montagePositionForItemIndex:(NSUInteger)itemIndex;

-(NSUInteger)itemIndexForRow:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

-(void)clearExistingPositionCellFrames;
-(void)changeScrollDirection:(UICollectionViewScrollDirection)scrollDirection;

@end

NS_ASSUME_NONNULL_END
