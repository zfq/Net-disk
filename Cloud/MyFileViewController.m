//
//  MyFileViewController.m
//  Cloud
//
//  Created by zzti on 13-11-12.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "MyFileViewController.h"
#import "SearchBarCell.h"
#import "MainContentCell.h"
#import "SetMainContentCell.h"
#import "SetFolderCell.h"
#import "MainContentItem.h"
#import "MyFileItemStore.h"
#import "DownloadItemStore.h"
#import "DownloadViewController.h"
#import "PhotoBrowser.h"
#import "Constant.h"
#import "TBXML.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "SSKeychain.h"

@interface MyFileViewController ()<UIActionSheetDelegate,UISearchBarDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    CGFloat _newFolderBtnOriginX;
    NSMutableURLRequest *_request;
    NSMutableData *_receiveData;
    BOOL _receivedNotificaion;
    BOOL _connIsFinished;
    MBProgressHUD *_HUD;
    
    Reachability *_internetReachability;
    Reachability *_wifiReachability;
}

@property (nonatomic) BOOL isUnfold;
@property (nonatomic,strong) NSIndexPath *selectIndex;
@property (nonatomic,strong) NSIndexPath *indexOfUnfold;
@property (nonatomic,strong) UIToolbar *toolBar;


- (void)stopLoading;
- (void)startLoading;

- (NSArray *)sortFilesByModDate: (NSString *)fullPath;
- (void)changeArrowDirectionForIndexPathofUnfold;
- (void)addTargetForSetMainContentCell:(SetMainContentCell *)cell;

- (void)setTableViewCellFold;//关闭折叠
- (void)hideTabBar;
- (void)showTabBar;
- (void)setAllBarItemsEnabledWithCount:(NSInteger)selectCount;
@end

@implementation MyFileViewController

@synthesize myFileTableView;
@synthesize searchDisplayController;
@synthesize refreshView;
@synthesize itemDictionaryStore;
//@synthesize itemSotre;
@synthesize currentPath;
@synthesize navTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        #ifdef IOS7_SDK_AVAILABLE
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        #endif
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
        self.isUnfold = NO;
        self.indexOfUnfold = nil;
        
        _receivedNotificaion = NO;
        _connIsFinished = NO;
    }
    return self;
}

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setExtraCellLineHidden:self.myFileTableView];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的文件" image:[UIImage imageNamed:@"cloud.png"] tag:0];
    self.tabBarItem = tabBarItem;
    
    if ([self.currentPath isEqualToString:ROOT_PATH]) {
        self.navigationItem.title = @"网盘"; //根据全部中选择可改为文档、图片 等等
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(showMenuView:withEvent:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
    } else {
        self.navigationItem.title = self.navTitle;
    }
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"多选" style:UIBarButtonItemStylePlain target:self action:@selector(mutableSelect:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFileList:) name:kLoginStatusChangedNotification object:nil];
    
    NSArray *nils = [[NSBundle mainBundle]loadNibNamed:@"RefreshView" owner:self options:nil];
    self.refreshView = [nils objectAtIndex:0];
    self.refreshView.frame = CGRectMake(0, -REFRESH_HEADER_HEIGHT, SCREEN_WIDTH, REFRESH_HEADER_HEIGHT);
    [self.myFileTableView insertSubview:refreshView atIndex:0];
    [self.refreshView.refreshIndicator stopAnimating];
    
    [self addNetworkStateNotification];
}

#pragma mark - 后台登陆成功 notification
- (void)getFileList:(NSNotification *)notification
{
    _receivedNotificaion = YES;
    [self startConnectionWithRequest:_request];
//
}

#pragma mark - 下拉刷新
// 停止，可以触发自己定义的停止方法
- (void)stopLoading
{
    // control
    refreshView.isLoading = NO;
    
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <7.0) {
        myFileTableView.contentInset = UIEdgeInsetsZero;
    } else {
        myFileTableView.contentInset = UIEdgeInsetsZero;
    }
    
    refreshView.refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
    
    // UI 更新日期计算
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
    [outFormat setDateFormat:@"MM'-'dd HH':'mm':'ss"];
    NSString *timeStr = [outFormat stringFromDate:nowDate];
    
    // UI 赋值
    refreshView.refreshLastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@", REFRESH_UPDATE_TIME_PREFIX, timeStr];
    refreshView.refreshStatusLabel.text = REFRESH_PULL_DOWN_STATUS;
    refreshView.refreshArrowImageView.hidden = NO;
    [refreshView.refreshIndicator stopAnimating];
}

- (void)refresh
{
    [self startLoading];
    _connIsFinished = NO;
    [self startConnectionWithRequest:_request];
}

// 开始，可以触发自己定义的开始方法
- (void)startLoading
{
    // control
    refreshView.isLoading = YES;
    
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    myFileTableView.contentOffset = CGPointMake(0, -REFRESH_HEADER_HEIGHT);
    myFileTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshView.refreshStatusLabel.text = REFRESH_LOADING_STATUS;
    refreshView.refreshArrowImageView.hidden = YES;
    [refreshView.refreshIndicator startAnimating];
    [UIView commitAnimations];
}

#pragma mark - UIScrollView
// 刚拖动的时候
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (refreshView.isLoading)
        return;
    refreshView.isDragging = YES;
}
// 拖动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (refreshView.isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (refreshView.isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshView.refreshStatusLabel.text = REFRESH_RELEASED_STATUS;
            refreshView.refreshArrowImageView.transform = CGAffineTransformMakeRotation(3.14);
        } else { // User is scrolling somewhere within the header
            refreshView.refreshStatusLabel.text = REFRESH_PULL_DOWN_STATUS;
            refreshView.refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
        }
        [UIView commitAnimations];
    }
}
// 拖动结束后
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (refreshView.isLoading)
        return;
    refreshView.isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        if (![self networkReachable]) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self createHUDWithCustomView];
            UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/error.png"];
            [self showHUDWithImage:img messege:@"当前网络不可用"];
        } else {
            [self refresh];
        }
    }
}

