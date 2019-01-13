//
//  LDGFilterOperation.mm
//  LogDigger
//
//  Created by Hongyu on 2019/1/13.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#import "LDGFilterOperation.h"
#import "LDGLogItem.h"
#import "LDGQuery.h"
#import "LDGFilterMatch.h"

@implementation LDGFilterOperation

- (void)main {
    size_t from = self.iterationRange.location;
    size_t to = from + self.iterationRange.length;
    auto &items = *self.workItems;
    NSArray<LDGQuery *> *queries = self.queries;
    
    for (size_t i = from; i < to && !self.cancelled; i++) {
        LDGLogItem *logItem = (__bridge id) items[i].log_item;
        LDGFilterMatch *match = (__bridge id) items[i].match;
        
        match.query = nil;
        
        [queries enumerateObjectsUsingBlock:^(LDGQuery *obj,
                                              NSUInteger idx,
                                              BOOL *stop) {
            if (self.cancelled) {
                *stop = YES;
                return;
            }
            
            if (obj.enabled && [obj isItemMatched:logItem]) {
                match.query = obj;
                *stop = YES;
            }
        }];
    }
}

@end
