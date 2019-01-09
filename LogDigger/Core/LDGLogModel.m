//
//  LDGLogModel.m
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import "LDGLogModel.h"
#import "LDGLogItem.h"
//#import "LDGQuery.h"

//#define ADD_OBSERVER(target, key) \
//[target addObserver:self forKeyPath:NSStringFromSelector(@selector(key)) options:NSKeyValueObservingOptionNew context:&kContext]
//
//#define REMOVE_OBSERVER(target, key) \
//[target removeObserver:self forKeyPath:NSStringFromSelector(@selector(key)) context:&kContext]

static char kContext = 0;

@interface LDGLogModel ()
@property (readwrite, copy) NSString *fullText;
@property (readwrite, copy) NSArray<LDGLogItem *> *items;
@end

@implementation LDGLogModel {
//    NSMutableArray<LDGQuery *> *_filterQueries;
//    NSMutableArray<LDGLogItem *> *_filteredItems;
}

//@dynamic numberOfItems;
//@dynamic filterQueries;
//@dynamic hasEffectiveFilters;

- (void)dealloc {
//    [_filterQueries enumerateObjectsUsingBlock:^(LDGQuery * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        REMOVE_OBSERVER(obj, enabled);
//        REMOVE_OBSERVER(obj, textColor);
//        REMOVE_OBSERVER(obj, backgroundColor);
//    }];
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _fullText = string;
        [self _parse];
    }
    return self;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
//                       context:(void *)context {
//    if (context == &kContext) {
//        // Properties of queries changed, do filter again.
//        [self _doFilter];
//    }
//}

//- (void)setShowsMatchedItemsOnly:(BOOL)showsMatchedItemsOnly {
//    _showsMatchedItemsOnly = showsMatchedItemsOnly;
//    [self _doFilter];
//}
//
//- (NSUInteger)numberOfItems {
//    if (self.showsMatchedItemsOnly) {
//        return _filteredItems.count;
//    }
//    return self.items.count;
//}
//
//- (NSArray<LDGQuery *> *)filterQueries {
//    return [_filterQueries copy];
//}
//
//- (BOOL)hasEffectiveFilters {
//    __block BOOL ret = NO;
//    [_filterQueries enumerateObjectsUsingBlock:^(LDGQuery * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.enabled) {
//            ret = YES;
//            *stop = YES;
//        }
//    }];
//    return ret;
//}

//- (void)addFilterQuery:(LDGQuery *)query {
//    [_filterQueries addObject:query];
//    ADD_OBSERVER(query, enabled);
//    ADD_OBSERVER(query, textColor);
//    ADD_OBSERVER(query, backgroundColor);
//    [self _doFilter];
//}
//
//- (void)removeFilterQuery:(LDGQuery *)query {
//    [_filterQueries removeObject:query];
//    REMOVE_OBSERVER(query, enabled);
//    REMOVE_OBSERVER(query, textColor);
//    REMOVE_OBSERVER(query, backgroundColor);
//    [self _doFilter];
//}
//
//- (LDGLogItem *)logItemAtIndex:(NSUInteger)index {
//    if (self.showsMatchedItemsOnly) {
//        return _filteredItems[index];
//    }
//    return self.items[index];
//}

- (void)_parse {
    NSMutableArray *items = [NSMutableArray array];
    [_fullText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        LDGLogItem *item = [LDGLogItem new];
        item.lineText = line;
        [items addObject:item];
    }];
    self.items = [items copy];
}

//- (void)_doFilter {
//    if (self.showsMatchedItemsOnly) {
//        [_filteredItems removeAllObjects];
//    }
//
//    BOOL needsMatch = self.hasEffectiveFilters;
//    [self.items enumerateObjectsUsingBlock:^(LDGLogItem *item, NSUInteger idx, BOOL *stop) {
//        item.matchedFilters = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPersonality];
//        if (!needsMatch) {
//            // No enabled filters, just clear the old states.
//            if (self.showsMatchedItemsOnly) {
//                // And don't forget to add the item to the filtered list, if needed.
//                [self->_filteredItems addObject:item];
//            }
//            return;
//        }
//
//        __block BOOL matched = NO;
//        [self->_filterQueries enumerateObjectsUsingBlock:^(LDGQuery *query, NSUInteger idx, BOOL *stop) {
//            if (query.enabled && [query isItemMatched:item]) {
//                [item.matchedFilters addPointer:(__bridge void *) query];
//                matched = YES;
//            }
//        }];
//
//        if (matched && self.showsMatchedItemsOnly) {
//            [self->_filteredItems addObject:item];
//        }
//    }];
//
//    // Notify changes.
//    if ([self.delegate respondsToSelector:@selector(logModelDidFinishFiltering:)]) {
//        [self.delegate logModelDidFinishFiltering:self];
//    }
//}

@end
