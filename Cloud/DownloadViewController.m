//
//  DownloadViewController.m
//  Cloud
//
//  Created by zzti on 13-11-12.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadItemStore.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "UploadCell.h"
#import "MainContentItem.h"

@interface DownloadViewController ()<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableURLRequest *_request;
    AFHTTPRequestOperation *_requestOperation;
    
    NSInteger _currentProgressCounter;
    MDRadialProgressView *_progressView;
    UIView *_bottomDeleteView;
    
    UILabel *_downloadingLabel;  //正在下载数
    UILabel *_downloadLabel;   //完成下载数
}
@end

@implementation DownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"下载列表" image:[UIImage imageNamed:@"download.png"] tag:2];
        self.tabBarItem = tabBarItem;
        self.navigationItem.title = @"下载列表";
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"多选" style:UIBarButtonItemStylePlain target:self action:@selector(mutableSelect:)];
        
        
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setExtraCellLineHidden:self.downloadTableView];
    
    UINib *nib = [UINib nibWithNibName:@"UploadCell" bundle:nil];
    [self.downloadTableView registerNib:nib forCellReuseIdentifier:@"UploadCell"];
    
    CGFloat width = self.downloadTableView.bounds.size.width;
    _downloadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, width, 20.0)];
    _downloadingLabel.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1];
    _downloadingLabel.font = [UIFont systemFontOfSize:14.0];
    _downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, width, 20.0)];
    _downloadLabel.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1];
    _downloadLabel.font = [UIFont systemFontOfSize:14.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - 多选
- (void)mutableSelect:(id)sender
{
    UIBarButtonItem *rightBtnItem = sender;
    if ([rightBtnItem.title isEqualToString:@"多选"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
        [self.downloadTableView setEditing:YES animated:NO];
        [self hideTabBar:YES];
    } else if ([rightBtnItem.title isEqualToString:@"取消"]) {
        [self recover];
    }
}

- (void)selectAll:(id)sender
{
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    NSInteger downloadingCounts = [DownloadItemStore shareItemStore].downloadingItems.count;
    NSInteger downloadCounts = [DownloadItemStore shareItemStore].downloadItems.count;
    NSInteger allCounts = downloadCounts + downloadingCounts;
    
    if ([item.title isEqualToString:@"全选"]) {
        item.title = @"全不选";
        for (NSIndexPath *index in self.downloadTableView.indexPathsForVisibleRows ) {
            [self.downloadTableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
        [self setDeleteButtonWithCount:allCounts];
    } else {
        item.title = @"全选";
        for (NSIndexPath *index in self.downloadTableView.indexPathsForVisibleRows ) {
            [self.downloadTableView deselectRowAtIndexPath:index animated:NO ];
        }
        [self setDeleteButtonWithCount:0];
    }
}

- (void)recover
{
    [self.navigationItem.rightBarButtonItem setTitle:@"多选"];
    self.navigationItem.leftBarButtonItem = nil;
    [self.downloadTableView setEditing:NO animated:NO];
    [self hideTabBar:NO];
}

#pragma mark - 隐藏tabBar
- (void) hideTabBar:(BOOL) hidden
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
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
                [self addBottomViewInView:view];
            } else {
                [self removeBottomViewInView:view];
            }
        }
    }
    [UIView commitAnimations];
}

#pragma mark - 添加或移除底部按钮
- (void)addBottomViewInView:(UIView *)view
{
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnWidth = viewWidth - 30;
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake((viewWidth-btnWidth)/2.0, 4.5, btnWidth, 35)];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"bottomDeleteBtn.png"] forState:UIControlStateNormal];
    
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitle:@"删除" forState:UIControlStateSelected];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.enabled = NO;
    
    CGFloat tbY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        tbY = self.view.frame.size.height+self.view.frame.origin.y-44-20; //44+20 导航栏+状态栏
    } else{
        tbY = self.view.frame.size.height+self.view.frame.origin.y; //44+20 导航栏+状态栏
    }
    
    _bottomDeleteView = [[UIView alloc] initWithFrame:CGRectMake(0, tbY-44, viewWidth, 44)];
    _bottomDeleteView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    [_bottomDeleteView addSubview:deleteBtn];
    [self.view addSubview:_bottomDeleteView];
    
    [deleteBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeBottomViewInView:(UIView *)view
{
    for (UIView *subView in _bottomDeleteView.subviews) {
        [subView removeFromSuperview];
    }
    
    [_bottomDeleteView removeFromSuperview];
    _bottomDeleteView = nil;
}

#pragma mark - 修改按钮label
- (void)setDeleteButtonWithCount:(NSInteger)count
{
    UIButton *button = [_bottomDeleteView.subviews objectAtIndex:0];
    if (count < 1) {
        button.enabled = NO;
        [button setTitle:@"删除" forState:UIControlStateNormal];
    } else {
        button.enabled = YES;
        NSString *str = [NSString stringWithFormat:@"删除（%i）",count];
        [button setTitle:str forState:UIControlStateNormal];
    }
}

#pragma mark 删除所选行
- (void)deleteCell:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"仅移除下记录,不会删除文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定删除" otherButtonTitles: nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, tableView.bounds.size.width, 20.0)];
    customView.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
    NSInteger downloadingCounts = [DownloadItemStore shareItemStore].downloadingItems.count;
    NSInteger downloadCounts = [DownloadItemStore shareItemStore].downloadItems.count;
