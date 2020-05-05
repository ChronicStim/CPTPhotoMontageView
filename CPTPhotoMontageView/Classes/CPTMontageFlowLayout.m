//
//  CPTMontageFlowLayout.m
//  CPTMontageFlowLayout
//
//  Created by support@chronicstimulation.com on 05/03/2020.
//  Copyright (c) 2020 support@chronicstimulation.com. All rights reserved.
//

#import "CPTMontageFlowLayout.h"
#import "CPTMontageGrid.h"
#import "CPTMontagePosition.h"

@interface CPTMontageFlowLayout ()
{
    NSInteger _numberOfItemFrameSections;
    
    NSMutableArray *_deleteIndexPaths, *_insertIndexPaths;
    CGFloat centerXOffset;
}

@property (nonatomic) CGSize contentSize;

@property (nonatomic, strong) NSArray *headerFrames;
@property (nonatomic, strong) NSArray *footerFrames;
@property (nonatomic, strong) CPTMontageGrid *montageGrid;

@end

@implementation CPTMontageFlowLayout

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.minimumLineSpacing = 10;
    self.minimumInteritemSpacing = 10;
    self.headerReferenceSize = CGSizeZero;
    self.footerReferenceSize = CGSizeZero;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

#pragma mark - Layout

- (void)prepareLayout
{
    [super prepareLayout];
    
    NSAssert([self.delegate conformsToProtocol:@protocol(CPTMontageFlowLayoutDelegate)], @"UICollectionView delegate should conform to CPTMontageFlowLayout protocol");
    
    CGSize contentSize = CGSizeZero;
    
    // first release old item frame sections
    [self.montageGrid clearExistingPositionCellFrames];
    
    // create new item frame sections
    _numberOfItemFrameSections = [self.collectionView numberOfSections];
    
    for (int section = 0; section < _numberOfItemFrameSections; section++) {
        
        CGSize sectionSize = CGSizeZero;
        
        CGPoint sectionOffset;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            sectionOffset = CGPointMake(0, contentSize.height);
        } else {
            sectionOffset = CGPointMake(contentSize.width, 0);
        }
        
        [self setFramesInSection:section sectionOffset:sectionOffset sectionSize:&sectionSize];
        
        contentSize = CGSizeMake(sectionSize.width, contentSize.height + sectionSize.height);
    }

    self.contentSize = contentSize;
    CGSize size = self.collectionView.frame.size;
    centerXOffset = 2* size.width;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    _deleteIndexPaths = [NSMutableArray array];
    _insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems) {
        if (update.updateAction == UICollectionUpdateActionDelete) {
            [_deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        } else if (update.updateAction == UICollectionUpdateActionInsert) {
            [_insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    _deleteIndexPaths = nil;
    _insertIndexPaths = nil;
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

-(void)invalidateLayout;
{
    [super invalidateLayout];
    
    self.montageGrid = nil;
}

#pragma mark - Row/Column Calculations

-(CPTMontageGrid *)montageGrid;
{
    if (nil != _montageGrid) {
        return _montageGrid;
    }
    
    NSUInteger n = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    _montageGrid = [[CPTMontageGrid alloc] initMontageGridWithNumberOfItems:n];
    
    return _montageGrid;
}

-(void)setFramesInSection:(NSUInteger)section sectionOffset:(CGPoint)sectionOffset sectionSize:(CGSize *)sectionSize;
{
    CGPoint offset = CGPointMake(sectionOffset.x+self.sectionInset.left,sectionOffset.y+self.sectionInset.top);
    CGFloat contentMaxValueInScrollDirection = 0;

    CGFloat cellHeightForContent = ([self viewPortAvailableSize].height - ((self.montageGrid.rowCount - 1) * self.minimumLineSpacing)) / (float)self.montageGrid.rowCount;

    NSUInteger itemIndex = 0;
    for (int row = 0; row<self.montageGrid.rowCount; row++) {
        
        NSInteger cellCount = [self.montageGrid cellCountForRowIndex:row];
        CGFloat cellWidthForContent = ([self viewPortAvailableSize].width - ((cellCount - 1) * self.minimumInteritemSpacing)) / (float)cellCount;

        for (int cell = 0; cell < cellCount; cell++) {
            
            CGRect cellFrame = CGRectMake(offset.x, offset.y, cellWidthForContent, cellHeightForContent);
            CPTMontagePosition *montagePosition = [self.montageGrid montagePositionForItemIndex:itemIndex];
            montagePosition.cellFrame = cellFrame;
            //NSLog(@"Adding cellFrame %@ for itemIndex %li at rowIndex %li cellIndex %li",NSStringFromCGRect(cellFrame),(long)itemIndex,(long)row,(long)cell);
            itemIndex++;

            offset.x += cellWidthForContent + self.minimumInteritemSpacing;
            contentMaxValueInScrollDirection = CGRectGetMaxY(cellFrame);
        }
        
        offset = CGPointMake(sectionOffset.x+self.sectionInset.left,(offset.y + cellHeightForContent + self.minimumLineSpacing));
    }
    
    *sectionSize = CGSizeMake([self viewPortWidth], (contentMaxValueInScrollDirection - sectionOffset.y) + self.sectionInset.bottom);
}


#pragma mark -

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    NSInteger n = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < n; section++) {
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        
        UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                  atIndexPath:sectionIndexPath];
        
        CGSize size = headerAttributes.frame.size;
        if (size.height != 0 && size.width != 0 && CGRectIntersectsRect(headerAttributes.frame, rect)) {
            [layoutAttributes addObject:headerAttributes];
        }
        
        for (int i = 0; i < [self.collectionView numberOfItemsInSection:section]; i++) {
            CPTMontagePosition *montagePosition = [self.montageGrid montagePositionForItemIndex:i];
            CGRect itemFrame = montagePosition.cellFrame;
            if (CGRectIntersectsRect(rect, itemFrame)) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
                [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            }
        }
        
        UICollectionViewLayoutAttributes *footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                  atIndexPath:sectionIndexPath];
        size = footerAttributes.frame.size;
        if (size.width != 0 && size.height != 0 && CGRectIntersectsRect(footerAttributes.frame, rect)) {
            [layoutAttributes addObject:footerAttributes];
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [self itemFrameForIndexPath:indexPath];
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes.frame = [self headerFrameForSection:indexPath.section];
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        attributes.frame = [self footerFrameForSection:indexPath.section];
    }
    
    // If there is no header or footer, we need to return nil to prevent a crash from UICollectionView private methods.
    if(CGRectIsEmpty(attributes.frame)) {
        attributes = nil;
    }
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds) || CGRectGetHeight(newBounds) != CGRectGetHeight(oldBounds)) {
        return YES;
    }
    
    return NO;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([_insertIndexPaths containsObject:itemIndexPath]) {
        // only change attributes on inserted cells
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // Configure attributes ...
        attributes.alpha = 0.5;
        CGPoint center = attributes.center;
        attributes.center = CGPointMake(center.x+centerXOffset, center.y);
    }
    
    return attributes;
}

