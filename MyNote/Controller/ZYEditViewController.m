//
//  ZYEditViewController.m
//  MyNote
//
//  Created by zhuyongqing on 15/10/20.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//

#import "ZYEditViewController.h"

#import "AppDelegate.h"
#import "UIView+ITTAdditions.h"
#import "UIColor+UIColor_Hex.h"
#import "MBProgressHUD+Add.h"
#define kwinY 64
#define kBtnW 40
#define kBtnH 30
// 分割线，占位字的灰色
#define kBaseGrayColor [UIColor colorWithHexString: @"dddddd"]
// 基本的文字颜色
#define kBaseTextColor [UIColor colorWithHexString: @"626466"]

#define kRGBcolor(red,g,b) [UIColor colorWithRed:red/255.0 green:g/255.0 blue:b/255.0 alpha:1]
@interface ZYEditViewController ()<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIView *topView;
    
    UIView *editView;
    
    UIImage *photo;
}
/**
 *  托管代理
 */
@property(nonatomic,strong) AppDelegate *myDelegate;
/**
 *  新的note
 */
@property(nonatomic,strong) MynoteModel *noteModel;
/**
 *  时间的label
 */
@property(nonatomic,strong) UILabel *timeLabel;
/**
 *  note text
 */
@property(nonatomic,strong) UITextView *textView;
/**
 *  右上角的btn
 */
@property(nonatomic,strong) UIButton *imgBtn;

@property(nonatomic,strong) UIButton *saveBtn;



/**
 *  状态
 */
@property(nonatomic,assign) BOOL editState;

/**
 *  是否是删除
 */
@property(nonatomic,assign) BOOL isDelete;

/**
 *  是否是选择照片
 */
@property(nonatomic,assign) BOOL isPicker;

@end

@implementation ZYEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //默认状态
    _editState = NO;
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_bg"]];
    img.frame = self.view.bounds;
    img.contentMode = UIViewContentModeScaleAspectFill;
    img.clipsToBounds = YES;
    [self.view addSubview:img];
    //得到应用程序代理类对象
    self.myDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //创建视图
    [self setTopView];
    //创建导航栏
    [self buildNaviBar];
   
}

- (MynoteModel *)noteModel
{
    if (!_noteModel) {
        //创建一个新的Student托管对象 在托管对象上下文中
        _noteModel = [NSEntityDescription insertNewObjectForEntityForName:@"MynoteModel" inManagedObjectContext:self.myDelegate.managedObjectContext];
    }
    return _noteModel;
}

#pragma mark - 创建视图

- (void)setTopView
{
    topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, kwinY, self.view.frame.size.width, self.view.height);
    [self.view addSubview:topView];
    //时间
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width-100, kBtnW)];
    self.timeLabel.textColor = kRGBcolor(183, 166, 143);
    self.timeLabel.text = [NSString stringWithFormat:@"今天 %@",[self retureNowdate:0]];
    self.timeLabel.font =[UIFont systemFontOfSize:13];
    //背景图
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note_paper_background_full"]];
    img.frame = CGRectMake(0, 0,topView.frame.size.width, topView.frame.size.height);
    img.contentMode = UIViewContentModeScaleAspectFill;
    img.userInteractionEnabled = YES;
    img.clipsToBounds = YES;
    [img addSubview:self.timeLabel];
    
    //分割线
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.timeLabel.bottom-1, self.view.width,1)];
    view.backgroundColor = kBaseGrayColor;
    [img addSubview:view];
    //内容
    self.textView = [[UITextView alloc] init];
    self.textView.frame = CGRectMake(0,self.timeLabel.bottom, topView.width,topView.height-self.timeLabel.height);
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.textColor = kRGBcolor(93,56,42);
    self.textView.delegate = self;
    self.textView.selectedRange=NSMakeRange(self.textView.text.length,0);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollEnabled = YES;
    //加上右滑删除的手势
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwip)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.textView addGestureRecognizer:right];
    [img addSubview:self.textView];
    if (_type == kEditTypechange) {
        self.textView.text = self.note.text;
        //显示时间
        self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",[self intervalSinceNow:self.note.trueTime],self.note.time];
        //如果有图 设置图片
        if (self.note.imageName != nil) {
            [self setImge];
        }
    }
    [topView addSubview:img];
}

