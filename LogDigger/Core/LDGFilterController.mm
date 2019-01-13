//
//  LDGFilterController.mm
//  LogDigger
//
//  Created by Hongyu on 2019/1/5.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#import "LDGFilterController.h"
#import "LDGQuery.h"
#import "LDGLogModel.h"
#import "LDGLogItem.h"
#import "LDGFilterMatch.h"
#import "LDGFilterOperation.h"

#include <vector>

#include "LDGFilterWorkItem.h"

@interface LDGFilterController ()
@end

@implementation LDGFilterController {
    NSMutableArray<LDGQuery *> *_queries;
    NSMutableArray<LDGFilterMatch *> *_internalMatches;
    NSOperationQueue *_operationQueue;
    std::vector<logdigger::filter_work_item> _workItems;
}

@synthesize includesUnmatchedItems = _includesUnmatchedItems;
@dynamic queries;
@dynamic hasEffectiveQueries;
@dynamic filterInFlight;

- (instancetype)init {
    self = [super init];
    if (self) {
        _queries = [NSMutableArray array];
        _internalMatches = [NSMutableArray array];
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"com.cyandev.LogDigger.filter";
        _operationQueue.maxConcurrentOperationCount = 8;
        _operationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    }
    return self;
}

- (void)setLogModel:(LDGLogModel *)logModel {
    _logModel = logModel;
    
    // Prepare work items for filtering.
    [logModel.items enumerateObjectsUsingBlock:^(LDGLogItem *obj,
                                                 NSUInteger idx,
                                                 BOOL *stop) {
        LDGFilterMatch *match = [[LDGFilterMatch alloc] init];
        match.item = obj;
        
        self->_workItems.emplace_back((__bridge void *) obj,
                                      const_cast<void *>(CFBridgingRetain(match)));
    }];
}

- (NSArray<LDGQuery *> *)queries {
    return _queries;
}

- (NSArray<LDGFilterMatch *> *)matches {
    return _internalMatches;
}

- (BOOL)hasEffectiveQueries {
    __block BOOL flag = NO;
    [_queries enumerateObjectsUsingBlock:^(LDGQuery *obj, NSUInteger idx, BOOL *stop) {
        if (obj.enabled) {
            flag = YES;
            *stop = YES;
        }
    }];
    return flag;
}

- (BOOL)filterInFlight {
    return _operationQueue.operationCount > 0;
}

- (void)addFilterQuery:(LDGQuery *)query {
    @synchronized (_queries) {
        [_queries addObject:query];
    }
}

- (void)removeFilterQuery:(LDGQuery *)query {
    @synchronized (_queries) {
        [_queries removeObject:query];
    }
}

- (void)triggerFiltering {
    [self _performFiltering];
}

- (void)stopFiltering {
    if (!self.filterInFlight) return;
    
    NSArray<NSOperation *> *ops = [_operationQueue.operations copy];
    [ops enumerateObjectsUsingBlock:^(NSOperation *obj, NSUInteger idx, BOOL *stop) {
        [obj cancel];
    }];
    
    [_operationQueue waitUntilAllOperationsAreFinished];
}

- (void)_performFiltering {
    [self stopFiltering];
    
    [_internalMatches removeAllObjects];
    
    if (!self.hasEffectiveQueries) {
        [self _notifyChange];
        return;
    }
    
    static const NSUInteger kGroupCount = 8;
    
    NSUInteger itemsCount = self.logModel.items.count;
    NSOperation *reduceOp = [NSBlockOperation blockOperationWithBlock:^{
        [self->_internalMatches removeAllObjects];
        for (auto &workItem : self->_workItems) {
            LDGFilterMatch *match = (__bridge id) workItem.match;
            if (self.includesUnmatchedItems || match.query) {
                [self->_internalMatches addObject:match];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self _notifyChange];
        }];
    }];
    
    if (itemsCount < 64) {
        // Dataset too small, don't use concurrent mode.
        LDGFilterOperation *op = [[LDGFilterOperation alloc] init];
        op.workItems = &_workItems;
        op.queries = self.queries;
        op.iterationRange = NSMakeRange(0, itemsCount);
        
        [reduceOp addDependency:op];
        [_operationQueue addOperation:op];
    } else {
        NSUInteger groupSize = itemsCount / kGroupCount;
        for (NSUInteger i = 0; i < kGroupCount; i++) {
            LDGFilterOperation *op = [[LDGFilterOperation alloc] init];
            op.workItems = &_workItems;
            op.queries = self.queries;
            if (i == kGroupCount - 1) {
                op.iterationRange = NSMakeRange(i * groupSize,
                                                itemsCount - (kGroupCount - 1) * groupSize);
            } else {
                op.iterationRange = NSMakeRange(i * groupSize, groupSize);
            }
            
            [reduceOp addDependency:op];
            [_operationQueue addOperation:op];
        }
    }
    
    [_operationQueue addOperation:reduceOp];
    
    [self _notifyChange];
}

- (void)_notifyChange {
    if ([self.delegate respondsToSelector:@selector(filterControllerMatchesDidChange:)]) {
        [self.delegate filterControllerMatchesDidChange:self];
    }
}

@end