#pragma mark - 视图viewWillAppear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.navigationController setNavigationBarHidden:YES];
    [self.myFileTableView deselectRowAtIndexPath:[self.myFileTableView indexPathForSelectedRow] animated:YES];
    
    if (![self networkReachable]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self createHUDWithCustomView];
        UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/error.png"];
        [self showHUDWithImage:img messege:@"当前网络不可用"];
    }
    NSString *boolStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"succeedLogin"];
    if ([boolStr isEqualToString:@"YES"]) {  //在appdelegate中写入plist firstAppear = YES; 在后台login后改为NO;
        [self startConnectionWithRequest:_request];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (mvc) {
        [mvc.view removeFromSuperview];
        mvc = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    nfvc = nil;
    [self setRefreshView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginStatusChangedNotification object:nil];
}

#pragma mark - 弹出菜单(全部)
- (void)showMenuView:(id)sender withEvent:(UIEvent*)senderEvent
{
    if (mvc) {
        [self removeMenuView];
        return;
    }
    
    UIView *btnItemView = [[senderEvent.allTouches anyObject] view];
    mvc = [[FQMenuViewController alloc] init];
    mvc.delegate = self;
    CGRect rect = btnItemView.frame;
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    mvc.menuViewFrame = CGRectMake(rect.origin.x,rect.origin.y+rect.size.height+statusRect.size.height, 308, 130);
    
    [mvc addMyFileMenuViewContent];
    
    [self.navigationController.view addSubview:mvc.view];
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeMenuView)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)removeMenuView
{
    [mvc.view removeFromSuperview];
    mvc=nil;
    if (gestureRecognizer) {
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)menuViewControllerIsVisible:(FQMenuViewController *)fmvc
{
    if (fmvc)
        [self removeMenuView];
}

#pragma mark - 多选按钮点击事件及相关函数
- (void)mutableSelect:(id)sender
{
    if ([self.myFileTableView isEditing]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"多选"];
        [self.myFileTableView setEditing:NO animated:YES];
        if (self.toolBar != nil) {
            [self showTabBar];
        }
    } else {
        [sender setTitle:@"取消"];
        [self setTableViewCellFold]; //关闭折叠
        [self.myFileTableView setEditing:YES animated:YES];
        [self hideTabBar];
    }
}

- (void)recover
{
    [self.navigationItem.rightBarButtonItem setTitle:@"多选"];
    [self.myFileTableView setEditing:NO animated:YES];
    if (self.toolBar != nil) {
        [self showTabBar];
    }
}

#pragma mark 关闭折叠
- (void)setTableViewCellFold
{
    [self.myFileTableView beginUpdates];
    if (self.indexOfUnfold != nil) {
        [self.myFileTableView deleteRowsAtIndexPaths:@[self.indexOfUnfold] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self changeArrowDirectionForIndexPathofUnfold];
    self.indexOfUnfold = nil;
    self.isUnfold = NO;
    [self.myFileTableView endUpdates];
}

- (void)hideTabBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	float fHeight = screenRect.size.height;
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3];
    for (UIView *view in self.tabBarController.view.subviews) {
        if (view == self.tabBarController.tabBar) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor whiteColor];
         
            _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, fHeight-49, view.frame.size.width, 49)];
            UIBarButtonItem *downloadBi = [[UIBarButtonItem alloc] initWithTitle:@"下载" style:UIBarButtonItemStylePlain target:self action:@selector(downloadFile:)];
            downloadBi.enabled = NO;
            UIBarButtonItem *shareBi = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareFiles:)];
            shareBi.enabled = NO;
            UIBarButtonItem *moveBi = [[UIBarButtonItem alloc] initWithTitle:@"移动" style:UIBarButtonItemStylePlain target:self action:@selector(moveFiles:)];
            moveBi.enabled = NO;
            UIBarButtonItem *deleteBi = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteFile:)];
            deleteBi.enabled = NO;
            deleteBi.tintColor = [UIColor redColor];
            UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
            _toolBar.items = @[downloadBi,flexItem,shareBi,flexItem,moveBi,flexItem,deleteBi];
            [view addSubview:_toolBar];
        }
    }
    [UIView commitAnimations];
}

- (void)showTabBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	float fHeight = screenRect.size.height - 49.0;
    
	if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ) {
		fHeight = screenRect.size.width - 49.0;
	}
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    for (UIView *view in self.tabBarController.view.subviews) {
        if (view == self.tabBarController.tabBar) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            [_toolBar removeFromSuperview];
            _toolBar = nil;
        }
    }
    [UIView commitAnimations];
}

- (void)setAllBarItemsEnabledWithCount:(NSInteger)selectCount
{
    UIBarButtonItem *downloadBi = [_toolBar.items objectAtIndex:0];
    UIBarButtonItem *shareBi = [_toolBar.items objectAtIndex:2];
    UIBarButtonItem *moveBi = [_toolBar.items objectAtIndex:4];
    UIBarButtonItem *deleteBi = [_toolBar.items objectAtIndex:6];
    
    if (selectCount == 0) {
        downloadBi.enabled = NO;
        downloadBi.title = @"下载";
        shareBi.enabled = NO;
        shareBi.title = @"分享";
        moveBi.enabled = NO;
        moveBi.title = @"移动";
        deleteBi.enabled = NO;
        deleteBi.title = @"删除";
    } else {
        downloadBi.enabled = YES;
        downloadBi.title = [NSString stringWithFormat:@"下载(%i)",selectCount];
        shareBi.enabled = YES;
        shareBi.title = [NSString stringWithFormat:@"分享(%i)",selectCount];
        moveBi.enabled = YES;
        moveBi.title = [NSString stringWithFormat:@"移动(%i)",selectCount];
        deleteBi.enabled = YES;
        deleteBi.title = [NSString stringWithFormat:@"删除(%i)",selectCount];
    }
}

#pragma mark - 多选

- (void)shareFiles:(id)sender
{
    NSLog(@"share");
}

- (void)moveFiles:(id)sender
{
    NSLog(@"move");
}

