//
//  LDGFilterMatch.h
//  LogDigger
//
//  Created by Hongyu on 2019/1/5.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LDGLogItem;
@class LDGQuery;

/**
 The filter match.
 */
@interface LDGFilterMatch : NSObject

@property (strong) LDGLogItem *item;
@property (strong, nullable) LDGQuery *query;

@end

NS_ASSUME_NONNULL_END
