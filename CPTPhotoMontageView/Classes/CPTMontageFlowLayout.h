//
//  CPTMontageFlowLayout.h
//  CPTMontageFlowLayout
//
//  Created by support@chronicstimulation.com on 05/03/2020.
//  Copyright (c) 2020 support@chronicstimulation.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * The CPTMontageFlowLayout class is designed to display photos in a defined view bounds. Within the provided space, the layout will determine the appropriate cell size to maximize the space usage for the given number of photos.
 * Cells are arranged in rows & columns. Row height is consistent, but column width per row will vary depending on the number of cells to be displayed in the row.
 * The effect is a fully utilized collectionView bounds area whether you are displaying 1 or 100 photos.
 * The Layout currently supports a single section. Header & Footer views are not supported.
 *
 */
@interface CPTMontageFlowLayout : UICollectionViewLayout

// The margins used to lay out content in a section.
@property (nonatomic) UIEdgeInsets sectionInset;

// The minimum spacing to use between lines of items in the grid.
@property (nonatomic) CGFloat minimumLineSpacing;

// The minimum spacing to use between items in the same row.
@property (nonatomic) CGFloat minimumInteritemSpacing;

// The scroll direction of the grid.
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;

@end