// Note: name of method changed
// Also this gets called for all visible cells (not just the deleted ones) and
// even gets called when inserting cells!
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // So far, calling super hasn't been strictly necessary here, but leaving it in
    // for good measure
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([_deleteIndexPaths containsObject:itemIndexPath])
    {
        // only change attributes on deleted cells
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // Configure attributes ...
        attributes.alpha = 0.5;
        CGPoint center = attributes.center;
        attributes.center = CGPointMake(center.x-centerXOffset, center.y);
        //attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    }
    
    return attributes;
}

#pragma mark - Layout helpers

- (CGRect)headerFrameForSection:(NSInteger)section
{
    return [[self.headerFrames objectAtIndex:section] CGRectValue];
}

- (CGRect)itemFrameForIndexPath:(NSIndexPath *)indexPath
{
    CPTMontagePosition *montagePosition = [self.montageGrid montagePositionForItemIndex:indexPath.item];
    return montagePosition.cellFrame;
}

- (CGRect)footerFrameForSection:(NSInteger)section
{
    return [[self.footerFrames objectAtIndex:section] CGRectValue];
}

- (CGFloat)viewPortWidth
{
    return CGRectGetWidth(self.collectionView.frame) - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
}

- (CGFloat)viewPortHeight
{
    return (CGRectGetHeight(self.collectionView.frame) - self.collectionView.contentInset.top  - self.collectionView.contentInset.bottom);
}

- (CGSize)viewPortAvailableSize
{
    CGSize availableSize = CGSizeZero;
    availableSize.width = [self viewPortWidth] - self.sectionInset.left - self.sectionInset.right;
    availableSize.height = [self viewPortHeight] - self.sectionInset.top - self.sectionInset.bottom;
    
    return availableSize;
}

#pragma mark - Custom setters

- (void)setPreferredRowSize:(CGFloat)preferredRowHeight
{
    _preferredRowSize = preferredRowHeight;
    
    [self invalidateLayout];
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset
{
    _sectionInset = sectionInset;
    
    [self invalidateLayout];
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    _minimumLineSpacing = minimumLineSpacing;
    
    [self invalidateLayout];
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    _minimumInteritemSpacing = minimumInteritemSpacing;
    
    [self invalidateLayout];
}

- (void)setHeaderReferenceSize:(CGSize)headerReferenceSize
{
    _headerReferenceSize = headerReferenceSize;
    
    [self invalidateLayout];
}

- (void)setFooterReferenceSize:(CGSize)footerReferenceSize
{
    _footerReferenceSize = footerReferenceSize;
    
    [self invalidateLayout];
}

#pragma mark - Delegate

- (id<CPTMontageFlowLayoutDelegate>)delegate
{
    return (id<CPTMontageFlowLayoutDelegate>)self.collectionView.delegate;
}

#pragma mark - Delegate helpers

- (CGSize)referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}


@end