#pragma mark -文件路径
- (MyFileViewController *)initWithDirectoryAtPath:(NSString *)dirPath
{
    self = [super init];
    
    if (self) {
//        self.itemSotre = [[MyFileItemStore alloc] init];
        self.itemDictionaryStore = [[NSMutableDictionary alloc] init];
        self.currentPath = dirPath;
//        [self rebuildFileList:self.currentPath];
    }
    
    return self;
}

-(NSArray *)sortFilesByModDate: (NSString *)fullPath
{
    NSError* error = nil;
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath
                                                                         error:&error];
    if(error == nil)
    {
        NSMutableDictionary* filesAndProperties = [NSMutableDictionary	dictionaryWithCapacity:[files count]];
        for(NSString* path in files)
        {
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:[fullPath stringByAppendingPathComponent:path]
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            
            if(error == nil)
            {
                [filesAndProperties setValue:modDate forKey:path];
            }
        }
        
        return [filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)];
        
    }
    
	return [NSArray arrayWithObjects:nil];
}

#pragma mark 新建文件夹
- (void)newFolder:(id)sender
{
//    if (!nfvc) {
//        nfvc = [[NewFolderViewController alloc] init];
//                nfvc.nDelegate = self;
//        
//    }
//    nfvc.folderImage = [UIImage imageNamed:@"mainFolder"];
    NewFolderViewController *vc = [[NewFolderViewController alloc] init];
    vc.operationType = kOperationTypeCreateDir;
    vc.nDelegate = self;
    vc.folderName.text = @"新建文件夹";
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - NewFolderViewController代理
- (void)cancelNewFolder:(NewFolderViewController *)newFolderViewController
{
    [newFolderViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)completeNewFolder:(NewFolderViewController *)newFolderViewController
{
    static NSInteger i = 1;
    NSString *itemName = newFolderViewController.folderName.text;
    MainContentItem *tempItem = [self.itemDictionaryStore objectForKey:itemName];
    while (tempItem !=nil ) {
        itemName = [itemName stringByAppendingFormat:@"(%i)",i++];
        tempItem = [self.itemDictionaryStore objectForKey:itemName];
    }

    if (newFolderViewController.operationType == kOperationTypeCreateDir) {     //新建文件夹
        [self createDirWithName:itemName];
        [newFolderViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {    //重命名
        MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:self.selectIndex.section-1];
        NSLog(@"%@",item.fileName);
        BOOL result = [self renameWithOriginalName:item.fileName NewName:itemName];
        if (result) {
             [newFolderViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    
}

- (void)createFolderWithName:(NSString *)folderName
{
    NSDate *currentDate = [NSDate date];
    MainContentItem *newItem = [[MyFileItemStore sharedItemStore] createFolderWithName:folderName date:currentDate folderPath:self.currentPath isDir:YES];
    [[MyFileItemStore sharedItemStore].allItems insertObject:newItem atIndex:0];
    [self.myFileTableView beginUpdates];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    [self.myFileTableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.myFileTableView endUpdates];
}

- (void)createDirWithName:(NSString *)folderName
{
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
    NSString *urlString = [NSString stringWithFormat:@"%@cndcreatdir.cgi?path=%@&name=%@&sid=%@",HOST_URL,self.currentPath,folderName,sid];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str1 = [urlString stringByAddingPercentEscapesUsingEncoding:enc];
   
    if (!_request) {
        _request = [[NSMutableURLRequest alloc] init];
        [_request setHTTPMethod:@"GET"];
        [_request setTimeoutInterval:30];
    }
    _request.URL = [NSURL URLWithString:str1];
    AFHTTPRequestOperation *requestOperaton = [[AFHTTPRequestOperation alloc] initWithRequest:_request];
    [requestOperaton setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseCreateDirResultWithData:operation.responseData name:folderName];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"创建文件夹失败:%@",[error localizedDescription]);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [requestOperaton start];
}

- (BOOL)renameWithOriginalName:(NSString *)originName NewName:(NSString *)newFileName
{
    __block BOOL result = NO;
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
    NSString *urlString = [NSString stringWithFormat:@"%@cndrename.cgi?path=%@&name=%@&newname=%@&sid=%@",HOST_URL,self.currentPath,originName,newFileName,sid];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str1 = [urlString stringByAddingPercentEscapesUsingEncoding:enc];
    
    if (!_request) {
        _request = [[NSMutableURLRequest alloc] init];
        [_request setHTTPMethod:@"GET"];
        [_request setTimeoutInterval:30];
    }
    _request.URL = [NSURL URLWithString:str1];
    AFHTTPRequestOperation *requestOperaton = [[AFHTTPRequestOperation alloc] initWithRequest:_request];
    [requestOperaton setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        result = [self parserRenameResultWithData:operation.responseData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"重命名失败:%@",[error localizedDescription]);
        result = NO;
    }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [requestOperaton start];
    return result;
}

- (void)parseCreateDirResultWithData:(NSData *)data name:(NSString *)folderName
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *dataString = [[NSString alloc] initWithData:data encoding:encoding];
    NSError *error = nil;
    TBXML *xml = [[TBXML alloc] initWithXMLString:dataString error:&error];
    if (error) {
        NSLog(@"解析文件错误:%@",[error localizedDescription]);
        return;
    }
    TBXMLElement *root = [xml rootXMLElement];
    TBXMLElement *deleteNode = [TBXML childElementNamed:@"Creatdir" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:deleteNode];
    NSString *errorNum = [NSString stringWithCString:statusNode->firstAttribute->value encoding:NSUTF8StringEncoding];
    if ([errorNum isEqualToString:@""]) {
        [self startConnectionWithRequest:_request];

    } else {
        if ([errorNum isEqualToString:@"02000005"])
            [self showHUDWithMessage:@"该文件夹已存在"];
        else if ([errorNum isEqualToString:@"020000020"])
            [self showHUDWithMessage:@"获取已使用空间失败"];
        else if ([errorNum isEqualToString:@"020000021"])
            [self showHUDWithMessage:@"没有足够空间"];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)parserRenameResultWithData:(NSData *)data
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *dataString = [[NSString alloc] initWithData:data encoding:encoding];
    NSError *error = nil;
    TBXML *xml = [[TBXML alloc] initWithXMLString:dataString error:&error];
    if (error) {
        NSLog(@"解析文件错误:%@",[error localizedDescription]);
        return NO;
    }
    TBXMLElement *root = [xml rootXMLElement];
    TBXMLElement *deleteNode = [TBXML childElementNamed:@"Rename" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:deleteNode];
    NSString *errorNum = [NSString stringWithCString:statusNode->firstAttribute->value encoding:NSUTF8StringEncoding];
    if ([errorNum isEqualToString:@""]) {
        [self startConnectionWithRequest:_request];
        return YES;
    } else {
        if ([errorNum isEqualToString:@"02000005"])
            [self showHUDWithMessage:@"该文件已存在"];
        else if ([errorNum isEqualToString:@"02000002E"])
            [self showHUDWithMessage:@"没有该文件"];
        else if ([errorNum isEqualToString:@"02000001E"])
            [self showHUDWithMessage:@"分享文件不能重命名"];
        return NO;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UISearchBar代理
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    SearchBarCell *cell = (SearchBarCell*)[self.myFileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    CGRect btnFrame = cell.newFolderButton.frame;
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];

    //移动searchBar
//    _newFolderBtnOriginX = btnFrame.origin.x;
//    cell.newFolderButton.frame = CGRectMake(_newFolderBtnOriginX-X_OFFSET, btnFrame.origin.y, btnFrame.size.width, btnFrame.size.height);
//    searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    
    [searchBar setShowsCancelButton:YES animated:NO];
   
    UIView *topView = searchBar.subviews[0];

    for (UIView *view in topView.subviews)
    {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
        } 
    }
    
    if (!self.searchDisplayController) {
        self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:cell.searchBar contentsController:self];
        self.searchDisplayController.searchResultsDelegate = self;
        self.searchDisplayController.searchResultsDataSource = self;
        self.searchDisplayController.delegate = self;
        [self.searchDisplayController setActive:YES animated:YES];
    }

    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    [self.navigationController setNavigationBarHidden:NO animated:YES];

//    SearchBarCell *cell = (SearchBarCell*)[self.myFileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    CGRect btnFrame = cell.newFolderButton.frame;
//    
//    searchBar.frame = CGRectMake(X_OFFSET, 0,SCREEN_WIDTH-X_OFFSET, 44);
//    cell.newFolderButton.frame = CGRectMake(_newFolderBtnOriginX, btnFrame.origin.y, btnFrame.size.width, btnFrame.size.height);
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchDisplayController 代理

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

#pragma mark - 隐藏navigationBar
- (void)hideNavigationBar:(BOOL)isHidden
{
    CGRect rect = self.myFileTableView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
   
    for (UIView *subView in self.navigationController.view.subviews)
    {
        if ([subView isKindOfClass:[UINavigationBar class]]) {
            
            if (isHidden == YES) {
                subView.frame = CGRectMake(0, -44, SCREEN_WIDTH, 44);
                self.myFileTableView.frame = CGRectMake(0, -44, rect.size.width, rect.size.height);
            } else {
                subView.frame = CGRectMake(0, 20, SCREEN_WIDTH, 44);
                self.myFileTableView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
            }
        }
    }
    [UIView commitAnimations];
}

#pragma mark - tableViewDataSource代理

- (void)tableView: (UITableView*)tableView
  willDisplayCell: (UITableViewCell*)cell
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    if (indexPath.row > 0) { //注意颜色的alpha要设为1.0,不然在弹出时cell的颜色会有闪烁
        UIColor *cellBackgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        cell.backgroundColor = cellBackgroundColor;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"SearchBarCell";
        SearchBarCell *cell = (SearchBarCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchBarCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] objectAtIndex:0];
            [cell.newFolderButton addTarget:self action:@selector(newFolder:) forControlEvents:UIControlEventTouchUpInside];
            cell.searchBar.delegate = self;
        }
        return cell;
    } else {
        if (indexPath.row == 0) {
            static NSString *mainContentCellID = @"MainContentCell";
            MainContentCell *cell = [tableView dequeueReusableCellWithIdentifier:mainContentCellID];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:mainContentCellID owner:self options:nil] objectAtIndex:0];
                [cell.unfoldBtn addTarget:self action:@selector(changeArrowDirection:) forControlEvents:UIControlEventTouchUpInside];
            }

            MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:indexPath.section-1];
            cell.nameLabel.text = item.fileName;
            cell.thumbnailView.image = item.thumbnailImage;
            NSDate *currentDate = item.dateCreated;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
            cell.dateLabel.text = [dateFormatter stringFromDate:currentDate];
            cell.sizeLabel.text = item.fileSize;
            return cell;
        } else {  //显示拓展行
            MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:indexPath.section-1];
            if (self.isUnfold && (item.fileProperty != kFilePropertyPic)) {
                static NSString *setMainContentCellID = @"SetMainContentCell";
                SetMainContentCell *cell = [tableView dequeueReusableCellWithIdentifier:setMainContentCellID];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:setMainContentCellID owner:self options:nil] objectAtIndex:0];
                    [self addTargetForSetMainContentCell:cell];
                }
                return cell;
            } else {
                static NSString *setFolderCellID = @"SetFolderCell";
                SetFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:setFolderCellID];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:setFolderCellID owner:self options:nil] objectAtIndex:0];
