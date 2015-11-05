//
//  ZYAccount.h
//  MyNote
//
//  Created by zhuyongqing on 15/10/25.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYAccount : NSObject

@property(nonatomic,strong) NSString *passWorld;

@property(nonatomic,assign) BOOL isLogin;

+ (ZYAccount *)shareInstance;

- (BOOL)setloginPassWorld:(NSString *)pass;

@end
