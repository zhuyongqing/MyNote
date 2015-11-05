//
//  ZYLoginView.h
//  MyNote
//
//  Created by zhuyongqing on 15/10/25.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZYLoginViewDelegate <NSObject>

- (void)isLoginPass;

@end

typedef void(^completion)();

@interface ZYLoginView : UIView<UITextFieldDelegate>

@property(nonatomic,strong) UILabel *label;
@property(nonatomic,strong) UITextField *pass;

@property(nonatomic,assign) id<ZYLoginViewDelegate>delegate;

+ (ZYLoginView *)shareInstance;

- (void)loginViewMoveToPoint:(CGPoint)point andSussec:(completion)sussecd;

@end
