//
//  CPTMontageFlowLayout.m
//  CPTMontageFlowLayout
//
//  Created by support@chronicstimulation.com on 05/03/2020.
//  Copyright (c) 2020 support@chronicstimulation.com. All rights reserved.
//

#import "CPTMontageFlowLayout.h"
#import "CPTLinearPartition.h"

@interface CPTMontageFlowLayout ()
{
    CGRect **_itemFrameSections;
    NSInteger _numberOfItemFrameSections;
    
    
    NSMutableArray *_deleteIndexPaths, *_insertIndexPaths;
    CGFloat centerXOffset;
}

@property (nonatomic) CGSize contentSize;

@property (nonatomic, strong) NSArray *headerFrames;
@property (nonatomic, strong) NSArray *footerFrames;

@end

@implementation CPTMontageFlowLayout
@synthesize singleSectionWithConstrainedContentSize = _singleSectionWithConstrainedContentSize;

#pragma mark - Lifecycle

- (void)clearItemFrames
{
    // free all item frame arrays
    if (NULL != _itemFrameSections) {
        for (NSInteger i = 0; i < _numberOfItemFrameSections; i++) {
            CGRect *frames = _itemFrameSections[i];
            free(frames);
        }
        
        free(_itemFrameSections);
        _itemFrameSections = NULL;
    }
}

- (void)dealloc
{
    [self clearItemFrames];
}

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
    // set to NULL so it is not released by accident in dealloc
    _itemFrameSections = NULL;
    
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
    
    CGFloat idealHeight = self.preferredRowSize;
    if (idealHeight == 0) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            idealHeight = CGRectGetHeight(self.collectionView.bounds) / 3.0;
        }
        else {
            idealHeight = CGRectGetWidth(self.collectionView.bounds) / 3.0;
        }
    }
    
    NSMutableArray *headerFrames = [NSMutableArray array];
    NSMutableArray *footerFrames = [NSMutableArray array];
    
    CGSize contentSize = CGSizeZero;
    
    // first release old item frame sections
    [self clearItemFrames];
    
    // create new item frame sections
    _numberOfItemFrameSections = [self.collectionView numberOfSections];
    _itemFrameSections = (CGRect **)malloc(sizeof(CGRect *) * _numberOfItemFrameSections);
    
    for (int section = 0; section < _numberOfItemFrameSections; section++) {
        // add new item frames array to sections array
        NSInteger numberOfItemsInSections = [self.collectionView numberOfItemsInSection:section];
        CGRect *itemFrames = (CGRect *)malloc(sizeof(CGRect) * numberOfItemsInSections);
        _itemFrameSections[section] = itemFrames;
        
        CGSize headerSize = [self referenceSizeForHeaderInSection:section];
        CGSize sectionSize = CGSizeZero;
        
        CGRect headerFrame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            headerFrame = CGRectMake(0, contentSize.height, CGRectGetWidth(self.collectionView.bounds), headerSize.height);
        } else {
            headerFrame = CGRectMake(contentSize.width, 0, headerSize.width, CGRectGetHeight(self.collectionView.bounds));
        }
        [headerFrames addObject:[NSValue valueWithCGRect:headerFrame]];
        
        CGFloat totalItemSize = [self totalItemSizeForSection:section preferredRowSize:idealHeight];
        NSInteger numberOfRows = MAX(roundf(totalItemSize / [self viewPortAvailableSize]), 1);
        
        CGPoint sectionOffset;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            sectionOffset = CGPointMake(0, contentSize.height + headerSize.height);
        } else {
            sectionOffset = CGPointMake(contentSize.width + headerSize.width, 0);
        }
        
        [self setFrames:itemFrames forItemsInSection:section numberOfRows:numberOfRows sectionOffset:sectionOffset sectionSize:&sectionSize];
        
        CGSize footerSize = [self referenceSizeForFooterInSection:section];
        CGRect footerFrame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            footerFrame = CGRectMake(0, contentSize.height + headerSize.height + sectionSize.height, CGRectGetWidth(self.collectionView.bounds), footerSize.height);
        } else {
            footerFrame = CGRectMake(contentSize.width + headerSize.width + sectionSize.width, 0, footerSize.width, CGRectGetHeight(self.collectionView.bounds));
        }
        [footerFrames addObject:[NSValue valueWithCGRect:footerFrame]];
        
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            contentSize = CGSizeMake(sectionSize.width, contentSize.height + headerSize.height + sectionSize.height + footerSize.height);
        }
        else {
            contentSize = CGSizeMake(contentSize.width + headerSize.width + sectionSize.width + footerSize.width, sectionSize.height);
        }
    }
    
    self.headerFrames = [headerFrames copy];
    self.footerFrames = [footerFrames copy];
    
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
            CGRect itemFrame = _itemFrameSections[section][i];
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
    return _itemFrameSections[indexPath.section][indexPath.item];
}