//                    cell.sDelegate = self;
                    [self addTargetForSetFolderCell:cell];
                }
                return cell;
            }
        }
    }
}

- (NSString *)stringFromFileSize:(double)fileSize
{
    NSString *sizeString = nil;
    if (fileSize <1000) {
        sizeString = [NSString stringWithFormat:@"%.0lfB",fileSize];
    } else if (fileSize >=1000 && fileSize < 1024) {
        sizeString = [NSString stringWithFormat:@"%.2lfKB",fileSize/1024.0];
    } else if (fileSize >=1024 && fileSize < 1024000){
        sizeString = [NSString stringWithFormat:@"%iKB",(int)(fileSize/1024)];
    } else if (fileSize >=1024000 && fileSize <1048576) {
        sizeString = [NSString stringWithFormat:@"%.2fMB",fileSize/1048576.0];
    } else if (fileSize >=1048576 && fileSize < 1048576000) {
        sizeString = [NSString stringWithFormat:@"%iMB",(int)(fileSize/1048576)];
    } else if (fileSize >=1048576000 && fileSize < 1048576000000) {
        sizeString = [NSString stringWithFormat:@"%.2fGB",fileSize/1048576000.0];
    } else {
        sizeString = [NSString stringWithFormat:@"%.0fGB",fileSize/1048576000];
    }
    return sizeString;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[MyFileItemStore sharedItemStore].allItems count];
    return count+1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isUnfold) {  //展开时就将展开的section行数返回2
        if (self.selectIndex.section == section) {
            return 2;
        }
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 44;
            break;
        default:
            return 55;
            break;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return nil;
    }
    if (indexPath.section > 0) {
        if (indexPath.row > 0) {
            return nil;
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0)
    {
        if ([tableView cellForRowAtIndexPath:indexPath].editing) { //如果正处于编辑状态，就不让push
            NSInteger count = tableView.indexPathsForSelectedRows.count;
            [self setAllBarItemsEnabledWithCount:count];
            return;
        } else {
            if (indexPath.row>0) { //对于展开行(即展开出来的行)，不让push
                return;
            }

            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView = backgroundView;
            cell.selectedBackgroundView.backgroundColor = NavigationBarColor;

            MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:indexPath.section-1];
            [self previewItem:item];
        }
     }
}

