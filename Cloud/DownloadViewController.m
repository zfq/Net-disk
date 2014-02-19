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
#import "DownloadCell.h"
#import "MainContentItem.h"
#import "Constant.h"
#import "TBXML.h"

#define MAX_BUFFER_LENGTH 2097152   //2MB  2097152

@interface DownloadViewController ()<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSMutableURLRequest *_request;
    AFHTTPRequestOperation *_requestOperation;
    BOOL _connIsFinished;
    
    NSInteger _currentProgressCounter;
    NSInteger _currentDownloadingRow;
    NSIndexPath *_currentDownloadingIndexPath;
    long long _fileLength;
    
    NSFileHandle *_fileHandle;
    NSMutableData *_receivedData;
    long long _receivedLength;
    
    MDRadialProgressView *_progressView;
    UIButton *_progressButton;
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
        
        _currentProgressCounter = 0;
        _connIsFinished = NO;
        _fileLength = 0;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFile:) name:kDownloadNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setExtraCellLineHidden:self.downloadTableView];
    
    UINib *uploadCellNib = [UINib nibWithNibName:@"UploadCell" bundle:nil];
    [self.downloadTableView registerNib:uploadCellNib forCellReuseIdentifier:@"UploadCell"];
    UINib *downloadCellNib = [UINib nibWithNibName:@"DownloadCell" bundle:nil];
    [self.downloadTableView registerNib:downloadCellNib forCellReuseIdentifier:@"DownloadCell"];
    
    CGFloat width = self.downloadTableView.bounds.size.width;
    _downloadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, width, 20.0)];
    _downloadingLabel.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1];
    _downloadingLabel.font = [UIFont systemFontOfSize:14.0];
    _downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, width, 20.0)];
    _downloadLabel.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1];
    _downloadLabel.font = [UIFont systemFontOfSize:14.0];
    
