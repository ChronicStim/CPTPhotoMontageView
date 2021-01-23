//
//  CPTMontageGrid.m
//  CPTPhotoMontageView
//
//  Created by Bob Kutschke on 5/4/20.
//

#import "CPTMontageGrid.h"
#import "CPTMontagePosition.h"

@interface CPTMontageGrid ()

@property (nonatomic, assign, readwrite) NSUInteger numberOfItems;
@property (nonatomic, strong) NSArray *perRowCellCountArray;
@property (nonatomic, assign, readwrite) NSInteger rowCount;
@property (nonatomic, assign, readwrite) NSInteger defaultCellsPerRowCount;
@property (nonatomic, strong, readwrite) NSDictionary *montagePositions;
// The scroll direction of the grid.
@property (nonatomic, assign, readwrite) UICollectionViewScrollDirection scrollDirection;

@end

@implementation CPTMontageGrid
@synthesize numberOfItems = _numberOfItems;

-(instancetype)initMontageGridWithNumberOfItems:(NSUInteger)numberOfItems scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
{
    self = [super init];
    if (self) {
        self.numberOfItems = numberOfItems;
    }
    return self;
}

-(NSUInteger)numberOfItems;
{
    return _numberOfItems;
}

-(void)setNumberOfItems:(NSUInteger)numberOfItems;
{
    if (numberOfItems != _numberOfItems) {
        _numberOfItems = numberOfItems;
        [self generateMontageGridDetails];
    }
}

-(void)generateMontageGridDetails;
{
    // Reset grid values
    _rowCount = 0;
    _defaultCellsPerRowCount = 0;
    _perRowCellCountArray = nil;
    _montagePositions = nil;
    
    if (0 < self.numberOfItems) {
        
        _defaultCellsPerRowCount = (NSInteger)ceilf(sqrtf((float)self.numberOfItems));
        _rowCount = (NSInteger)ceilf((float)self.numberOfItems/(float)_defaultCellsPerRowCount);
        
        NSInteger totalNumberOfEmptyCellsForLayout = ((_rowCount * _defaultCellsPerRowCount) - self.numberOfItems);
        
        NSAssert(totalNumberOfEmptyCellsForLayout<_rowCount,@"Total row count %li must be greater than the number of empty cells (%li) in the layout.",(long)_rowCount,(long)totalNumberOfEmptyCellsForLayout);
        
        // To determine which rows have the empty cells, use the following rules
        // a) Start with last row first, then first row, then second to last, then second row, etc. until all empty cells have been distributed.
        // b) Divide totalNumberOfEmptyCells (n) by 2 and half will be applied to the first (n/2) rows and the other half to the last (n/2) rows. If there was a remainder when dividing, it will be applied to the last rows as well. E.g. 7 empty rows in a 10 row layout would have rows 1,2,3 with empty cells and rows 7,8,9,10 with empty cells. Rows 4,5,6 would be the full column count.
        NSUInteger itemIndex = 0;
        NSMutableArray *rowMArray = [NSMutableArray new];
        for (int row = 0; row < _rowCount; row++) {
            // For each row, determine number of cells in the row and store that number in the array at the same index as represented by the row in the montage.
            
            NSInteger numberOfCellsInRow = _defaultCellsPerRowCount;
            
            if (0 < totalNumberOfEmptyCellsForLayout) {
                NSInteger halfNumberOfEmptyCells = totalNumberOfEmptyCellsForLayout / 2;
                NSInteger remainder = totalNumberOfEmptyCellsForLayout % 2;
                
                NSInteger firstFullRow = halfNumberOfEmptyCells;
                NSInteger lastFullRow = (_rowCount - 1) - (halfNumberOfEmptyCells + remainder);
                
                if (firstFullRow <= row && lastFullRow >= row) {
                    // Row is a full row
                } else {
                    // Row contains empty cell
                    numberOfCellsInRow = _defaultCellsPerRowCount - 1;
                }
            }
            
            for (int cellIndex=0; cellIndex < numberOfCellsInRow; cellIndex++) {
                
                if (itemIndex < self.numberOfItems) {
                    CPTMontagePosition *montagePosition = [self.montagePositions objectForKey:@(itemIndex)];
                    montagePosition.row = row;
                    montagePosition.cellInRow = cellIndex;
                    itemIndex++;
                }
            }
            
            [rowMArray addObject:@( numberOfCellsInRow)];
        }
        self.perRowCellCountArray = [NSArray arrayWithArray:rowMArray];
    }
}

/// Returns number of cells in the given row
/// @param rowIndex Index of the row in the Montage.  This value should be Zero-based => the first row is rowIndex==0.
-(NSUInteger)cellCountForRowIndex:(NSUInteger)rowIndex;
{
    NSUInteger cellCount = 0;
    if (rowIndex < _rowCount && nil != self.perRowCellCountArray) {
        cellCount = [(NSNumber *)[self.perRowCellCountArray objectAtIndex:rowIndex] unsignedIntegerValue];
    }
    return cellCount;
}

-(NSDictionary *)montagePositions;
{
    if (nil != _montagePositions) {
        return _montagePositions;
    }
    
    _montagePositions = [NSDictionary new];
    if (0 < self.numberOfItems) {
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        for (int itemIndex=0; itemIndex<self.numberOfItems; itemIndex++) {
            CPTMontagePosition *montagePosition = [[CPTMontagePosition alloc] initMontagePositionWithItemIndex:itemIndex forMontageGrid:self];
            [tempDict setObject:montagePosition forKey:@(itemIndex)];
        }
        _montagePositions = [NSDictionary dictionaryWithDictionary:tempDict];
    }
    return _montagePositions;
}

-(CPTMontagePosition *)montagePositionForItemIndex:(NSUInteger)itemIndex;
{
    CPTMontagePosition *montagePosition = [self.montagePositions objectForKey:@(itemIndex)];
    return montagePosition;
}

-(NSUInteger)itemIndexForRow:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;
{
    NSUInteger itemIndex = NSNotFound;

    if (rowIndex < self.rowCount && cellIndex < self.defaultCellsPerRowCount) {

        NSUInteger row = 0;
        NSUInteger runningCellCount = 0;
        BOOL itemLocated = NO;
        
        do {
            if (row == rowIndex) {
                itemIndex = runningCellCount + cellIndex;
                itemLocated = YES;
            } else {
                runningCellCount += [self cellCountForRowIndex:row];
                row++;
            }
        } while (!itemLocated);
    }

    return itemIndex;
}

-(void)clearExistingPositionCellFrames;
{
    [self.montagePositions.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [(CPTMontagePosition *)obj setCellFrame:CGRectZero];
    }];
}

-(void)changeScrollDirection:(UICollectionViewScrollDirection)scrollDirection;
{
    self.scrollDirection = scrollDirection;
    [self generateMontageGridDetails];
}

@end