#pragma mark - 文件预览
- (void)previewItem:(MainContentItem *)item
{
    NSString *rootPath = [NSString stringWithFormat:@"%@",ROOT_PATH];
    if ([item.currentFolderPath isEqualToString:rootPath]) {
        item.currentFolderPath = [NSString stringWithFormat:@"%@%@",ROOT_PATH,item.fileName];
    } else {
        item.currentFolderPath = [NSString stringWithFormat:@"%@/%@",self.currentPath,item.fileName];
    }
    
    switch (item.fileProperty) {
        case kFilePropertyDir:{
            MyFileViewController *mfvc = [[MyFileViewController alloc] initWithDirectoryAtPath:item.currentFolderPath];
            mfvc.navTitle = item.fileName;
            [self setTableViewCellFold];
            [self.navigationController pushViewController:mfvc animated:YES];
            break;
        }
        case kFilePropertyDoc:
        case kFilePropertyXls:
        case kFilePropertyPpt:{
            break;
        }
        case kFilePropertyPic:{
            //push进入文件查看控制器viewController，比如图片，文档等
            PhotoBrowser *photoBrowser = [[PhotoBrowser alloc] init];
            photoBrowser.photoArray = [[NSMutableArray alloc] initWithObjects:@"tutorial_background_00@2x.jpg",@"tutorial_background_01@2x.jpg",
                                       @"tutorial_background_02@2x.jpg",@"tutorial_background_03@2x.jpg",nil];
            [photoBrowser showPhotoViewFromCurrentIndex:0];
            [self setTableViewCellFold];
            [self.navigationController pushViewController:photoBrowser animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 取消选择某一行时
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0) {
        if ([tableView cellForRowAtIndexPath:indexPath].editing) {
            NSInteger count = tableView.indexPathsForSelectedRows.count;
            [self setAllBarItemsEnabledWithCount:count];
        }
    }
}

#pragma mark - 设置某一行是否能编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark - 改变折叠按钮图片
- (void)changeArrowDirectionForIndexPathofUnfold
{
    if (self.indexOfUnfold != nil) {
        NSIndexPath *btnIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.indexOfUnfold.section];
        MainContentCell *cell = (MainContentCell *)[self.myFileTableView cellForRowAtIndexPath:btnIndexPath];
        [cell.unfoldBtn setImage:[UIImage imageNamed:@"DownAccessory.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - 折叠按钮点击事件
- (void)changeArrowDirection:(id)sender 
{
    UIButton *btn = (UIButton *)sender;
    [self changeArrowDirectionForIndexPathofUnfold];
    NSIndexPath *indexPath = nil;
   
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <7.0) {
        indexPath = [self.myFileTableView indexPathForCell:((MainContentCell *)[[btn superview] superview])];
    } else {
        indexPath = [self.myFileTableView indexPathForCell:((MainContentCell *)[[[btn superview] superview] superview])];
    }
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    self.selectIndex = indexPath;
    if (!self.isUnfold) {
        [self.myFileTableView beginUpdates];
        [btn setImage:[UIImage imageNamed:@"UpAccessory.png"] forState:UIControlStateNormal];
        [self.myFileTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        self.indexOfUnfold = newIndexPath;
        self.isUnfold = YES;
       [self.myFileTableView endUpdates];
        [self makeCellVisibleAtIndexPath:newIndexPath];
    } else {
        if (self.indexOfUnfold != nil) {  //如果已经展开且点击的不在同一行
            if (self.indexOfUnfold.section != self.selectIndex.section) {
                [self.myFileTableView beginUpdates];
                [btn setImage:[UIImage imageNamed:@"UpAccessory.png"] forState:UIControlStateNormal];
                [self.myFileTableView deleteRowsAtIndexPaths:@[self.indexOfUnfold] withRowAnimation:UITableViewRowAnimationTop];
                [self.myFileTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                 self.indexOfUnfold = newIndexPath;
                 self.isUnfold = YES;
                [self.myFileTableView endUpdates];
                [self makeCellVisibleAtIndexPath:newIndexPath];
            } else {            //关闭折叠
                [self.myFileTableView beginUpdates];
                [self.myFileTableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                self.indexOfUnfold = nil;
                self.isUnfold = NO;
                [self.myFileTableView endUpdates];
                
            }
        }
    }
}

- (void)makeCellVisibleAtIndexPath:(NSIndexPath*)indexPath
{
    //如果不完全可见，滚动使其完全可见
    UITableViewCell *cell = [self.myFileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];

    CGFloat offset = self.myFileTableView.contentOffset.y;
    CGFloat visible = [UIScreen mainScreen].bounds.size.height-64-49; //455
    CGFloat originY = cell.frame.origin.y;
    CGFloat y = cell.frame.origin.y + cell.frame.size.height- offset;
    CGFloat height = cell.frame.size.height;
  
    if (visible-y < height) {
         [self.myFileTableView setContentOffset:CGPointMake(0, 2*height+originY-visible) animated:YES];
    }
}

#pragma mark - 文件拓展行
- (void)addTargetForSetMainContentCell:(SetMainContentCell *)cell
{
    [cell.saveBtn addTarget:self action:@selector(saveFile:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareBtn addTarget:self action:@selector(shareFile:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(deleteFile:) forControlEvents:UIControlEventTouchUpInside];
    [cell.moreBtn addTarget:self action:@selector(moreFile:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addTargetForSetFolderCell:(SetFolderCell *)cell
{
    [cell.downloadBtn addTarget:self action:@selector(downloadFile:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareBtn addTarget:self action:@selector(shareFile:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(deleteFile:) forControlEvents:UIControlEventTouchUpInside];
    [cell.moreBtn addTarget:self action:@selector(moreFile:) forControlEvents:UIControlEventTouchUpInside];
}
//保存图片
- (void)saveFile:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到本地相册", nil];
    actionSheet.tag = 1011;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

//下载文件
- (void)downloadFile:(id)sender
{
    [self recover];
    NSMutableArray *items = [NSMutableArray array];
    if (self.myFileTableView.isEditing) {   //多选下载
        for (NSIndexPath *indexPath in self.myFileTableView.indexPathsForSelectedRows) {
            MainContentItem *tempItem = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:indexPath.section-1];
            [items addObject:tempItem];
        }
        [[DownloadItemStore sharedItemStore].downloadingItems addObjectsFromArray:items];
    } else {
        MainContentItem *tempItem = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:self.selectIndex.section-1];
        [[DownloadItemStore sharedItemStore].downloadingItems addObject:tempItem];
    }
    
    NSString *value = [NSString stringWithFormat:@"%i",[DownloadItemStore sharedItemStore].downloadingItems.count];
    [[self.navigationController.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:value];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadNotification object:nil];
}

//分享文件
- (void)shareFile:(id)sender
{
//    [self showShareSingleFileOrFolderActionSheet];
    UIActionSheet *shareList = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:
                                @"复制链接", @"短信分享",@"邮件分享",
                                @"分享到新浪微博",@"分享到腾讯微博",
                                @"分享到QQ空间",@"分享给微信好友",@"分享到微信朋友圈",
                                nil];
    shareList.tag = 1012;
    [shareList showFromToolbar:self.navigationController.toolbar];
}

//删除文件,多选删除和拓展行删除用的是同一个函数
- (void)deleteFile:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"在回收站找回删除的文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
    actionSheet.tag = 1013;
    if (self.myFileTableView.indexPathsForSelectedRows.count > 0) {
        [actionSheet showFromToolbar:_toolBar];
    } else {
        [actionSheet showFromRect:[(UIButton*)sender frame] inView:self.myFileTableView animated:YES];
    }
}

//更多操作
- (void)moreFile:(id)sender
{
    MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:self.selectIndex.section-1];
    UIActionSheet *actionSheet = nil;
    if (item.fileProperty == kFilePropertyPic) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"下载", @"重命名",@"移动",@"复制",nil];
        actionSheet.tag = 1014;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重命名",@"移动",@"复制",nil];
        actionSheet.tag = 1015;
    }
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - actionSheet代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 1011:  //保存文件
            [self saveFileAction:actionSheet clickedButtonAtIndex:buttonIndex];
            break;
        case 1012:  //分享文件
            [self shareFileAction:actionSheet clickedButtonAtIndex:buttonIndex];
            break;
        case 1013:  //删除图片
            [self deleteFileAction:actionSheet clickedButtonAtIndex:buttonIndex];
            break;
        case 1014:  //更多操作 for pic
        case 1015:  //更多操作 for others
            [self moreFileAction:actionSheet clickedButtonAtIndex:buttonIndex];
            break;
        default:
            break;
    }
}

#pragma mark - actionSheet操作

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error
  contextInfo: (void *) contextInfo;
{
    [self createHUDWithCustomView];
    
    if (error != NULL) {
        UIImage *failImg = [UIImage imageNamed:@"MBProgressHUD.bundle/fail.png"];
        [self showHUDWithImage:failImg messege:@"照片保存失败"];
    }else{
        UIImage *successImg = [UIImage imageNamed:@"MBProgressHUD.bundle/success.png"];
        [self showHUDWithImage:successImg messege:@"照片保存成功"];
    };
}

- (void)saveFileAction:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        //图片单个文件保存，indexofUnfold
     if (buttonIndex == 0) {
         MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:self.selectIndex.section-1];
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentPath = [paths objectAtIndex:0];
         NSString *downloadDir = [documentPath stringByAppendingPathComponent:DOWNLOAD_DIR];
         NSString *tempFilePath = [downloadDir stringByAppendingPathComponent:item.fileName];
         if ([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
             NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:tempFilePath];
             UIImage *image = [UIImage imageWithData:imageData];
             UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
         } else {
             //下载图片
             
         }
     }
}

- (void)shareFileAction:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

- (void)deleteFileAction:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableArray *nameArray = [NSMutableArray array];
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确认删除"]) {
        if (self.myFileTableView.editing) {         //多选删除
            for (NSIndexPath *index in [self.myFileTableView indexPathsForSelectedRows]) {
                 MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:index.section-1];
                [nameArray addObject:item.fileName];
            }
            
            _HUD = [[MBProgressHUD alloc] initWithView:self.view];
            _HUD.labelText = @"请稍后…";
            [self.view addSubview:_HUD];
            [_HUD show:YES];;
            
            [self requestDeleteFile:nameArray];
        } else {
            MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:self.selectIndex.section-1];
            MainContentCell *cell = (MainContentCell*)[self.myFileTableView cellForRowAtIndexPath:self.selectIndex];
            cell.dateLabel.text = @"正在删除...";
            [nameArray addObject:item.fileName];
            [self requestDeleteFile:nameArray];
        }
    }
}

