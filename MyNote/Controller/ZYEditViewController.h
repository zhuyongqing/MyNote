//
//  ZYEditViewController.h
//  MyNote
//
//  Created by zhuyongqing on 15/10/20.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MynoteModel.h"
typedef enum{
    kEditTypechange,
    kEditTypenew
}editType;

@interface ZYEditViewController : UIViewController

@property(nonatomic,assign) editType type;

@property(nonatomic,strong) MynoteModel *note;

@property(nonatomic,strong) UIImageView *photoImg;


@end
