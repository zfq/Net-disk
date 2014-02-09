//
//  FQMenuViewController.m
//  Cloud
//
//  Created by zzti on 13-11-14.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "FQMenuViewController.h"
#import "IrregularView.h"
@interface FQMenuViewController ()

@end

@implementation FQMenuViewController
@synthesize delegate = _delegate;
@synthesize menuViewFrame;
@synthesize menuViewIsTapped;
@synthesize menuView = _menuView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:self.menuViewFrame];
    self.view = view;
}

#pragma mark 自定义视图形状
- (IrregularView *)customInitIrregularView
{
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight =  self.view.frame.size.height;
    IrregularView *mView = [[IrregularView alloc] initWithFrame:CGRectMake(0, 0, viewWidth,viewHeight)];
    [self.view addSubview:mView];
    mView.trackPoints = [NSMutableArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(25.0, 0)],
                         [NSValue valueWithCGPoint:CGPointMake(25.0, 15.0)],
                         [NSValue valueWithCGPoint:CGPointMake(0, 15.0)],
                         [NSValue valueWithCGPoint:CGPointMake(0, viewHeight)],
                         [NSValue valueWithCGPoint:CGPointMake(viewWidth, viewHeight)],
                         [NSValue valueWithCGPoint:CGPointMake(viewWidth, 15.0)],
                         [NSValue valueWithCGPoint:CGPointMake(40.0, 15.0)],nil];
    [mView setCornerRadius:5.0];
    [mView setBorderWidth:1.5];
    [mView setBackgroundColor:[UIColor whiteColor]];
    mView.borderColor  = [UIColor grayColor];
    [mView setMask];
    
    return mView;
}

- (UIButton *)customButton:(CGFloat)width withHeight:(CGFloat)height withNormalImge:(UIImage *)normalImage withPressedImage:(UIImage *)pressedImage
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *stretchableImageNormal = [normalImage stretchableImageWithLeftCapWidth:width topCapHeight:height];
    [btn setBackgroundImage:stretchableImageNormal forState:UIControlStateNormal];
    
    UIImage *stretchableImagePressed = [pressedImage stretchableImageWithLeftCapWidth:width topCapHeight:height];
    [btn setBackgroundImage:stretchableImagePressed forState:UIControlStateHighlighted];
    return btn;
}