- (void)deleteSingleItem
{
    MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:self.selectIndex.section-1];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:self.selectIndex.section];
    //应先删除服务器端的文件，再删除本地的文件或者
    //删除
    
    [self.myFileTableView beginUpdates];
    [[[MyFileItemStore sharedItemStore] allItems] removeObject:item];
    [self.myFileTableView deleteRowsAtIndexPaths:@[self.indexOfUnfold] withRowAnimation:UITableViewRowAnimationRight];
    [self.myFileTableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
    self.isUnfold = NO; //注意这个不能少
    [self.myFileTableView endUpdates];
    self.indexOfUnfold = nil;
}

- (void)deleteMutableItems
{
    NSInteger selectCounts = self.myFileTableView.indexPathsForSelectedRows.count;
    NSMutableArray *selectIndexPaths = [self.myFileTableView.indexPathsForSelectedRows mutableCopy];
    NSMutableIndexSet *indexSets = [NSMutableIndexSet indexSet];
    int i = 0;
    for (NSIndexPath *indexPath in [self.myFileTableView indexPathsForSelectedRows]) {
        MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:indexPath.section-i-1];
        [[MyFileItemStore sharedItemStore].allItems removeObject:item];
        [indexSets addIndex:indexPath.section];
        if (selectIndexPaths.count > 0) {
            [
             selectIndexPaths removeObject:indexPath];
            i++;
        }
    }
   
    [self.myFileTableView beginUpdates];
    [self.myFileTableView deleteSections:indexSets withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.myFileTableView endUpdates];
    [self setAllBarItemsEnabledWithCount:selectCounts];
    
    self.indexOfUnfold = nil;
    [self.navigationItem.rightBarButtonItem setTitle:@"多选"];
    [self.myFileTableView setEditing:NO animated:YES];

    if (self.toolBar != nil) {
        [self showTabBar];
    }
}

