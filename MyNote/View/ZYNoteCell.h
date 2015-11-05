//
//  ZYNoteCell.h
//  MyNote
//
//  Created by zhuyongqing on 15/10/20.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZYNoteCellDelegate <NSObject>

- (void)swipDowithindex:(NSInteger)index;
- (void)deleteCellwithindex:(NSInteger)index;

@end

@interface ZYNoteCell : UITableViewCell


@property(nonatomic,assign) id<ZYNoteCellDelegate>delegate;

/**
 *  时间
 */
@property(nonatomic,strong) UILabel *timeLabel;

/**
 *  note描述
 */
@property(nonatomic,strong) UILabel *titleLabel;

/**
 *  分割线
 */
@property(nonatomic,strong) UIView *backLine;

/**
 *  背景的img
 */
@property(nonatomic,strong) UIImageView *backImg;

/**
 *  左侧的钉子
 */
@property(nonatomic,strong) UIImageView *nailImg;

/**
 *  删除按钮
 */
@property(nonatomic,strong) UIButton *deleteBtn;
/**
 *  标志有图
 */
@property(nonatomic,strong) UIImageView *samllImg;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andInteger:(NSInteger)index;

- (void)buildNotewithindex:(NSInteger)index and:(BOOL)ishave;
@end
