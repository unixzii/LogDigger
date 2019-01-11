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

/**
 A model object to encapsulate the log.
 */
@interface LDGLogModel : NSObject

@property (readonly, copy) NSString *fullText;

/**
 An array containing the log items, delimited via line breaks.
 */
@property (readonly, copy) NSArray<LDGLogItem *> *items;

- (instancetype)initWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