#pragma mark - 设置右滑手势 返回上一级
- (void)rightSwip
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 设置图片
- (void)setImge
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        photo = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:self.note.imageName options:NSDataBase64DecodingIgnoreUnknownCharacters]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoImg.image = photo;
        });
    });
}

#pragma mark - 双击图片变大
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 2 && [touch.view isEqual:self.photoImg]) {
     
       // [self.photoImg setFrame:CGRectMake(10,100,self.view.width-20,400)];
        
    }
}

#pragma mark - 获取当前时间
- (NSString *)retureNowdate:(int)type
{
    //获取当前时间
    NSDate *senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"];
    if (type==0) {
         [dateformatter setDateFormat:@"HH:mm YYYY年MM月dd日"];
    } else
         [dateformatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    return locationString;
}

#pragma mark - 计算距离现在的时间
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


#pragma mark - textview 代理方法

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _editState = YES;
  
    [self setBtnImg:1];
}

#pragma mark - 设置btn 的图片
- (void)setBtnImg:(int)type
{
    //根据编辑的状态 改变 导航栏的按钮
    if (type==1) {
        //编辑状态
        [self.imgBtn setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
        [self.imgBtn setImage:[UIImage imageNamed:@"btn_camera"] forState:UIControlStateNormal];
        self.imgBtn.size = CGSizeMake(kBtnW-3, kBtnW+3);
        
        [self.saveBtn setImage:[UIImage imageNamed:@"btn_done"] forState:UIControlStateNormal];
    }else
    {
        //非编辑状态
        [self.imgBtn setBackgroundImage:[UIImage imageNamed:@"iOSbtnBg"] forState:UIControlStateNormal];
        [self.imgBtn setImage:[UIImage imageNamed:@"iOSbtn_0001"] forState:UIControlStateNormal];
        self.imgBtn.size = CGSizeMake(kBtnW, kBtnH);
        [self.saveBtn setImage:[UIImage imageNamed:@"btn_send"] forState:UIControlStateNormal];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!_isPicker) {
       [self save];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_type == kEditTypenew) {
         [self.textView becomeFirstResponder];
    }
   
    _isDelete = NO;
    _isPicker = NO;
}

#pragma mark - 保存
- (void)save
{
    if (_type == kEditTypenew) {
        //如果是创建新的
      
        if ((![self.noteModel.text isEqualToString:self.textView.text] && ![self.textView.text isEqualToString:@""]&&!_isDelete)||(self.photoImg.image!=nil&&!_isDelete)) {
            self.noteModel.text = self.textView.text;
            self.noteModel.time = [self retureNowdate:0];
            self.noteModel.trueTime = [self retureNowdate:1];
                if (self.photoImg.image != nil) {
                    [self saveImg:1];
                }
            [self.myDelegate saveContext];
        }else{
            if ([self.textView.text isEqualToString:@""]) {
                //如果是空的 就不创建
                [self.myDelegate.managedObjectContext deleteObject:self.noteModel];
            }
        }
    }else if(_type == kEditTypechange){
        //修改 查看 旧的
        if ((![self.note.text isEqualToString:self.textView.text] && ![self.textView.text isEqualToString:@""]&&!_isDelete)||(self.photoImg.image != nil && ![self.photoImg.image isEqual:photo]&&!_isDelete)) {
            //当前的内容
            self.note.text = self.textView.text;
            //把当前的时间
            self.note.time = [self retureNowdate:0];
            //刷新界面显示的时间
            self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",[self intervalSinceNow:[self retureNowdate:1]],[self retureNowdate:0]];
            //排序 计算的时间
            self.note.trueTime = [self retureNowdate:1];
            if (self.photoImg.image != nil) {
                [self saveImg:0];
            }
            [self.myDelegate saveContext];
        }else{
            
        }
    }
}

#pragma mark - 把图片转换成string
- (void)saveImg:(int)type
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        NSData *data;
        if (UIImagePNGRepresentation(self.photoImg.image) == nil)
        {
            data = UIImageJPEGRepresentation(self.photoImg.image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(self.photoImg.image);
        }
        NSString *str;
        str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        if (type == 0) {
            self.note.imageName = str;
        }else
            self.noteModel.imageName = str;
    });
}

#pragma mark - 创建导航栏

