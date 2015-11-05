//
//  ZYLoginView.m
//  MyNote
//
//  Created by zhuyongqing on 15/10/25.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import "ZYLoginView.h"
#import "ZYAccount.h"
#import "UIView+ITTAdditions.h"
#import "MBProgressHUD+Add.h"
#define kSize [UIScreen mainScreen].bounds.size
#define kLabelH 160
#define kTextH 300
#define PASSWORLD @"PASSWORLD"
@implementation ZYLoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //提示
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0,100,kSize.width,30)];
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:17];
        self.label.adjustsFontSizeToFitWidth = YES;
        if ([ZYAccount shareInstance].passWorld == nil) {
            self.label.text = @"请设定验证(以后将会把这个密码用作验证密码，请牢记)";
        }else{
            self.label.text = @"请输入验证";
        }
        [self addSubview:self.label];
        
        //输入框
        self.pass = [[UITextField alloc] initWithFrame:CGRectMake(kSize.width/2-kTextH/2,self.label.bottom+20,kTextH,40)];
        self.pass.textAlignment = NSTextAlignmentCenter;
        self.pass.keyboardType = UIKeyboardTypeNumberPad;
        //密码安全
        self.pass.secureTextEntry = YES;
        //开始编辑时清空
        self.pass.clearsOnBeginEditing = YES;
        //右边的x按钮
        self.pass.clearButtonMode = UITextFieldViewModeAlways;
        self.pass.textColor = [UIColor blackColor];
        self.pass.borderStyle = UITextBorderStyleRoundedRect;
        self.pass.delegate = self;
        [self addSubview:self.pass];
        
        //底部收起的按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(kSize.width/2-40,kSize.height/2-50,80,40)];
        [btn setTitle:@"收起" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(packUp) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    
    return self;
}

#pragma mark - 视图收起的动画
- (void)packUp
{
    
    [self.pass resignFirstResponder];
    [self loginViewMoveToPoint:CGPointMake(0, -self.height) andSussec:^{
        [self removeFromSuperview];
    }];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.pass resignFirstResponder];
}

#pragma mark - 输入完成的操作
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    //如果是第一次创建
    if ([ZYAccount shareInstance].passWorld == nil && ![self.pass.text isEqualToString:@""]) {
        [ZYAccount shareInstance].passWorld = self.pass.text;
        //保存密码
        [[NSUserDefaults standardUserDefaults] setObject:self.pass.text forKey:PASSWORLD];
    }
    
    //验证密码
  [ZYAccount shareInstance].isLogin = [[ZYAccount shareInstance] setloginPassWorld:textField.text];
    
    if ([_delegate respondsToSelector:@selector(isLoginPass)]) {
        [_delegate isLoginPass];
    }
}

#pragma mark - 单例
+ (ZYLoginView *)shareInstance
{
    static ZYLoginView *login = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        login = [[self alloc] init];
    });
    return login;
}

#pragma mark - 动画
- (void)loginViewMoveToPoint:(CGPoint)point andSussec:(completion)sussecd
{
    [UIView animateWithDuration:0.4 animations:^{
        self.origin = point;
    } completion:^(BOOL finished) {
        sussecd();
        [self removeFromSuperview];
    }];
}


@end