#pragma mark 为”我的文件“的menuView添加内容
- (void)addMyFileMenuViewContent:(IrregularView *)mView;
{
    if (!mView) {
        mView = [self customInitIrregularView];
    }
    UIImage *normalImage = [UIImage imageNamed:@"layes.png"];
    UIImage *pressedImage = [UIImage imageNamed:@"folder.png"];
    
    UIButton *btnAll = [self customButton:30 withHeight:30 withNormalImge:normalImage withPressedImage:pressedImage];
    btnAll.frame = CGRectMake(10, 25, 30, 30);
    [btnAll addTarget:self action:@selector(btnShowAllTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mView addSubview:btnAll];
    
    UIButton *btnPhotos = [self customButton:30 withHeight:30 withNormalImge:normalImage withPressedImage:pressedImage];
    btnPhotos.frame = CGRectMake(55, 25, 30, 30);
    [btnPhotos addTarget:self action:@selector(btnShowPhotosTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mView addSubview:btnPhotos];
    
    UIButton *btnVideos = [self customButton:30 withHeight:30 withNormalImge:normalImage withPressedImage:pressedImage];
    btnVideos.frame = CGRectMake(100, 25, 30, 30);
    [btnVideos addTarget:self action:@selector(btnShowVideosTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mView addSubview:btnVideos];
    
    UIButton *btnDocuments = [self customButton:30 withHeight:30 withNormalImge:normalImage withPressedImage:pressedImage];
    btnDocuments.frame = CGRectMake(145, 25, 30, 30);
    [btnDocuments addTarget:self action:@selector(btnShowDocumentsTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mView addSubview:btnDocuments];
}

- (void)addMyFileMenuViewContent
{
    [self addMyFileMenuViewContent:_menuView];
}

- (void)addUploadViewContent:(IrregularView *)mView
{
    if (!mView) {
        mView = [self customInitIrregularView];
    }
    
    UIImage *normalImage = [UIImage imageNamed:@"picture.png"];
    UIImage *pressedImage = [UIImage imageNamed:@"pictureBgd.png"];
    
    UIButton *btnPicture = [self customButton:64 withHeight:64 withNormalImge:normalImage withPressedImage:pressedImage];
    btnPicture.frame = CGRectMake(20, 25, 64, 64);
    [btnPicture addTarget:self action:@selector(btnPhotosTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *lPString = @"照片";
    UILabel *lP = [[UILabel alloc] init];
    CGSize lPSize = [lPString sizeWithFont:lP.font];
    lP.frame = CGRectMake(35, 90, lPSize.width, lPSize.height);
    lP.text = lPString;
    [mView addSubview:btnPicture];
    [mView addSubview:lP];
    
    
    UIImage *normalMovieImage = [UIImage imageNamed:@"movie.png"];
    UIImage *pressedMovieImage = [UIImage imageNamed:@"movieBgd.png"];
    
    UIButton *btnMovie = [self customButton:64 withHeight:64 withNormalImge:normalMovieImage withPressedImage:pressedMovieImage];
    btnMovie.frame = CGRectMake(105, 25, 64, 64);
    [btnMovie addTarget:self action:@selector(btnVideosTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *lMString = @"视频";
    UILabel *lM = [[UILabel alloc] init];
    CGSize lMSize = [lMString sizeWithFont:lM.font];
    lM.frame = CGRectMake(120, 90, lMSize.width, lMSize.height);
    lM.text = lMString;
    [mView addSubview:lM];
    [mView addSubview:btnMovie];
    
    UIImage *normalContactImage = [UIImage imageNamed:@"contact_card.png"];
    UIImage *pressedContactImage = [UIImage imageNamed:@"contact_cardBgd.png"];
    
    UIButton *btnContact = [self customButton:64 withHeight:64 withNormalImge:normalContactImage withPressedImage:pressedContactImage];
    btnContact.frame = CGRectMake(200, 25, 64, 64);
    [btnContact addTarget:self action:@selector(btnContactTapped:) forControlEvents:UIControlEventTouchUpInside];
   
    NSString *lCString = @"通讯录同步";
    UILabel *lC = [[UILabel alloc] init];
    CGSize lCSize = [lCString sizeWithFont:lC.font];
    lC.frame = CGRectMake(190, 90, lCSize.width, lCSize.height);
    lC.text = lCString;
    
    [mView addSubview:btnContact];
    [mView addSubview:lC];
}

- (void)addUploadViewContent
{
    [self addUploadViewContent:_menuView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuViewIsTapped = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tapIsInMenuView:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:tapGesture.view];
    
    if ([_menuView.tempPath containsPoint:tapPoint]){
        [_delegate menuViewControllerIsVisible:self];
        self.menuViewIsTapped = YES;
        return YES;
    }
    
    return NO;
}

- (void)showMenuViewInRect:(CGRect) senderRect
{
    UIView *subView = (UIView *)_menuView;
    [self.view addSubview:subView];
}

#pragma mark - 我的文件页面按钮
- (void)btnShowAllTapped:(id)sender
{
    [_delegate menuViewControllerIsVisible:self];
    NSLog(@"btnAll1");
}

#pragma mark - 上传页面按钮
- (void)btnPhotosTapped:(id)sender
{
    [_delegate tapPhoto:self];
}

- (void)btnVideosTapped:(id)sender
{
    [_delegate tapVideo:self];
}

- (void)btnDocumentsTapped:(id)sender
{
    [_delegate menuViewControllerIsVisible:self];
    NSLog(@"btnAll4");
}

- (void)btnContactTapped:(id)sender
{
     [_delegate menuViewControllerIsVisible:self];
}
@end

