- (CGRect)footerFrameForSection:(NSInteger)section
{
    return [[self.footerFrames objectAtIndex:section] CGRectValue];
}

- (CGFloat)totalItemSizeForSection:(NSInteger)section preferredRowSize:(CGFloat)preferredRowSize
{
    CGFloat totalItemSize = 0;
    NSUInteger n = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
    
    for (NSInteger i = 0; i < n; i++) {
        CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section]];
        
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            totalItemSize += (preferredSize.width / preferredSize.height) * preferredRowSize;
        }
        else {
            totalItemSize += (preferredSize.height / preferredSize.width) * preferredRowSize;
        }
    }
    
    return totalItemSize;
}

- (NSArray *)weightsForItemsInSection:(NSInteger)section
{
    NSMutableArray *weights = [NSMutableArray array];
    for (NSInteger i = 0, n = [self.collectionView numberOfItemsInSection:section]; i < n; i++) {
        CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section]];
        NSInteger aspectRatio = self.scrollDirection == UICollectionViewScrollDirectionVertical ? roundf((preferredSize.width / preferredSize.height) * 100) : roundf((preferredSize.height / preferredSize.width) * 100);
        [weights addObject:@(aspectRatio)];
    }
    
    return [weights copy];
}

- (void)setFrames:(CGRect *)frames forItemsInSection:(NSInteger)section numberOfRows:(NSUInteger)numberOfRows sectionOffset:(CGPoint)sectionOffset sectionSize:(CGSize *)sectionSize
{
    NSArray *weights = [self weightsForItemsInSection:section];
    
    if (weights.count == 0) {
        *sectionSize = CGSizeZero;
        return;
    }
    
    NSMutableArray *partition = [CPTLinearPartition linearPartitionForSequence:weights numberOfPartitions:numberOfRows];
    
    // workaround to remove single images in a row
    for (NSInteger i = 0; i < partition.count; i++) {
        NSArray *row = partition[i];
        if (row.count == 1) {
            NSArray *prev = i > 0 ? partition[i-1] : nil;
            NSArray *next = i < partition.count-1 ? partition[i+1] : nil;
            if (prev || next) {
                // stick the image in the row with less images in it
                if (next == nil || (prev != nil && prev.count < next.count)) {
                    partition[i-1] = [prev arrayByAddingObject:row[0]];
                } else {
                    NSMutableArray *arr = [next mutableCopy];
                    [arr insertObject:row[0] atIndex:0];
                    partition[i+1] = arr;
                }
                [partition removeObjectAtIndex:i];
                i--;
            }
        }
    }
    
    int i = 0;
    CGPoint offset = CGPointMake(sectionOffset.x + self.sectionInset.left, sectionOffset.y + self.sectionInset.top);
    CGFloat previousItemSize = 0;
    CGFloat contentMaxValueInScrollDirection = 0;
    for (NSArray *row in partition) {
        
        CGFloat summedRatios = 0;
        for (NSInteger j = i, n = i + [row count]; j < n; j++) {
            CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:section]];
            
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                summedRatios += preferredSize.width / preferredSize.height;
            }
            else {
                summedRatios += preferredSize.height / preferredSize.width;
            }
        }
        
        CGFloat rowSize = [self viewPortAvailableSize] - (([row count] - 1) * self.minimumInteritemSpacing);
        for (NSInteger j = i, n = i + [row count]; j < n; j++) {
            CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:section]];
            
            CGSize actualSize = CGSizeZero;
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                actualSize = CGSizeMake(roundf(rowSize / summedRatios * (preferredSize.width / preferredSize.height)), roundf(rowSize / summedRatios));
            }
            else {
                actualSize = CGSizeMake(roundf(rowSize / summedRatios), roundf(rowSize / summedRatios * (preferredSize.height / preferredSize.width)));
            }
            
            CGRect frame = CGRectMake(offset.x, offset.y, actualSize.width, actualSize.height);
            // copy frame into frames ptr and increment ptr
            *frames++ = frame;
            
            
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                offset.x += actualSize.width + self.minimumInteritemSpacing;
                previousItemSize = actualSize.height;
                contentMaxValueInScrollDirection = CGRectGetMaxY(frame);
            }
            else {
                offset.y += actualSize.height + self.minimumInteritemSpacing;
                previousItemSize = actualSize.width;
                contentMaxValueInScrollDirection = CGRectGetMaxX(frame);
            }
        }
        
        /**
         * Check if row actually contains any items before changing offset,
         * because linear partitioning algorithm might return a row with no items.
         */
        if ([row count] > 0) {
            // move offset to next line
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                offset = CGPointMake(self.sectionInset.left, offset.y + previousItemSize + self.minimumLineSpacing);
            }
            else {
                offset = CGPointMake(offset.x + previousItemSize + self.minimumLineSpacing, self.sectionInset.top);
            }
        }
        
        i += [row count];
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        *sectionSize = CGSizeMake([self viewPortWidth], (contentMaxValueInScrollDirection - sectionOffset.y) + self.sectionInset.bottom);
    }
    else {
        *sectionSize = CGSizeMake((contentMaxValueInScrollDirection - sectionOffset.x) + self.sectionInset.right, [self viewPortHeight]);
    }
}

