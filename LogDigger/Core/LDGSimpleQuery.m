//
//  LDGSimpleQuery.m
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import "LDGSimpleQuery.h"
#import "LDGLogItem.h"

@implementation LDGSimpleQuery

- (NSString *)displayText {
    return self.keyword;
}

- (BOOL)isItemMatched:(LDGLogItem *)item {
    return [item.lineText containsString:self.keyword];
}

@end
