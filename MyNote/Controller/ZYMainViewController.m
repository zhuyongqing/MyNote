//
//  ZYMainViewController.m
//  MyNote
//
//  Created by zhuyongqing on 15/10/20.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import "ZYMainViewController.h"
#import "MynoteModel+CoreDataProperties.h"
#import "MynoteModel.h"
#import "AppDelegate.h"
#import "ZYNoteCell.h"
#import "ZYEditViewController.h"
#import "UIView+ITTAdditions.h"
#import "ZYLoginView.h"
#import "ZYAccount.h"
#import "MBProgressHUD+Add.h"
#import "LocalAuthentication/LAContext.h"
#define kDuration 0.2
@interface ZYMainViewController ()<ZYNoteCellDelegate,ZYLoginViewDelegate>
/**
 *  所有笔记的数组
 */
@property(nonatomic,strong) NSMutableArray *allNote;

//没有验证的笔记数组
@property(nonatomic,strong) NSMutableArray *haveNote;

@property (nonatomic,weak) AppDelegate *myDelegate;

@property(nonatomic,strong) ZYLoginView *loginView;


@end

@implementation ZYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建背景
    [self setBackgroudView];
    //创建导航栏
    [self buildNavigationBar];
    
    //去除系统的线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //得到应用程序代理类对象
    self.myDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
}


#pragma mark - 查询现在所有的数据

- (void)findAllNote
{
    //创建一个查询的请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设定查询哪一种实体的对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MynoteModel" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [request setEntity:entity];
    //执行查询
    NSError *error;
    NSArray *result = [self.myDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    NSSortDescriptor *sort1=[[NSSortDescriptor alloc] initWithKey:@"trueTime" ascending:NO];
    self.allNote  = [[result sortedArrayUsingDescriptors:@[sort1]] mutableCopy];
    [self.haveNote removeAllObjects];
    for (MynoteModel *note in self.allNote) {
        if (![note.isHaveLogin isEqualToString:@"1"]) {
            [self.haveNote addObject:note];
        }
    }
    [self.tableView reloadData];
}

/**
 *  懒加载数组
 *
 */
#pragma mark - 懒加载数组
- (NSMutableArray *)allNote
{
    if (!_allNote) {
        _allNote = [[NSMutableArray alloc] init];
    }
    return _allNote;
}

- (NSMutableArray *)haveNote
{
    if (!_haveNote) {
        _haveNote = [[NSMutableArray alloc] init];
    }
    return _haveNote;
}

/**
 *  创建背景
 *
 */
#pragma mark - 创建背景
- (void)setBackgroudView
{
    UIImageView *img = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    img.image = [UIImage imageNamed:@"home_bg"];
    [self.tableView setBackgroundView:img];
}

/**
 *  创建导航栏
 */
#pragma mark - 设置导航栏
- (void)buildNavigationBar
{
    self.title = @"便签";
    //左边的设置button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 45, 40)];
   // [btn setImage:[UIImage imageNamed:@"btn_about"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
    [btn setTitle:@"秘密" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btn addTarget:self action:@selector(leftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftbar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftbar;
    
    //右边的编写
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    [right setFrame:CGRectMake(0, 0, 40, 40)];
    [right setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIImage *img = [[UIImage imageNamed:@"new_note_icon"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [right setImage:img forState:UIControlStateNormal];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightBar;
}

/**
 *  右边按钮点击事件
 */
#pragma mark - 导航栏右边 编写按钮
- (void)rightBarButtonAction
{
    ZYEditViewController *edit = [[ZYEditViewController alloc] init];
    edit.type = kEditTypenew;
    [self.navigationController pushViewController:edit animated:YES];
}

/**
 *  左边按钮点击事件
 */
#pragma mark - 左边按钮点击事件
- (void)leftBarButtonAction
{
    if ([ZYAccount shareInstance].isLogin) {
        return;
    }
    //指纹验证
    LAContext *myContext = [[LAContext alloc] init];

    NSError *authError = nil;
 
    NSString *myLocalizedReasonString = @"请输入指纹";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    
                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                         [ZYAccount shareInstance].isLogin = YES;
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.tableView reloadData];
                                             [MBProgressHUD showText:@"验证成功" toView:self.view];
                                         });
                                     });
                                  
                                } else {
                                 
                                    if (error.code == kLAErrorUserFallback) {
                                        //点击输入密码
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           ZYLoginView *login = [ZYLoginView shareInstance];
                                           login.frame = CGRectMake(0, 0, self.view.width,self.view.height/2);
                                           login.delegate = self;
                                           [self.view addSubview:login];
                                       });
                                    }
                                    
                                }
                            
                            }];
 
    } else {
     
        //没有指纹验证 输入app 验证密码
            ZYLoginView *login = [ZYLoginView shareInstance];
            login.frame = CGRectMake(0, 0, self.view.width,self.view.height/2);
            login.delegate = self;
            [self.view addSubview:login];
    }
    
}