//     _progressView = [self progressViewWithFrame:CGRectMake(0, 0, 40, 40)];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        NSInteger downloadingCounts = [DownloadItemStore shareItemStore].downloadingItems.count;
        NSInteger downloadCounts = [DownloadItemStore shareItemStore].downloadItems.count;
        UIBarButtonItem *leftItem = self.navigationItem.leftBarButtonItem;
        
        if ([leftItem.title isEqualToString:@"全不选"]) {
            [[DownloadItemStore shareItemStore].downloadingItems removeAllObjects];
            [[DownloadItemStore shareItemStore].downloadItems removeAllObjects];
            if (downloadingCounts > 0 && downloadCounts > 0) {
                [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                
                 [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
        } else {
            [self deleteCellsInTableView];
        }
        
        [self recover];
    }
}

- (void)deleteCellsInTableView
{
    //        BOOL isExistUploadingCell = NO;
    NSMutableIndexSet *downloadingIndexes = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *downloadIndexes = [[NSMutableIndexSet alloc] init];
    for (NSIndexPath *indexpath in self.downloadTableView.indexPathsForSelectedRows) {
        if (indexpath.section == 0) {
            [downloadingIndexes addIndex:indexpath.row];
            //                if (indexpath.row == 0) {
            //                    isExistUploadingCell = YES;
            //                    [_requestOperation cancel];
            //                    _requestOperation = nil;
            //                }
        } else {
            [downloadIndexes addIndex:indexpath.row];
        }
    }
    
    NSInteger downloadingCounts = [DownloadItemStore shareItemStore].downloadingItems.count;
    NSInteger downloadCounts = [DownloadItemStore shareItemStore].downloadItems.count;
    
    if (downloadingCounts > 0) {
        [[DownloadItemStore shareItemStore].downloadingItems removeObjectsAtIndexes:downloadingIndexes];
    }
    if (downloadCounts > 0) {
        [[DownloadItemStore shareItemStore].downloadItems removeObjectsAtIndexes:downloadIndexes];
    }
    
    if (downloadingCounts > 0 && downloadCounts > 0) { //正在下载和已完成下载同时存在
        if (downloadingIndexes.count == downloadingCounts && downloadIndexes.count != downloadCounts) {  //全选正在下载
            [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (downloadingIndexes.count != downloadingCounts && downloadIndexes.count == downloadCounts) {
            [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic]; //全选已完成下载
        } else if (downloadingIndexes.count == downloadingCounts && downloadIndexes.count == downloadCounts) {   //两者同时选中，即全选
            [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.downloadTableView deleteRowsAtIndexPaths:self.downloadTableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationNone];
        }
    } else if (downloadingCounts > 0 && downloadCounts == 0){  //只有正在下载
        if (downloadingIndexes.count == downloadingCounts) {
            [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.downloadTableView deleteRowsAtIndexPaths:self.downloadTableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationNone];
        }
    } else if (downloadingCounts == 0 && downloadCounts > 0) {  //只有已完成下载
        if (downloadIndexes.count == downloadCounts) {
            [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.downloadTableView deleteRowsAtIndexPaths:self.downloadTableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    
    //        if (isExistUploadingCell && [UploadItemStore sharedStore].uploadingItems.count>0) {
    //            [self continueUploadForView:self.uploadTableView];
    //        }
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
//    [self removeProgressViewInTableViewCell:cell];
    if (indexPath.section == 0) {
        DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell"];
        MainContentItem *item = [[DownloadItemStore shareItemStore].downloadingItems objectAtIndex:indexPath.row];
        cell.thumbnailView.image = item.thumbnailImage;
        cell.nameLabel.text = item.fileName;
        cell.sizeLabel.text = item.fileSize;
        if (indexPath.row == 0) {
            if ([self internetIsReachable])
                cell.dateLabel.text = item.fileSize;
            else
                cell.dateLabel.text = @"正在等待网络…";
            if (!_progressButton) {
                _progressButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _progressButton.frame = CGRectMake(0,0,40,40);
                _progressButton.selected = NO;
                [_progressButton setBackgroundImage:[UIImage imageNamed:@"fav_pause_normal"] forState:UIControlStateNormal];
                [_progressButton setBackgroundImage:[UIImage imageNamed:@"fav_pause_pressed"] forState:UIControlStateHighlighted];
                [_progressButton setBackgroundImage:[UIImage imageNamed:@"fav_download_normal"] forState:UIControlStateSelected];
                [_progressButton addTarget:self action:@selector(tapProgressButton:) forControlEvents:UIControlEventTouchUpInside];
            }
            if (!_progressView) {
                _progressView = [self progressViewWithFrame:CGRectMake(0, 0, 40, 40)];
                UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:_progressView action:@selector(tapProgressView:)];
                [_progressView addGestureRecognizer:recognizer];
            }
            if ([self internetIsReachable]) {
              
            }
            //添加进度条
            _progressView.progressCounter = _currentProgressCounter;
            _progressButton.hidden = YES;
            [_progressView addSubview:_progressButton];
            cell.accessoryView = _progressView;
//            cell.accessoryView = _progressButton;
//            if (_shouldBegin == YES) {
            _currentDownloadingIndexPath = indexPath;
            _currentDownloadingRow = indexPath.row;
            [self downloadItem:item];
//                _shouldBegin = NO;
//            }
        } else {
            cell.dateLabel.text = @"正在等待…";
        }
        return cell;
    } else {
        UploadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UploadCell"];
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

- (void)tapProgressButton:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
        //如果网络可用 该行开始下载，
    } else {
        btn.selected = YES;
        //该行暂停
    }
}

- (void)tapProgressView:(UITapGestureRecognizer *)recognizer
{
    _progressButton.hidden = NO;
}

- (void)downloadItem:(MainContentItem *)item
{
    if (!_request) {
        _request = [[NSMutableURLRequest alloc] init];
        _request.HTTPMethod = @"GET";
        _request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _request.timeoutInterval = 30;
    }
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
    NSString *urlString = [NSString stringWithFormat:@"%@cnddownload.cgi?path=%@&name=%@&sid=%@",HOST_URL,item.currentFolderPath,item.fileName,sid];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str1 = [urlString stringByAddingPercentEscapesUsingEncoding:enc];
    _request.URL = [NSURL URLWithString:str1];
  
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
//    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
//    if (!_connIsFinished) {
//        [connection scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
//    }
    [connection start];

/*
    _requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:_request];
    __weak typeof(self) weakSelf = self;
    NSInteger row = [[DownloadItemStore shareItemStore].downloadingItems indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    _currentDownloadingRow = row;
    
    [_requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [weakSelf updateProgressViewWithComplete:totalBytesRead totalToRead:totalBytesExpectedToRead bytesRead:bytesRead atIndexPath:indexPath];  //刷新进度条
    }];
    [_requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf parseDownloadXMLWithData:operation.responseData];
        [operation cancel];
        operation = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation != nil) {
            [operation cancel];
            operation = nil;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([error code] != NSURLErrorCancelled) {
            NSLog(@"下载失败:%@",error.localizedDescription);
        }
    }];
    
    [_requestOperation start];
*/
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (NSString *)downloadPathWithFileName:(NSString *)fileName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *downloadDir = [documentPath stringByAppendingPathComponent:DOWNLOAD_DIR];
    BOOL isDir = NO;
    BOOL isExisted = [manager fileExistsAtPath:downloadDir isDirectory:&isDir];
    if (!(isDir && isExisted)) {
        [manager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *downloadPath = [downloadDir stringByAppendingPathComponent:fileName];
    
    [manager createFileAtPath:downloadPath contents:nil attributes:nil];
    
    return downloadPath;

}
/*
#pragma mark 刷新进度条
- (void)updateProgressViewWithComplete:(long long)totalByteRead totalToRead:(long long)totalBytesExpectedToRead
                              bytesRead:(NSUInteger)bytesRead atIndexPath:(NSIndexPath *)indexPath
{
    MainContentItem *item = [[DownloadItemStore shareItemStore].downloadingItems objectAtIndex:indexPath.row];
    DownloadCell *cell = (DownloadCell*)[self.downloadTableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"%u",bytesRead);
  //    cell.sizeLabel.text = [NSString stringWithFormat:@"%iK/s",bytesRead/1024];
    MDRadialProgressView *progressView = nil;
    
    progressView = (MDRadialProgressView*)cell.accessoryView;
    _currentProgressCounter =  (NSInteger)((totalByteRead*100)/totalBytesExpectedToRead);    //0~100内整数
//    NSLog(@"%lli %lli %i",totalByteRead,totalBytesExpectedToRead,_currentProgressCounter);
  
//    NSLog(@"%i",_currentProgressCounter);
    progressView.progressCounter = _currentProgressCounter;
    
//    cell.dateLabel.text = item.fileSize;
    if (totalByteRead < 1000 ) {      //近似< 1K
        cell.dateLabel.text = [NSString stringWithFormat:@"%iB/%@",(int)totalByteRead,item.fileSize];
    } else if (totalByteRead >=1000 && totalByteRead <1024000) { //近似<1MB
        cell.dateLabel.text = [NSString stringWithFormat:@"%iK/%@",(int)(totalByteRead/1024),item.fileSize];
    } else if (totalByteRead >= 1024000 && totalByteRead <1024000000) { //近似>1MB
        cell.dateLabel.text = [NSString stringWithFormat:@"%.2fM/%@",totalByteRead/1024000.0,item.fileSize];
    } else {
        cell.dateLabel.text = [NSString stringWithFormat:@"%.2G/%@",totalByteRead/1024000000.0,item.fileSize];
    }
    
    if (!_receivedData) {
        _receivedData = [[NSMutableData alloc] init];
    }
    [_receivedData appendData:_requestOperation.responseData];
}

- (void)parseDownloadXMLWithData:(NSData *)data
{
    UIImage *image = [UIImage imageWithData:data];
    MainContentItem *item = [[DownloadItemStore shareItemStore].downloadingItems objectAtIndex:_currentDownloadingRow];
    [[DownloadItemStore shareItemStore].downloadingItems removeObject:item];
    [[DownloadItemStore shareItemStore].downloadItems addObject:item];
    
    //更新tableView和itemStore
//    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    NSInteger downloadingCounts = [DownloadItemStore shareItemStore].downloadingItems.count;
//    NSInteger downloadCounts = [DownloadItemStore shareItemStore].downloadItems.count;
//    if (downloadingCounts == 0 && downloadCounts==1) { //downloadingCounts在这里一定>=1
//        
//        [self.downloadTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.downloadTableView insertRowsAtIndexPaths:@[firstIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    } else {
//        NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:_currentDownloadingRow inSection:0];
//        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:_currentDownloadingRow inSection:1];
//        [self.downloadTableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.downloadTableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error
  contextInfo: (void *) contextInfo;
{
//    [self createHUD];
//    UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/success.png"];
    
    if (error != NULL) {
        NSLog(@"保存照片失败：%@",error.localizedDescription);
//        [self showHUDWithImage:img messege:@"照片保存失败"];
    }else{
        NSLog(@"保存照片成功");
//        [self showHUDWithImage:img messege:@"照片保存成功"];
    };
}
*/
#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connIsFinished = YES;
    NSLog(@"请求下载失败:%@",error.localizedDescription);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    MainContentItem *item = [[DownloadItemStore shareItemStore].downloadingItems objectAtIndex:_currentDownloadingIndexPath.row];
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:[self.class downloadPathWithFileName:item.fileName]];
    
    if (!_receivedData) {
        _receivedData = [[NSMutableData alloc] initWithLength:0];
    }
//    [_receivedData setLength:0];
    _receivedLength = 0;
    _fileLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
    _receivedLength += data.length;
    
    if (_receivedData.length > MAX_BUFFER_LENGTH && _fileHandle!=nil) {
        [_fileHandle writeData:_receivedData];
//        [_receivedData setLength:0];    //
        _receivedData = nil;
        _receivedData = [[NSMutableData alloc] initWithLength:0];
    }


    if (_currentDownloadingIndexPath != nil) {    //如果界面没有显示时
        MainContentItem *item = [[DownloadItemStore shareItemStore].downloadingItems objectAtIndex:_currentDownloadingIndexPath.row];
        DownloadCell *cell = (DownloadCell*)[self.downloadTableView cellForRowAtIndexPath:_currentDownloadingIndexPath];
//        NSLog(@"receivdata");
//        MDRadialProgressView *progressView = nil;
//        
//        progressView = (MDRadialProgressView*)cell.accessoryView;
        _currentProgressCounter =  (NSInteger)((_receivedLength*100)/_fileLength);    //0~100内整数
//
        _progressView.progressCounter = _currentProgressCounter;
        
//        if (_receivedLength < 1000 ) {      //近似< 1K
//            cell.dateLabel.text = [NSString stringWithFormat:@"%iB/%@",(int)_receivedLength,item.fileSize];
//        } else if (_receivedLength >=1000 && _receivedLength <1024000) { //近似<1MB
//            cell.dateLabel.text = [NSString stringWithFormat:@"%.1fK/%@",(_receivedLength/1024.0),item.fileSize];
//        } else if (_receivedLength >= 1024000 && _receivedLength <1024000000) { //近似>1MB
//            cell.dateLabel.text = [NSString stringWithFormat:@"%.1fM/%@",_receivedLength/1024000.0,item.fileSize];
//        } else {
//            cell.dateLabel.text = [NSString stringWithFormat:@"%.1G/%@",_receivedLength/1024000000.0,item.fileSize];
//        }
    }

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _connIsFinished = YES;
    [_fileHandle writeData:_receivedData];
    [_fileHandle closeFile];
    _receivedData = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     NSLog(@"finish");
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

#pragma mark - 创建进度条
- (MDRadialProgressView *)progressViewWithFrame:(CGRect)frame
{
	MDRadialProgressView *view = [[MDRadialProgressView alloc] initWithFrame:frame];
    
    view.progressTotal = 100;
    view.progressCounter = 0; //放在外面
	view.theme.completedColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:1.0];
	view.theme.incompletedColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    view.theme.thickness = 10;
    view.theme.sliceDividerHidden = YES;
	view.theme.centerColor = [UIColor whiteColor];
    view.label.textColor = view.theme.completedColor ;
    
	return view;
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
