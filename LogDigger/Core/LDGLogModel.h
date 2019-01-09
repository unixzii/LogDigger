//
//  LDGLogModel.h
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LDGLogItem;
@class LDGQuery;
@class LDGLogModel;
//
//@protocol LDGLogModelDelegate <NSObject>
//@optional
//- (void)logModelDidFinishFiltering:(LDGLogModel *)logModel;
//
//@end

@interface LDGLogModel : NSObject

//@property (weak) id<LDGLogModelDelegate> delegate;
//@property (assign, nonatomic) BOOL showsMatchedItemsOnly;

@property (readonly, copy) NSString *fullText;
@property (readonly, copy) NSArray<LDGLogItem *> *items;
//@property (readonly) NSUInteger numberOfItems;
//@property (readonly) NSArray<LDGQuery *> *filterQueries;
//@property (readonly) BOOL hasEffectiveFilters;

- (instancetype)initWithString:(NSString *)string;

//- (void)addFilterQuery:(LDGQuery *)query;
//- (void)removeFilterQuery:(LDGQuery *)query;

//- (LDGLogItem *)logItemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
