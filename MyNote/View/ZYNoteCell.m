//
//  ZYNoteCell.m
//  MyNote
//
//  Created by zhuyongqing on 15/10/20.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import "ZYNoteCell.h"
#import "UIView+ITTAdditions.h"
#import "UIColor+UIColor_Hex.h"
#define ksize [UIScreen mainScreen].bounds.size
// 分割线，占位字的灰色
#define kBaseGrayColor [UIColor colorWithHexString: @"dddddd"]
// 基本的文字颜色
#define kBaseTextColor [UIColor colorWithHexString: @"626466"]

//RGB颜色设置
#define kRGBcolor(red,g,b) [UIColor colorWithRed:red/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kImgH 60        //背景高
#define kLabelLeft 45
#define knailH 60       //钉子的高度
#define kTen 10
#define kDuration 0.2   //动画时间
#define kHeight 70     //cell 的高度
#define smallImgW 44   //小图宽
#define smallImgH 30   //小图高
@interface ZYNoteCell()

@property(nonatomic,strong) ZYNoteCell *cell;

@end

@implementation ZYNoteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andInteger:(NSInteger)index
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //删除按钮
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"slider_delete_n"] forState:UIControlStateNormal];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.deleteBtn.enabled = NO;
        [self.deleteBtn addTarget:self action:@selector(deleteCell) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deleteBtn];
        
        //背景图片
        self.backImg = [[UIImageView alloc] init];
        self.backImg.image = [UIImage imageNamed:@"list_item_bg"];
        self.backImg.contentMode = UIViewContentModeScaleAspectFill;
        self.backImg.clipsToBounds = YES;
        [self.contentView addSubview:self.backImg];
        //左侧的钉子图片
        self.nailImg = [[UIImageView alloc] init];
        self.nailImg.image = [UIImage imageNamed:@"clip_n"];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.nailImg.clipsToBounds = YES;
        [self.contentView addSubview:self.nailImg];
        //时间
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textColor = kRGBcolor(196, 179, 159);
        [self.backImg addSubview:self.timeLabel];
        //note内容
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor =kRGBcolor(114, 80, 62);
        [self.backImg addSubview:self.titleLabel];
        //上方的间距
        self.backLine = [[UIView alloc] init];
        self.backLine.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.backLine];
        
        //加入手势
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipDo:)];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:right];
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipDo:)];
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:left];
        
        //标志有图
        self.samllImg = [[UIImageView alloc] init];
        self.samllImg.contentMode = UIViewContentModeScaleAspectFill;
        self.samllImg.clipsToBounds = YES;
        self.samllImg.image = [UIImage imageNamed:@"icon_photo"];
      
    }
    return self;
}

//手势滑动
- (void)rightSwipDo:(UISwipeGestureRecognizer *)swip
{
    if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
        //背景图的滑动
        [UIView animateWithDuration:kDuration animations:^{
            self.backImg.origin = CGPointMake(self.deleteBtn.right-self.deleteBtn.width/2+5,self.backImg.origin.y);
            self.nailImg.image = [UIImage imageNamed:@"clip_p"];
            //删除按钮
            self.deleteBtn.enabled = YES;
        }];
    }else
    {
        [UIView animateWithDuration:kDuration animations:^{
            self.backImg.origin = CGPointMake(0,self.backImg.origin.y);
        } completion:^(BOOL finished) {
            self.nailImg.image =[UIImage imageNamed:@"clip_n"];
        }];
        //删除按钮不可用
        self.deleteBtn.enabled = NO;
  }
  
    if ([_delegate respondsToSelector:@selector(swipDowithindex:)]) {
        [_delegate swipDowithindex:self.tag];
    }
  
}

//删除
- (void)deleteCell
{
    if ([_delegate respondsToSelector:@selector(deleteCellwithindex:)]) {
        [_delegate deleteCellwithindex:self.tag];
    }
}

- (void)buildNotewithindex:(NSInteger)index and:(BOOL)ishave
{
    self.tag = index;
    //间距
    self.backLine.frame = CGRectMake(0,0,ksize.width,kTen);
    
    //按钮
    [self.deleteBtn setFrame:CGRectMake(20,self.backLine.bottom+kTen,80, 45)];
    
    //背景
    self.backImg.frame = CGRectMake(0,self.backLine.bottom,ksize.width,kImgH);
    //钉子
    self.nailImg.frame = CGRectMake(0,self.backImg.top+3,23,knailH);
    //时间
    self.timeLabel.frame = CGRectMake(kLabelLeft,3,ksize.width-80,15);
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    //内容
    self.titleLabel.frame = CGRectMake(self.timeLabel.left,self.timeLabel.bottom-5,ksize.width-self.timeLabel.left-smallImgW,kHeight-self.timeLabel.height);
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    
    //小图
    if (ishave) {
        self.samllImg.frame = CGRectMake(self.titleLabel.right-kTen,self.titleLabel.top+13,smallImgW, smallImgH);
        [self.backImg addSubview:self.samllImg];
    }
}


@end