- (void)buildNaviBar
{
    //左上角
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"btn_long_bg_n"] forState:UIControlStateNormal];
    [leftBtn setTitle:@"列表" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setFrame:CGRectMake(0, 0, 50, kBtnW)];
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [leftBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    //右上角
    self.imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imgBtn setFrame:CGRectMake(0, 0, kBtnW,kBtnH)];
    
    [self.imgBtn addTarget:self action:@selector(deleteNote) forControlEvents:UIControlEventTouchUpInside];
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveBtn setFrame:CGRectMake(0, 0, kBtnW-3, kBtnW+3)];
    [self.saveBtn setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
    [self setBtnImg:0];
    [self.saveBtn addTarget:self action:@selector(saveNote) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.saveBtn],[[UIBarButtonItem alloc] initWithCustomView:self.imgBtn]];
}

#pragma mark - 删除 或者添加图片
- (void)deleteNote
{
    if (!_editState) {
        //如果不是编辑状态 删除
        _isDelete = YES;
        if (_type == kEditTypechange) {
            [self.myDelegate.managedObjectContext deleteObject:self.note];
        }else{
            [self.myDelegate.managedObjectContext deleteObject:self.noteModel];
        }
         [self.myDelegate saveContext];
        self.imgBtn.imageView.animationImages = [self deleteAnimation];
        self.imgBtn.imageView.animationDuration = 0.6;
        [self.imgBtn.imageView startAnimating];
        
        //删除的donghua
        [UIView animateWithDuration:0.4 animations:^{
            topView.transform = CGAffineTransformMakeScale(0.06, 0.06);
            [self.imgBtn.imageView stopAnimating];
            [self.imgBtn setImage:[UIImage imageNamed:@"iOSbtn_0030"] forState:UIControlStateNormal];
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                topView.origin = CGPointMake(self.view.width-90,20);
            } completion:^(BOOL finished) {
                
              [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }else
    {
        [self.textView resignFirstResponder];
                  //在这里呼出下方菜单按钮项
           UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:@"取消"
                             destructiveButtonTitle:nil
                             otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
            [myActionSheet showInView:self.view];
        
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        NSLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            _isPicker = YES;
            break;
            
        case 1:  //打开本地相册
            [self LocalPhoto];
            _isPicker = YES;
            break;
    }
}

#pragma mark - 开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
    
}

#pragma mark - 打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}
#pragma mark - 当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
       
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
//        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//        
//        //文件管理器
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
//        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
//        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        
        //得到选择后沙盒中图片的完整路径
        //filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:^{
            _isPicker = NO;
        }];
        
        //创建一个选择后图片的小图标放在下方
        //类似微薄选择图后的效果
  
       // UIImage *scaleImg = [self scaleToSize:image size:CGSizeMake(self.photoImg.width,400)];
        self.photoImg.image = image;
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 懒加载图片

- (UIImageView *)photoImg
{
    if (!_photoImg) {
        _photoImg = [[UIImageView alloc] init];
        _photoImg.frame = CGRectMake(20,100,self.view.width-40, 300);
       // _photoImg.clipsToBounds = YES;
        _photoImg.contentMode = UIViewContentModeScaleAspectFit;
        _photoImg.userInteractionEnabled = YES;
          //加在视图中
        [topView addSubview:self.photoImg];
    }
    return _photoImg;
}

#pragma mark - 改变图片的大小
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}


#pragma mark - 动画的图片
- (NSMutableArray *)deleteAnimation
{
    NSMutableArray *imgs = [NSMutableArray array];
    for (int i = 1; i<=30; i++) {
        NSString *imgname;
        if (i<10) {
           imgname = [NSString stringWithFormat:@"iOSbtn_000%i.png",i];
        }else
        {
            imgname = [NSString stringWithFormat:@"iOSbtn_00%i.png",i];
        }
        UIImage *img = [UIImage imageNamed:imgname];
        [imgs addObject:img];
    }
    return imgs;
}

#pragma mark - 保存 或者 分享

- (void)saveNote
{
    if (_editState) {
        [self setBtnImg:0];
         [self save];
         [self.textView resignFirstResponder];
         _editState = NO;
    }else{
        //设为验证才能查看
        if (self.type == kEditTypechange) {
            self.note.isHaveLogin = @"1";
        }else
        {
            self.noteModel.isHaveLogin = @"1";
        }
        [self.myDelegate saveContext];
        
        [MBProgressHUD showText:@"已设为需要验证查看" toView:self.view];
    }
}

#pragma mark - 导航栏左侧按钮的点击

- (void)leftBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