- (CGFloat)viewPortWidth
{
    return CGRectGetWidth(self.collectionView.frame) - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
}

- (CGFloat)viewPortHeight
{
    return (CGRectGetHeight(self.collectionView.frame) - self.collectionView.contentInset.top  - self.collectionView.contentInset.bottom);
}

- (CGFloat)viewPortAvailableSize
{
    CGFloat availableSize = 0;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        availableSize = [self viewPortWidth] - self.sectionInset.left - self.sectionInset.right;
    }
    else {
        availableSize = [self viewPortHeight] - self.sectionInset.top - self.sectionInset.bottom;
    }
    
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

-(void)setSingleSectionWithConstrainedContentSize:(BOOL)singleSectionWithConstrainedContentSize;
{
    _singleSectionWithConstrainedContentSize = singleSectionWithConstrainedContentSize;
    
    [self invalidateLayout];
}

-(void)setMaximumAllowedContentSize:(CGSize)maximumAllowedContentSize;
{
    _maximumAllowedContentSize = maximumAllowedContentSize;
    
    [self invalidateLayout];
}

#pragma mark - Layout ContentSize Constraint Option

// Indicates whether or not the layout will force its contentSize to fit within the provided maximumAllowedContentSize. Both the flag and maximumAllowedContentSize must be set before this option will function.
-(BOOL)isSingleSectionWithConstrainedContentSize;
{
    return (_singleSectionWithConstrainedContentSize && !CGSizeEqualToSize(CGSizeZero, _maximumAllowedContentSize));
}

#pragma mark - Delegate

- (id<CPTMontageFlowLayoutDelegate>)delegate
{
    return (id<CPTMontageFlowLayoutDelegate>)self.collectionView.delegate;
}

#pragma mark - Delegate helpers

- (CGSize)referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.isSingleSectionWithConstrainedContentSize) {
        return CGSizeZero;
    }
    
    BOOL respondsToSelector = [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)];
    if (respondsToSelector) {
        return [(id <CPTMontageFlowLayoutDelegate>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
    }
    return self.headerReferenceSize;
}

- (CGSize)referenceSizeForFooterInSection:(NSInteger)section
{
    if (self.isSingleSectionWithConstrainedContentSize) {
        return CGSizeZero;
    }
    
    BOOL respondsToSelector = [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)];
    if (respondsToSelector) {
        return [(id <CPTMontageFlowLayoutDelegate>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
    }
    return self.footerReferenceSize;
}


@end
