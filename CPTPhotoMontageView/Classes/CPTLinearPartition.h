//
//  CPTLinearPartition.h
//  BalancedFlowLayout
//
//  Created by support@chronicstimulation.com on 05/03/2020.
//  Copyright (c) 2020 support@chronicstimulation.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Partitions a sequence of non-negative integers into the required number of partitions.
 * Based on implementation in Python by Óscar López: http://stackoverflow.com/a/7942946
 * Example: [LinearPartition linearPartitionForSequence:@[9,2,6,3,8,5,8,1,7,3,4] numberOfPartitions:3] => @[@[9,2,6,3],@[8,5,8],@[1,7,3,4]]
 */
@interface CPTLinearPartition : NSObject

+ (NSMutableArray *)linearPartitionForSequence:(NSArray *)sequence numberOfPartitions:(NSInteger)numberOfPartitions;

@end
