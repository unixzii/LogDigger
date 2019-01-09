//
//  LDGFilterController.h
//  LogDigger
//
//  Created by Hongyu on 2019/1/5.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LDGQuery;
@class LDGLogModel;
@class LDGFilterMatch;

@protocol LDGFilterControllerDelegate;

@interface LDGFilterController : NSObject

@property (weak) id<LDGFilterControllerDelegate> delegate;
@property (strong) LDGLogModel *logModel;
@property (assign) BOOL includesUnmatchedItems;

@property (readonly) NSArray<LDGQuery *> *queries;
@property (readonly) NSArray<LDGFilterMatch *> *matches;
@property (readonly) BOOL hasEffectiveQueries;
@property (readonly) BOOL filterInFlight;

- (void)addFilterQuery:(LDGQuery *)query;
- (void)removeFilterQuery:(LDGQuery *)query;

- (void)triggerFiltering;
- (void)stopFiltering;

@end

@protocol LDGFilterControllerDelegate <NSObject>
@optional
- (void)filterControllerMatchesDidChange:(LDGFilterController *)filterController;

@end


NS_ASSUME_NONNULL_END