//    if (section == 0) {
//        if (downloadingCounts == 0) {
//            return nil;
//        } else {
//            [customView addSubview:_downloadingLabel];
//            return customView;
//        }
//    } else {
//        if (_downloadLabel.text == nil) {
//            return nil;
//        } else {
//            [customView addSubview:_downloadLabel];
//            return customView;
//        }
//    }
    
    if (downloadingCounts > 0 && downloadCounts == 0) {
        [customView addSubview:_downloadingLabel];
        return customView;
    } else if (downloadingCounts == 0 && downloadCounts > 0) {
        [customView addSubview:_downloadLabel];
        return customView;
    } else if (downloadingCounts > 0 && downloadCounts > 0) {
        if (section == 0) {
            [customView addSubview:_downloadingLabel];
            return customView;
        } else {
            [customView addSubview:_downloadLabel];
            return customView;
        }
    } else {
        return nil;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger downloadingCounts = [DownloadItemStore shareItemStore].downloadingItems.count;
    NSInteger downloadCounts = [DownloadItemStore shareItemStore].downloadItems.count;
    if (section == 0) {
        return downloadingCounts > 0 ? 20.0 : 0;
    } else {
        return downloadCounts > 0 ? 20.0 : 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger downloadingNum = [DownloadItemStore shareItemStore].downloadingItems.count;
    NSInteger downloadNum = [DownloadItemStore shareItemStore].downloadItems.count;
    if (downloadingNum > 0 && downloadNum > 0) {
        return 2;
    } else if (downloadingNum ==0 && downloadNum == 0) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger downloadingCounts = [DownloadItemStore shareItemStore].downloadingItems.count;
    NSInteger downloadCounts = [DownloadItemStore shareItemStore].downloadItems.count;
    
    if (downloadingCounts == 0)
        _downloadingLabel.text = nil;
    else
        _downloadingLabel.text = [NSString stringWithFormat:@"正在下载（%i）",downloadingCounts];
    
    if (downloadCounts == 0)
        _downloadLabel.text = nil;
    else
        _downloadLabel.text = [NSString stringWithFormat:@"已完成下载（%i）",downloadCounts];
    
    if (section == 0) {
        return [DownloadItemStore shareItemStore].downloadingItems.count;
    } else {
        return [DownloadItemStore shareItemStore].downloadItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UploadCell"];
//    [self removeProgressViewInTableViewCell:cell];
    
    if (indexPath.section == 0) {
        MainContentItem *item = [[DownloadItemStore shareItemStore].downloadingItems objectAtIndex:indexPath.row];
        cell.thumbnailView.image = item.thumbnailImage;
        cell.nameLabel.text = item.fileName;
        cell.sizeLabel.text = item.fileSize;
        if (indexPath.row == 0) {
            if ([self internetIsReachable])
                cell.dateLabel.text = item.fileSize;
            else
                cell.dateLabel.text = @"正在等待网络…";
            //添加进度条
//            _progressView.progressCounter = _currentProgressCounter;
//            cell.accessoryView = _progressView;
            
//            if (_shouldBegin == YES) {
//                [self uploadFileWithAsset:asset AtIndexPath:indexPath];
//                _shouldBegin = NO;
//            }
        } else {
            cell.dateLabel.text = @"正在等待…";
        }
        return cell;
    } else {
        MainContentItem *item = [[DownloadItemStore shareItemStore].downloadItems objectAtIndex:indexPath.row];
        cell.thumbnailView.image = item.thumbnailImage;
        cell.nameLabel.text = item.fileName;
        
        NSDate *nowDate = [NSDate date];
        NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
        [outFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *timeStr = [outFormat stringFromDate:nowDate];
        cell.dateLabel.text = timeStr;
        cell.sizeLabel.text = item.fileSize;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark - 滑动删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            [[DownloadItemStore shareItemStore].downloadingItems removeObjectAtIndex:indexPath.row];
            if ([DownloadItemStore shareItemStore].downloadingItems.count == 0) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } else {
            [[DownloadItemStore shareItemStore].downloadItems removeObjectAtIndex:indexPath.row];
            if ([DownloadItemStore shareItemStore].downloadItems.count == 0) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

#pragma mark - 选择某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        [self setDeleteButtonWithCount:tableView.indexPathsForSelectedRows.count];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        [self setDeleteButtonWithCount:tableView.indexPathsForSelectedRows.count];
    }
}

#pragma mark - 当前网络状态
- (BOOL)internetIsReachable
{
    NetworkStatus wifiStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(wifiStatus == NotReachable && internetStatus == NotReachable)
        return NO;
    else
        return YES;
}

@end
