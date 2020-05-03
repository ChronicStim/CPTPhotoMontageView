//
//  CPTLinearPartition.m
//  BalancedFlowLayout
//
//  Created by support@chronicstimulation.com on 05/03/2020.
//  Copyright (c) 2020 support@chronicstimulation.com. All rights reserved.
//

#import "CPTLinearPartition.h"


#define CPT_LP_TABLE_LOOKUP(table, i, j, rowsize) (table)[(i) * (rowsize) + (j)]


@implementation CPTLinearPartition

/**
 *  Returns a solution integer array for the linear partition problem
 *
 *  @param sequence      An array of NSNumber's
 *  @param numPartitions The number of partitions wanted
 *
 *  @return A C-style solution table
 */
+ (NSInteger *)linearPartitionTable:(NSArray *)sequence numPartitions:(NSInteger)numPartitions
{
    NSInteger k = numPartitions;
    NSInteger n = [sequence count];
    
    // allocate a table buffer of n * k integers
    NSInteger tableSize = sizeof(NSInteger) * n * k;
    NSInteger *tmpTable = (NSInteger *)malloc(tableSize);
    memset(tmpTable, 0, tableSize);
    
    // allocate a solution buffer of (n - 1) * (k - 1) integers
    NSInteger solutionSize = sizeof(NSInteger) * (n - 1) * (k - 1);
    NSInteger *solution = (NSInteger *)malloc(solutionSize);
    memset(solution, 0, solutionSize);
    
    // fill table with initial values
    for (NSInteger i = 0; i < n; i++) {
        NSInteger offset = i? CPT_LP_TABLE_LOOKUP(tmpTable, i - 1, 0, k) : 0;
        CPT_LP_TABLE_LOOKUP(tmpTable, i, 0, k) = [sequence[i] integerValue] + offset;
    }
    
    for (NSInteger j = 0; j < k; j++) {
        CPT_LP_TABLE_LOOKUP(tmpTable, 0, j, k) = [sequence[0] integerValue];
    }
    
    // calculate the costs and fill the solution buffer
    for (NSInteger i = 1; i < n; i++) {
        for (NSInteger j = 1; j < k; j++) {
            NSInteger currentMin = 0;
            NSInteger minX = NSIntegerMax;
            
            for (NSInteger x = 0; x < i; x++) {
                NSInteger c1 = CPT_LP_TABLE_LOOKUP(tmpTable, x, j - 1, k);
                NSInteger c2 = CPT_LP_TABLE_LOOKUP(tmpTable, i, 0, k) - CPT_LP_TABLE_LOOKUP(tmpTable, x, 0, k);
                NSInteger cost = MAX(c1, c2);
                
                if (!x || cost < currentMin) {
                    currentMin = cost;
                    minX = x;
                }
            }
            
            CPT_LP_TABLE_LOOKUP(tmpTable, i, j, k) = currentMin;
            CPT_LP_TABLE_LOOKUP(solution, i - 1, j - 1, k - 1) = minX;
        }
    }
    
    // free the tmp table, we don't need it anymore
    free(tmpTable);
    
    return solution;
}

+ (NSMutableArray *)linearPartitionForSequence:(NSArray *)sequence numberOfPartitions:(NSInteger)numberOfPartitions
{
    NSInteger n = [sequence count];
    NSInteger k = numberOfPartitions;
    
    if (k <= 0) return [NSMutableArray array];
    
    if (k >= n) {
        NSMutableArray *partition = [[NSMutableArray alloc] init];
        [sequence enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [partition addObject:@[obj]];
        }];
        return [partition mutableCopy];
    }
    
    if (n == 1) {
        return [NSMutableArray arrayWithObject:sequence];
    }
    
    // get the solution table
    NSInteger *solution = [self linearPartitionTable:sequence numPartitions:numberOfPartitions];
    NSInteger solutionRowSize = numberOfPartitions - 1;
    
    k = k - 2;
    n = n - 1;
    NSMutableArray *answer = [NSMutableArray array];
    
    while (k >= 0) {
        if (n < 1) {
            [answer insertObject:@[] atIndex:0];
        } else {
            NSMutableArray *currentAnswer = [NSMutableArray array];
            for (NSInteger i = CPT_LP_TABLE_LOOKUP(solution, n - 1, k, solutionRowSize) + 1, range = n + 1; i < range; i++) {
                [currentAnswer addObject:sequence[i]];
            }
            [answer insertObject:currentAnswer atIndex:0];
            
            n = CPT_LP_TABLE_LOOKUP(solution, n - 1, k, solutionRowSize);
        }
        
        k = k - 1;
    }
    
    // free the solution table because we don't need it anymore
    free(solution);
    
    NSMutableArray *currentAnswer = [NSMutableArray array];
    for (NSInteger i = 0, range = n + 1; i < range; i++) {
        [currentAnswer addObject:sequence[i]];
    }
    
    [answer insertObject:currentAnswer atIndex:0];
    
    return answer;
}

@end



