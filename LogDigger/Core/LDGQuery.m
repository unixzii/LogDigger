//
//  LDGQuery.m
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import "LDGQuery.h"

@implementation LDGQuery

@dynamic displayText;

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    return self;
}

- (NSString *)displayText {
    return @"";
}

- (BOOL)isItemMatched:(LDGLogItem *)item {
    /* Stub. */
    return NO;
}

@end
