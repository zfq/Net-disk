//
//  PhotoBrowser.m
//
//
//  Created by zhaofuqiang on 13-8-24.
//  Copyright (c) 2013 zhaofuqiang. All rights reserved.
//

#import "PhotoBrowser.h"
#import "MBProgressHUD.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define IOS7_SDK_AVAILABLE 1
#endif

@interface PhotoBrowser ()<UIActionSheetDelegate>
{
    BOOL shouldHideStatusBar;
    
	NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    
    MBProgressHUD *HUD;
    
    UIToolbar *_toolBar;
}

- (void)changePhotoView;
- (void)showPhotoViewAtIndex:(NSUInteger)index;
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index;
- (void)toggleFullScreen;
- (void)hideTabBar;
- (NSArray *)customToolbarItems;
@end

@implementation PhotoBrowser

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self hideTabBar:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent]; //ios6需要使stausbar初始为透明
     self.wantsFullScreenLayout = YES;
    
    [self setNavBarAppearance:NO];

    shouldHideStatusBar = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    if (_photoArray.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    [self createScrollView];

    [self.view addSubview:_mainScrollView];
    self.title = [NSString stringWithFormat:@"%i/%i",_currentPhotoIndex+1,_photoArray.count];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault; //这个不能少
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self hideTabBar:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
	_mainScrollView = [[UIScrollView alloc] initWithFrame:frame];
	_mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_mainScrollView.pagingEnabled = YES;
	_mainScrollView.delegate = self;
	_mainScrollView.showsHorizontalScrollIndicator = NO;
	_mainScrollView.showsVerticalScrollIndicator = NO;
	_mainScrollView.backgroundColor = [UIColor blackColor];
    _mainScrollView.contentSize = CGSizeMake(frame.size.width * _photoArray.count, 0);
    _mainScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
}

- (void)changePhotoView
{
    if (_photoArray.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _mainScrollView.bounds;
	int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
	int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photoArray.count) firstIndex = _photoArray.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photoArray.count) lastIndex = _photoArray.count - 1;

   
    NSInteger photoViewIndex;
	for (PhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = (photoView.tag - kPhotoViewTagOffset);
		if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
			[_reusablePhotoViews addObject:photoView];
			[photoView removeFromSuperview];
		}
	}
 
	[_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }

    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
		if (![self isShowingPhotoViewAtIndex:index]) {
			[self showPhotoViewAtIndex:index];
           
		}
	}
}

#pragma mark 显示当前图片
- (void)showPhotoViewFromCurrentIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
        
    if ([self isViewLoaded]) {
        _mainScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _mainScrollView.frame.size.width, 0);
        
        [self changePhotoView];
    }
}

