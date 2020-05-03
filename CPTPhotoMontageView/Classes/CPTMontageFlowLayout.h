//
//  CPTMontageFlowLayout.h
//  CPTMontageFlowLayout
//
//  Created by support@chronicstimulation.com on 05/03/2020.
//  Copyright (c) 2020 support@chronicstimulation.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * The CPTMontageFlowLayout class is designed to display items of different sizes and aspect ratios in a grid, without wasting any visual space.
 * It takes the preferred sizes for the displayed items and a preferred row height as input to determine the optimal layout.
 *
 * In order to use this layout, the delegate for the collection view must implement the required methods in the CPTMontageFlowLayoutDelegate protocol.
 * Currently this class does not support supplementary or decoration views.
 *
 */
@interface CPTMontageFlowLayout : UICollectionViewLayout

// The preferred size for each row measured in the scroll direction
@property (nonatomic) CGFloat preferredRowSize;

// The size of each section's header. This maybe dynamically adjusted
// per section via the protocol method referenceSizeForHeaderInSection.
@property (nonatomic) CGSize headerReferenceSize;

// The size of each section's header. This maybe dynamically adjusted
// per section via the protocol method referenceSizeForFooterInSection.
@property (nonatomic) CGSize footerReferenceSize;

// The margins used to lay out content in a section.
@property (nonatomic) UIEdgeInsets sectionInset;

// The minimum spacing to use between lines of items in the grid.
@property (nonatomic) CGFloat minimumLineSpacing;

// The minimum spacing to use between items in the same row.
@property (nonatomic) CGFloat minimumInteritemSpacing;

// The scroll direction of the grid.
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;

// Treat the layout as a single section layout with no headers/footers AND force the item sizes to fit within the visible display size of the collectionView (or another provided fixed content size)
@property (nonatomic, getter=isSingleSectionWithConstrainedContentSize) BOOL singleSectionWithConstrainedContentSize;

// When singleSectionWithConstrainedContentSize == YES, this target size must be provided. During the prepareLayout phase, items will be sized to come as close as possible to filling this defined size while maintaining image aspect ratios. The provided contentSize should include sectionInsets (if any).
@property (nonatomic) CGSize maximumAllowedContentSize;

@end


@protocol CPTMontageFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(CPTMontageFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