- (void)moreFileAction:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MainContentItem *item = [[MyFileItemStore sharedItemStore].allItems objectAtIndex:self.selectIndex.section-1];
    if (actionSheet.tag == 1014) {  //图片拓展行
        switch (buttonIndex) {
            case 0:{        //下载
                [self downloadFile:nil];
                break;
            }
            case 1:{        //重命名
                NewFolderViewController *vc = [[NewFolderViewController alloc] init];
                vc.folderName.text = item.fileName;
                vc.folderImage = item.thumbnailImage;
                vc.operationType = kOperationTypeFileRename;
                vc.nDelegate = self;
                [self presentViewController:vc animated:YES completion:nil];
                break;
            }
            case 2:{        //移动
                break;
            }
            case 3:{        //复制
                break;
            }
            default:break;
        }
    } else if (actionSheet.tag == 1015) {
        switch (buttonIndex) {
            case 0:{        //重命名
                NewFolderViewController *vc = [[NewFolderViewController alloc] init];
                vc.folderName.text = item.fileName;
                vc.folderImage = item.thumbnailImage;
                vc.operationType = kOperationTypeFileRename;
                vc.nDelegate = self;
                [self presentViewController:vc animated:YES completion:nil];
                break;
            }
            case 1:{        //移动
                break;
            }
            case 2:{        //复制
                break;
            }
            default:break;
        }
    }
}

#pragma mark - 删除服务器端文件
- (void)requestDeleteFile:(NSArray *)nameArray
{
    NSString *str = [[NSString alloc] init];
    for (NSString *name in nameArray) {
        str = [str stringByAppendingFormat:@"&name=%@",name];
    }
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
    NSString *urlString = [NSString stringWithFormat:@"%@cnddelete.cgi?path=%@%@&sid=%@",HOST_URL,self.currentPath,str,sid];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str1 = [urlString stringByAddingPercentEscapesUsingEncoding:enc];

    if (!_request) {
        _request = [[NSMutableURLRequest alloc] init];
        [_request setHTTPMethod:@"GET"];
        [_request setTimeoutInterval:30];
    }
    _request.URL = [NSURL URLWithString:str1];
    AFHTTPRequestOperation *requestOperaton = [[AFHTTPRequestOperation alloc] initWithRequest:_request];
    [requestOperaton setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseDeleteResultWithData:operation.responseData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"删除失败:%@",[error localizedDescription]);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [requestOperaton start];
}

