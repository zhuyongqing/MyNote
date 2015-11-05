//
//  ZYAccount.m
//  MyNote
//
//  Created by zhuyongqing on 15/10/25.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import "ZYAccount.h"

#define PASSWORLD @"PASSWORLD"

@implementation ZYAccount

+ (ZYAccount *)shareInstance
{
    static ZYAccount *account = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        account = [[ZYAccount alloc] init];
    });
    return account;
}

#pragma mark - 是否验证
- (BOOL)setloginPassWorld:(NSString *)pass;
{
    if ([pass isEqualToString:self.passWorld]) {
        return YES;
    }
    return NO;
}

- (NSString *)passWorld{
    return [[NSUserDefaults standardUserDefaults] stringForKey:PASSWORLD];
}


@end
