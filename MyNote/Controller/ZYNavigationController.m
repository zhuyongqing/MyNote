//
//  ZYNavigationController.m
//  MyNote
//
//  Created by zhuyongqing on 15/10/20.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import "ZYNavigationController.h"

@interface ZYNavigationController ()


@end

@implementation ZYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setBarTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bg"]]];
    
    UINavigationBar *bar = [UINavigationBar appearance];
    
    [bar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
  //  UIBarButtonItem *item = [UIBarButtonItem appearance];
    
//    UIImage *img = [[UIImage imageNamed:@"back_button"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile];
//    [item setBackButtonBackgroundImage:img forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [item setTitle:@"列表"];
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