- (void)parseDeleteResultWithData:(NSData *)data
{
    NSError *error = nil;
    TBXML *xml = [[TBXML alloc] initWithXMLData:data error:&error];
    if (error) {
        NSLog(@"解析文件错误:%@",[error localizedDescription]);
        return;
    }
    TBXMLElement *root = [xml rootXMLElement];
    TBXMLElement *deleteNode = [TBXML childElementNamed:@"Delete" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:deleteNode];
    NSString *errorNum = [NSString stringWithCString:statusNode->firstAttribute->value encoding:NSUTF8StringEncoding];
    if ([errorNum isEqualToString:@""]) {
        if (self.myFileTableView.editing)
            [self deleteMutableItems];
        else
            [self deleteSingleItem];
    } else {
        NSLog(@"删除错误:%@",errorNum);
    }
    
    [_HUD removeFromSuperview];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - setMainContentCell代理方法
- (void)tapDownloadButtonInSetFolderCell:(SetFolderCell *)cell
{
    NSLog(@"下载文件夹");
}

- (void)tapShareButtonInSetFolderCell:(SetFolderCell *)cell
{
    [self showShareSingleFileOrFolderActionSheet];
}

- (void)showShareSingleFileOrFolderActionSheet  //对于单个的文件或文件夹使用相同的actionSheet，只需获取所选择的行即可
{
    UIActionSheet *shareList = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:
                                @"复制链接", @"短信分享",@"邮件分享",
                                @"分享到新浪微博",@"分享到腾讯微博",
                                @"分享到QQ空间",@"分享给微信好友",@"分享到微信朋友圈",
                                nil];
    shareList.tag = 1001;
    [shareList showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - 获取文件列表
- (void)startConnectionWithRequest:(NSMutableURLRequest *)request
{
    if (!request) {
        request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        request.timeoutInterval = 60;
    }

    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
    NSString *string = [NSString stringWithFormat:@"cndfilelist.cgi?path=%@&filter=all&sortby=name&desc=true&start=1&num=%i&sid=",self.currentPath,MAX_SHOW_NUM];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",HOST_URL,string,sid];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str1 = [urlString stringByAddingPercentEscapesUsingEncoding:enc];
    request.URL = [NSURL URLWithString:str1];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO]; //注意这个connection必须每次都要重新创建一次
    [connection start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    while (!_connIsFinished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)parseFileListWithData:(NSData *)data
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:encoding]);
    NSString *dataString = [[NSString alloc] initWithData:data encoding:encoding];
    NSError *error = nil;
    TBXML *xml = [[TBXML alloc] initWithXMLString:dataString error:&error];
    if (error) {
        NSLog(@"解析文件错误:%@",[error localizedDescription]);
        return;
    }
    
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *filelistNode = [TBXML childElementNamed:@"Filelist" parentElement:root];
    TBXMLElement *listNode = [TBXML childElementNamed:@"List" parentElement:filelistNode];
    TBXMLElement *fileNode = listNode->firstChild;
    
//    if (!itemSotre) {
//        itemSotre = [[MyFileItemStore alloc] init];
//    }
    [[MyFileItemStore sharedItemStore].allItems removeAllObjects];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    while (fileNode) {                                  
        NSString *fileName = [TBXML valueOfAttributeNamed:@"fname" forElement:fileNode];
        NSString *fileSize = [TBXML valueOfAttributeNamed:@"fsize" forElement:fileNode];
        NSString *fileDate = [TBXML valueOfAttributeNamed:@"fdate" forElement:fileNode];
        NSString *fileProp = [TBXML valueOfAttributeNamed:@"prop" forElement:fileNode];
       
        MainContentItem *tempItem = [[MainContentItem alloc] init];
        tempItem.fileName = fileName;
//        tempItem.fileSize = [fileSize doubleValue];
        tempItem.fileSize = fileSize;
        tempItem.dateCreated = [dateFormatter dateFromString:fileDate];
        tempItem.thumbnailImage = [UIImage imageNamed:@"placehoderImg"];
        tempItem.currentFolderPath = self.currentPath;
        if ([fileProp isEqualToString:@"dir"])
            tempItem.fileProperty = 0;
        else if ([fileProp isEqualToString:@"doc"])
            tempItem.fileProperty = 1;
        else if ([fileProp isEqualToString:@"xls"])
            tempItem.fileProperty = 2;
        else if ([fileProp isEqualToString:@"ppt"])
            tempItem.fileProperty = 3;
        else
            tempItem.fileProperty = 4;
        if (tempItem.fileProperty != 0)
            tempItem.thumbnailImage = [UIImage imageNamed:@"placehoderImg"];
        else
            tempItem.thumbnailImage = [UIImage imageNamed:@"mainFolder"];

        [[MyFileItemStore sharedItemStore].allItems addObject:tempItem];
        fileNode = fileNode->nextSibling;
    }
    
    [self.myFileTableView reloadData];
    TBXMLElement *status = [TBXML childElementNamed:@"Status" parentElement:filelistNode];
    NSString *errorno = [NSString stringWithCString:status->firstAttribute->value encoding:NSUTF8StringEncoding];
    if (![errorno isEqualToString:@""]) {
        NSLog(@"获取文件列表出错：%@",errorno);
    }
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connIsFinished = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%@",[error localizedDescription]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_receiveData) {
        _receiveData = [[NSMutableData alloc] init];
    }
    [_receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _connIsFinished = YES;
    connection = nil;
//    [_connection cancel];
//    _connection = nil;
    if (self.refreshView.isLoading) {
        [self stopLoading];
    }
    
    [self parseFileListWithData:_receiveData];
    [_receiveData setLength:0];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - 提示框
#pragma mark 显示提示框
- (void)createHUDWithCustomView
{
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_HUD];
        _HUD.mode = MBProgressHUDModeCustomView;
    }
}

- (void)showHUDWithImage:(UIImage *)image messege:(NSString *)string
{
    if (_HUD==nil)
        return;
    _HUD.customView = [[UIImageView alloc] initWithImage:image];
    _HUD.labelText = string;
    [_HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2.5);
    } completionBlock:^{
        [_HUD removeFromSuperview];
        _HUD = nil;
    }];
}

- (void)showHUDWithMessage:(NSString *)string
{
    if (_HUD == nil) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_HUD];
        _HUD.mode = MBProgressHUDModeText;
    }
    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = string;
    
    [_HUD showAnimated:YES whileExecutingBlock:^{
        sleep(3);
    } completionBlock:^{
        [_HUD removeFromSuperview];
    }];
}

- (void)addNetworkStateNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
//    _internetReachability = [Reachability reachabilityForInternetConnection];
//	[_internetReachability startNotifier];
//    _wifiReachability = [Reachability reachabilityForLocalWiFi];
//	[_wifiReachability startNotifier];
}

- (BOOL)networkReachable
{
    NetworkStatus wifiStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (wifiStatus == NotReachable && internetStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - NetworkStatus通知消息
- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    switch (netStatus)
    {
        case NotReachable:
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self createHUDWithCustomView];
            UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/error.png"];
            [self showHUDWithImage:img messege:@"当前网络不可用"];
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"2G/3G网络可用！");
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"文件页面wifi可用");
//            if (_getSpaceFail == YES) {
//                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//                [self getAvailebleSpace];
//            }
            break;
        }
    }
}
@end