#pragma mark 从srollView中删除照片
- (void)deleteCurrentPhotoViewFromScrollView
{
    for (PhotoView *photoView in _visiblePhotoViews) {
        if (photoView.imageView.image) {
            // [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    
    if (_photoArray.count>0)
    {
        if (_photoArray.count==1) //如果只有一个就关闭PhotoBrowzer
        {
            //关闭PhotoBrowzer
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (_currentPhotoIndex == _photoArray.count-1) //如果是最后一个就显示前一个
        {
            [_photoArray removeObjectAtIndex:_currentPhotoIndex];
            _mainScrollView.contentSize = CGSizeMake(frame.size.width * _photoArray.count, 0);
            [self showPhotoViewAtIndex:_currentPhotoIndex];
            self.title = [NSString stringWithFormat:@"%i/%i",_currentPhotoIndex+1,_photoArray.count];
            
        }else if(_currentPhotoIndex < _photoArray.count-1) //如果不是最后一个就显示下一个
        {
            [_photoArray removeObjectAtIndex:_currentPhotoIndex];
            _mainScrollView.contentSize = CGSizeMake(frame.size.width * _photoArray.count, 0);
            [self showPhotoViewAtIndex:_currentPhotoIndex];
            self.title = [NSString stringWithFormat:@"%i/%i",_currentPhotoIndex+1,_photoArray.count];
        }
    }
}

#pragma mark 显示第几个照片

- (void)showPhotoViewAtIndex:(NSUInteger)index
{
    PhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {
        photoView = [[PhotoView alloc] initImageScrollViewWithFrame:self.view.frame imageName:@""];
        photoView.tapDelegate = self;
    }
    
    CGRect bounds = _mainScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index)+ kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    photoView.frame = photoViewFrame;
   
    [photoView reloadImageViewWithName:[_photoArray objectAtIndex:index]];
    [_visiblePhotoViews addObject:photoView];
    [_mainScrollView addSubview:photoView];
}

- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index
{
	for (PhotoView *photoView in _visiblePhotoViews) {
		if ((photoView.tag - kPhotoViewTagOffset) == index) {
            return YES;
        }
    }
	return  NO;
}

- (PhotoView *)dequeueReusablePhotoView
{
    PhotoView *photoView = [_reusablePhotoViews anyObject];
	if (photoView) {
		[_reusablePhotoViews removeObject:photoView];
	}
    photoView.zoomScale = 1.0; 
	return photoView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self changePhotoView];
     _currentPhotoIndex = _mainScrollView.contentOffset.x / _mainScrollView.frame.size.width;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.title = [NSString stringWithFormat:@"%i/%i",_currentPhotoIndex+1,_photoArray.count];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tapGesture
{
    [self toggleFullScreen];
}

#pragma mark - 设置导航栏透明
- (void)setNavBarAppearance:(BOOL)animated
{
    
    self.navigationController.navigationBar.tintColor = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = YES;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
}

- (void)toggleFullScreen
{
    if (self.navigationController.navigationBar.alpha == 0.0) {
        // 显示导航栏和状态栏
        [UIView animateWithDuration:0.4 animations:^{
            shouldHideStatusBar = NO;
            [self showStatusBar];
            self.navigationController.navigationBar.alpha = 1.0;
            _toolBar.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }else {
        // 隐藏导航栏和状态栏
            [UIView animateWithDuration:0.4 animations:^{
            shouldHideStatusBar = YES;
            [self hideStatusBar];
            self.navigationController.navigationBar.alpha = 0.0;
            _toolBar.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark 创建工具栏
- (NSArray *)customToolbarItems
{
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
     UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *airDropBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [airDropBtn setImage:[UIImage imageNamed:@"airDrop1.png"] forState:UIControlStateNormal];
    [airDropBtn addTarget:self action:@selector(shareFileByAirDrop:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *airDropBI = [[UIBarButtonItem alloc] initWithCustomView:airDropBtn];
                                      
    UIButton *downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [downloadBtn setImage:[UIImage imageNamed:@"download1.png"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadFile:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *downloadBI = [[UIBarButtonItem alloc] initWithCustomView:downloadBtn];
    
    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [shareBtn setImage:[UIImage imageNamed:@"share1.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareFile:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareBI = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [deleteBtn setImage:[UIImage imageNamed:@"delete1.png"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteFile:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteBI = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
                                 
    return @[ flex1,airDropBI, flex2,downloadBI, flex4,shareBI,flex5,deleteBI,flex6];
}

#pragma mark airDrop分享
- (void)shareFileByAirDrop:(id)sender
{
    UIImage *currentImage = [UIImage imageNamed:[_photoArray objectAtIndex:_currentPhotoIndex]];
    NSArray *objectsToShare = [NSArray arrayWithObject:currentImage];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypeAssignToContact,UIActivityTypeCopyToPasteboard,
                                    UIActivityTypePrint];
    controller.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark 保存
- (void)downloadFile:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到本地相册", nil];
    actionSheet.tag = 1000;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark 显示提示框
- (void)createHUD
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
}

- (void)showHUDWithImage:(UIImage *)image messege:(NSString *)string
{
    if (HUD==nil) 
        return;
    HUD.customView = [[UIImageView alloc] initWithImage:image];
    HUD.labelText = string;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo;
{
   [self createHUD];
    UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/success.png"];
    
    if (error != NULL) {
        [self showHUDWithImage:img messege:@"照片保存失败"];
    }else{
        [self showHUDWithImage:img messege:@"照片保存成功"];
    };
}

#pragma mark 分享
- (void)shareFile:(id)sender
{
    UIActionSheet *shareList = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:
                                @"复制链接", @"短信分享",@"邮件分享",
                                @"分享到新浪微博",@"分享到腾讯微博",
                                @"分享到QQ空间",@"分享给微信好友",@"分享到微信朋友圈",
                                nil];
    shareList.tag = 1001;
    [shareList showFromToolbar:self.navigationController.toolbar];
}

#pragma mark 删除
- (void)deleteFile:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"在回收站找回删除的文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
    actionSheet.tag = 1002;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1000)
    {
        if (buttonIndex == 0) {
            NSString *imgName = [_photoArray objectAtIndex:_currentPhotoIndex];
            UIImage *currentImage = [UIImage imageNamed:imgName];
            UIImageWriteToSavedPhotosAlbum(currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    else if(actionSheet.tag == 1001)
    {
        switch (buttonIndex) {
            case 0:
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = @"URL";
                [self createHUD];
                [self showHUDWithImage:[UIImage imageNamed:@"MBProgressHUD.bundle/success.png"] messege:@"链接已复制"];
                break;
            }
            default: break;
        }
    }
    else if(actionSheet.tag == 1002)
    {
        if (buttonIndex == 0) {
            [self deleteCurrentPhotoViewFromScrollView];
        }
    }
}

#pragma mark 隐藏和显示TabBar
- (void)hideTabBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	float fHeight = screenRect.size.height;

    for (UIView *view in self.tabBarController.view.subviews) {
        if (view == self.tabBarController.tabBar) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)showTabBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	float fHeight = screenRect.size.height - 49.0;
    
	if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ) {
		fHeight = screenRect.size.width - 49.0;
	}
    
    for (UIView *view in self.tabBarController.view.subviews) {
        if (view == self.tabBarController.tabBar) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
}

- (void) hideTabBar:(BOOL) hidden{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	float fHeight = screenRect.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight-49, view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
                //添加toolBar
                _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,fHeight-49,screenRect.size.width,49)];
                _toolBar.items = [self customToolbarItems];
                _toolBar.translucent = YES;
                _toolBar.tintColor = [UIColor clearColor];
                [view addSubview:_toolBar];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
                [_toolBar removeFromSuperview];
                _toolBar = nil;
            }
        }
    }
    [UIView commitAnimations];
}

#pragma mark 隐藏和显示状态栏
- (void)hideStatusBar
{
   
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) { //ios7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)showStatusBar
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) { //ios7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
#ifdef IOS7_SDK_AVAILABLE
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; //ios6
#endif
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent]; //ios7
    }
}

/*
- (BOOL)prefersStatusBarHidden //ios7下暂不隐藏状态栏
{
    if (!shouldHideStatusBar)
        return NO;  //不隐藏
    else
        return YES; //隐藏
}
*/
@end








