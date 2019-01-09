//
//  LDGFilterController.m
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

@interface LDGFilterController ()
@end

@implementation LDGFilterController {
    NSMutableArray<LDGQuery *> *_queries;
    NSMutableArray<LDGFilterMatch *> *_internalMatches;
    NSThread *_filterThread;
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
    }
    return self;
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
    return _filterThread.executing;
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
    if (!_filterThread) return;
    
    NSThread *filterThread = _filterThread;
    _filterThread = nil;
    
    if (filterThread.executing) {
        [filterThread cancel];
    }
    
    // Cocoa-way to join a thread.
    while (filterThread.executing) {
        usleep(1000);
    }
}

- (void)_performFiltering {
    [self stopFiltering];
    
    [_internalMatches removeAllObjects];
    [self _notifyChange];
    
    if (!self.hasEffectiveQueries) {
        return;
    }
    
    _filterThread = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(_performFilteringInThread)
                                              object:nil];
    _filterThread.threadPriority = 0.2;
    [_filterThread start];
}

- (void)_performFilteringInThread {
    NSThread *selfThread = [NSThread currentThread];
    
    NSArray<LDGQuery *> *queriesCopy;
    @synchronized (_queries) {
        queriesCopy = [_queries copy];
    }
    
#define STOP_IF_CANCELLED \
if (selfThread.cancelled) { \
    *stop = YES; \
    return; \
}; do {} while (0)
    
    __block NSUInteger batchedSize = 0;
    NSMutableArray<LDGFilterMatch *> *buffer = [NSMutableArray arrayWithCapacity:1000];
    
    [self.logModel.items enumerateObjectsUsingBlock:^(LDGLogItem *item, NSUInteger idx, BOOL *stop) {
        __block BOOL matched = NO;
        STOP_IF_CANCELLED;
        [queriesCopy enumerateObjectsUsingBlock:^(LDGQuery *query, NSUInteger idx, BOOL *stop) {
            STOP_IF_CANCELLED;
            if (query.enabled && [query isItemMatched:item]) {
                *stop = YES;
                matched = YES;
                
                LDGFilterMatch *match = [[LDGFilterMatch alloc] init];
                match.item = item;
                match.query = query;
                
                [buffer addObject:match];
                batchedSize++;
            }
        }];
        
        if (!matched && self.includesUnmatchedItems) {
            LDGFilterMatch *match = [[LDGFilterMatch alloc] init];
            match.item = item;
            match.query = nil;  // Indicates an unmatched item.
            
            [buffer addObject:match];
            batchedSize++;
        }
        
        if (batchedSize > 1000) {
            batchedSize = 0;
            NSArray<LDGFilterMatch *> *bufferCopy = [buffer copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self->_filterThread != selfThread) return;
                [self->_internalMatches addObjectsFromArray:bufferCopy];
                [self _notifyChange];
            });
            [buffer removeAllObjects];
        }
    }];
    
#undef STOP_IF_CANCELLED
    
    if (buffer.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_filterThread != selfThread) return;
            [self->_internalMatches addObjectsFromArray:buffer];
            [self _notifyChange];
        });
    }
}

- (void)_notifyChange {
    if ([self.delegate respondsToSelector:@selector(filterControllerMatchesDidChange:)]) {
        [self.delegate filterControllerMatchesDidChange:self];
    }
}

@end
