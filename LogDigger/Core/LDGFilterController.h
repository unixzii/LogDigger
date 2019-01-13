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

/**
 An object to manage the collection of filter queries and perform the filtering
 operations.
 */
@interface LDGFilterController : NSObject

@property (weak) id<LDGFilterControllerDelegate> delegate;

/**
 The log model.
 
 @discussion The receiver will retain this object.
 */
@property (strong, nonatomic) LDGLogModel *logModel;

/**
 A Boolean value that determines whether filter needs to output the unmatched
 items.
 
 @discussion The common use case of this behavior is when you want to display
             the unmatched items with different styles instead of getting rid
             of them. Match items with `query` property equaling to `nil`
             are unmatched.
 */
@property (assign) BOOL includesUnmatchedItems;


/**
 An array containing the current queries.
 */
@property (readonly) NSArray<LDGQuery *> *queries;

/**
 An array containing the result matches.
 
 @discussion The contents of the array will be changed during the filter
             process. Clients need to deal with the mutation properly, and
             make a copy if you want a snapshot.
 */
@property (readonly) NSArray<LDGFilterMatch *> *matches;

/**
 A Boolean value indicates whether there are enabled queries.
 */
@property (readonly) BOOL hasEffectiveQueries;

/**
 An Boolean value indicates whther the filter process is running.
 */
@property (readonly) BOOL filterInFlight;

- (void)addFilterQuery:(LDGQuery *)query;
- (void)removeFilterQuery:(LDGQuery *)query;


/**
 Starts the filter process.
 
 @discussion This kicks off an background operation to perform the filtering,
             and clients can get notified about the changes via the delegate
             method.
 */
- (void)triggerFiltering;

/**
 Stops the filter process.
 */
- (void)stopFiltering;

@end

@protocol LDGFilterControllerDelegate <NSObject>
@optional
- (void)filterControllerMatchesDidChange:(LDGFilterController *)filterController;

@end


NS_ASSUME_NONNULL_END
