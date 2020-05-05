//
//  CPTMontagePosition.m
//  CPTPhotoMontageView
//
//  Created by Bob Kutschke on 5/4/20.
//

#import "CPTMontagePosition.h"

@implementation CPTMontagePosition

-(instancetype)initMontagePositionWithRow:(NSUInteger)row cellInRow:(NSUInteger)cellInRow forMontageGrid:(CPTMontageGrid *)montageGrid;
{
    self = [super init];
    if (self) {
        _row = row;
        _cellInRow = cellInRow;
        _montageGrid = montageGrid;
    }
    return self;
}

-(instancetype)initMontagePositionWithItemIndex:(NSUInteger)itemIndex forMontageGrid:(CPTMontageGrid *)montageGrid;
{
    self = [super init];
    if (self) {
        _itemIndex = itemIndex;
        _montageGrid = montageGrid;
    }
    return self;
}

@end