#pragma mark - 验证代理
- (void)isLoginPass
{
    if ([ZYAccount shareInstance].isLogin) {
        [[ZYLoginView shareInstance] loginViewMoveToPoint:CGPointMake(0,-self.view.height/2) andSussec:^{
            [self.tableView reloadData];
            [MBProgressHUD showText:@"验证成功" toView:self.view];
        }];
    }else{
        [MBProgressHUD showText:@"验证失败" toView:self.view];
    }
}

#pragma mark - cell的代理
- (void)swipDowithindex:(NSInteger)index
{
    for (NSInteger i = 0;i<self.allNote.count; i++) {
        ZYNoteCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i != index && cell.backImg.frame.origin.x>0) {
            [UIView animateWithDuration:0.2 animations:^{
                cell.backImg.origin = CGPointMake(0,cell.backImg.origin.y);
                cell.nailImg.image =[UIImage imageNamed:@"clip_n"];
                cell.deleteBtn.enabled = NO;
            }];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([ZYAccount shareInstance].isLogin) {
        return self.allNote.count;
    }
    return self.haveNote.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MynoteModel *note ;
    //是否验证过了
    if ([ZYAccount shareInstance].isLogin) {
       note  = self.allNote[indexPath.row];
    }else
        note = self.haveNote[indexPath.row];
        
   //是否有图片
    BOOL ishave;
    NSString *ID = @"NOTE";
    if (note.imageName != nil) {
        ishave = YES;
        ID = @"IMAGE";
    }else
        ishave = NO;
    ZYNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[ZYNoteCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID andInteger:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    [cell buildNotewithindex:indexPath.row and:ishave];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ %@",[self intervalSinceNow:note.trueTime],note.time];
    cell.titleLabel.text = note.text;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击的时候 遍历cell  恢复 位置
   __block BOOL isReturn = NO;
    [self.allNote enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZYNoteCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        if (cell.backImg.frame.origin.x>0) {
            [self recoverCellPosition:idx];
            *stop = YES;
            isReturn = YES;
        }
    }];
    if (isReturn) {
        return;
    }
    //进入编辑界面
    ZYEditViewController *edit = [[ZYEditViewController alloc] init];
    edit.type = kEditTypechange;
    if ([ZYAccount shareInstance].isLogin) {
        edit.note = self.allNote[indexPath.row];
    }else{
        edit.note = self.haveNote[indexPath.row];
    }
    
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - 恢复cell 的位置
- (void)recoverCellPosition:(NSInteger)index
{
    ZYNoteCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [UIView animateWithDuration:kDuration animations:^{
        cell.backImg.origin = CGPointMake(0,cell.backImg.origin.y);
        cell.deleteBtn.enabled = NO;
    } completion:^(BOOL finished) {
        cell.nailImg.image =[UIImage imageNamed:@"clip_n"];
    }];
 
}

- (void)deleteCellwithindex:(NSInteger)index
{
    //恢复 cell 的位置
    [self recoverCellPosition:index];
    //删除
    MynoteModel *note;
    if ([ZYAccount shareInstance].isLogin) {
        note = self.allNote[index];
    }else{
        note = self.haveNote[index];
    }
    //数据库的删除
    [self.myDelegate.managedObjectContext deleteObject:note];
    if ([ZYAccount shareInstance].isLogin) {
        [self.allNote removeObject:note];
    }else
        [self.haveNote removeObject:note];
    //tableView 的删除
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationLeft];
    [self.myDelegate saveContext];
    [self.tableView reloadData];
}

#pragma mark - 距离现在的时间
- (NSString *)intervalSinceNow: (NSString *) theDate
{
//    NSArray *timeArray=[theDate componentsSeparatedByString:@"."];
//    theDate=[timeArray objectAtIndex:0];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
   
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    //如果是昨天
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"];
    [dateformatter setDateFormat:@"dd"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    NSString *old = [dateformatter stringFromDate:d];

    
    if (cha/86400>2)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
        
    }else if([locationString intValue]>[old intValue]){
        timeString = @"昨天";
    }else
    {
        timeString = @"今天";
    }
   
    return timeString;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self findAllNote];
}
@end
