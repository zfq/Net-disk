//
//  UploadViewController.m
//  Cloud
//
//  Created by zzti on 13-11-12.
//  Copyright (c) 2013年 zzti. All rights reserved.
//
#import "CTAssetsPickerController.h"
#import "UploadViewController.h"
#import "UploadCell.h"
#import "UploadItemStore.h"
#import "Constant.h"
#import "AFNetworking.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "Reachability.h"
#import "TBXML.h"

@interface UploadViewController ()<UIActionSheetDelegate>
{
    NSMutableURLRequest *_request;
    UILabel *_uploadingLabel;
    UILabel *_uploadedLabel;
    BOOL _shouldBegin;
    BOOL _isMutableSelect;
    NSInteger _currentProgressCounter;
    AFHTTPRequestOperation *_requestOperation;
    
    Reachability *_internetReachability;
    Reachability *_wifiReachability;
    
    MDRadialProgressView *_progressView;
    UIView *_bottomDeleteView;
    
    NSMutableArray *_selectedIndexpath;
}

@end

@implementation UploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"上传列表" image:[UIImage imageNamed:@"upload.png"] tag:1];
        self.tabBarItem = tabBarItem;
        self.navigationItem.title = tabBarItem.title;
        UIBarButtonItem *select = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(showMenuView:withEvent:)];
        UIBarButtonItem *mutableSelect = [[UIBarButtonItem alloc] initWithTitle:@"多选" style:UIBarButtonItemStylePlain target:self action:@selector(mutableSelect:)];
        self.navigationItem.leftBarButtonItem = select;
        self.navigationItem.rightBarButtonItem = mutableSelect;
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ";
        
        _request = nil;
        _shouldBegin = YES;
        _isMutableSelect = NO;
        _currentProgressCounter = 0;
        _progressView = [self progressViewWithFrame:CGRectMake(0, 0, 40, 40)];
    }
    return self;
}

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.uploadTableView setTableFooterView:view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setExtraCellLineHidden:self.uploadTableView];
    UINib *nib = [UINib nibWithNibName:@"UploadCell" bundle:nil];
    [self.uploadTableView registerNib:nib forCellReuseIdentifier:@"UploadCell"];
    
    [[UploadItemStore sharedStore] setRefreshTableView:self.uploadTableView];
    CGFloat width = self.uploadTableView.bounds.size.width;
    _uploadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, width, 20.0)];
    _uploadingLabel.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1];
    _uploadingLabel.font = [UIFont systemFontOfSize:14.0];
    _uploadedLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, width, 20.0)];
    _uploadedLabel.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1];
    _uploadedLabel.font = [UIFont systemFontOfSize:14.0];
    
    [self addNotificationForNetStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeMenuView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    mvc = nil;
    _request = nil;
    _uploadedLabel = nil;
    _uploadingLabel = nil;
    _progressView = nil;
    _bottomDeleteView = nil;
}

- (void)showMenuView:(id)sender withEvent:(UIEvent*)senderEvent;
{
    if (mvc) {
        [self removeMenuView];
        return;
    }
    
    UIBarButtonItem *leftBtnItem = sender;
    if ([leftBtnItem.title isEqualToString:@"上传"]) {
        UIView *btnItemView = [[senderEvent.allTouches anyObject] view];
        mvc = [[FQMenuViewController alloc] init];
        mvc.delegate = self;
        CGRect rect = btnItemView.frame;
        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
        mvc.menuViewFrame = CGRectMake(rect.origin.x,rect.origin.y+rect.size.height+statusRect.size.height, 305, 130);
        
        [mvc addUploadViewContent];
        
        [self.navigationController.view addSubview:mvc.view];
        gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeMenuView)];
        [self.view addGestureRecognizer:gestureRecognizer];

    } else if ([leftBtnItem.title isEqualToString:@"全选"]) {
        //全选
    }
    
}

#pragma mark 移除菜单视图
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

#pragma mark FQMenuViewController delegate 方法
- (void)tapPhoto:(FQMenuViewController *)fmvc
{
    if (!self.itemStore) {
        self.itemStore = [[UploadItemStore alloc] init];
    }
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self.itemStore;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)tapVideo:(id)sender
{
    if (!self.itemStore) {
        self.itemStore = [[UploadItemStore alloc] init];
    }
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allVideos];
    picker.delegate = self.itemStore;
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark CTAssetsViewController 上传的代理方法
- (void)tapUpload:(id)sender
{
    CTAssetsViewController *vc = sender;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableView delegate方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger uploadingCounts = [UploadItemStore sharedStore].uploadingItems.count;
    NSInteger uploadedCounts = [UploadItemStore sharedStore].uploadedItems.count;
    
    if (uploadingCounts == 0)
        _uploadingLabel.text = nil;
    else
        _uploadingLabel.text = [NSString stringWithFormat:@"正在上传（%i）",uploadingCounts];
    
    if (uploadedCounts == 0)
        _uploadedLabel.text = nil;
    else
        _uploadedLabel.text = [NSString stringWithFormat:@"已完成上传（%i）",uploadedCounts];
    
    if (section == 0) {
        return [UploadItemStore sharedStore].uploadingItems.count;
    } else {
        return [UploadItemStore sharedStore].uploadedItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UploadCell"];
    [self removeProgressViewInTableViewCell:cell];
    
    if (indexPath.section == 0) {
        ALAsset *asset = [[UploadItemStore sharedStore].uploadingItems objectAtIndex:indexPath.row];
        NSString *name = asset.defaultRepresentation.filename;
        [[UploadItemStore sharedStore].itemName setObject:name forKey:name];
        
        cell.thumbnailView.image = [UIImage imageWithCGImage:asset.thumbnail];
        cell.nameLabel.text = name;
        cell.sizeLabel.text = @"";
        if (indexPath.row == 0) {
            if ([self internetIsReachable])
                cell.dateLabel.text = [NSString stringWithFormat:@"%lliK",[asset.defaultRepresentation size]/1024];
            else
                cell.dateLabel.text = @"正在等待网络…";
            //添加进度条
            _progressView.progressCounter = _currentProgressCounter;
            cell.accessoryView = _progressView;
            
            if (_shouldBegin == YES) {
                [self uploadFileWithAsset:asset AtIndexPath:indexPath];
                _shouldBegin = NO;
            }
        } else {
            cell.dateLabel.text = @"正在等待…";
        }
        return cell;
    } else {
        ALAsset *asset = [[UploadItemStore sharedStore].uploadedItems objectAtIndex:indexPath.row];
        cell.thumbnailView.image = [UIImage imageWithCGImage:asset.thumbnail];
        
        NSString *name = asset.defaultRepresentation.filename;
        [[UploadItemStore sharedStore].itemName setObject:name forKey:name];
        cell.nameLabel.text = name;
        
        NSDate *nowDate = [NSDate date];
        NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
        [outFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *timeStr = [outFormat stringFromDate:nowDate];
        cell.dateLabel.text = timeStr;
        
        NSString *sizeStr = nil;
        long long size = [asset.defaultRepresentation size]/1024;
        if (size >= 1000)
            sizeStr = [NSString stringWithFormat:@"%.2fMB",[asset.defaultRepresentation size]/4120576.0];
        else
            sizeStr = [NSString stringWithFormat:@"%lliK",size];
        cell.sizeLabel.text = sizeStr;

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark - 如何让自定义的acessoryView自动缩进？？
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadCell *cell = (UploadCell*)[tableView cellForRowAtIndexPath:indexPath];
    CGRect labelFrame = cell.sizeLabel.frame;
    CGRect viewFrame = cell.accessoryView.frame;
    if (_isMutableSelect == YES) {
        cell.accessoryView.frame = CGRectMake(100, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
        if (indexPath.section == 1) {
            cell.sizeLabel.frame = CGRectMake(labelFrame.origin.x+25,labelFrame.origin.y , labelFrame.size.width, labelFrame.size.height);
        }

        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    } else {
        cell.accessoryView.frame = CGRectMake(viewFrame.origin.x+25, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
        if (indexPath.section == 0) {
            cell.sizeLabel.frame = CGRectMake(labelFrame.origin.x-25,labelFrame.origin.y , labelFrame.size.width, labelFrame.size.height);
        }
        
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            ALAsset *asset = [[UploadItemStore sharedStore].uploadingItems objectAtIndex:indexPath.row];
            NSString *fileName = asset.defaultRepresentation.filename;
            
            [[UploadItemStore sharedStore].uploadingItems removeObjectAtIndex:indexPath.row];
            [[UploadItemStore sharedStore].assetsPath removeObjectForKey:fileName];
            [[UploadItemStore sharedStore].itemName removeObjectForKey:fileName];
            [tableView deleteRowsAtIndexPaths:[ NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            if ([UploadItemStore sharedStore].uploadingItems.count == 0) {
                [_requestOperation cancel];
                _requestOperation = nil;
                [self.uploadTableView reloadData];
            } else if (indexPath.row == 0){
                [_requestOperation cancel];
                _requestOperation = nil;
                
                if ([UploadItemStore sharedStore].uploadingItems.count >0 ) {
                    [self continueUploadForView:tableView];
                }
              
                //添加进度条
//                CGFloat width = 40;
//                UploadCell *cell = (UploadCell*)[tableView cellForRowAtIndexPath:first];
//                CGRect frame = CGRectMake(cell.frame.size.width-10-width, (55-width)/2.0, width, width);
//                MDRadialProgressView *v = [self progressViewWithFrame:frame];
//                v.progressCounter = 0;
//                [cell.contentView addSubview:v];
            }
        } else {
            ALAsset *asset = [[UploadItemStore sharedStore].uploadedItems objectAtIndex:indexPath.row];
            NSString *fileName = asset.defaultRepresentation.filename;
            
            [[UploadItemStore sharedStore].uploadedItems removeObjectAtIndex:indexPath.row];
            [[UploadItemStore sharedStore].assetsPath removeObjectForKey:fileName];
            [[UploadItemStore sharedStore].itemName removeObjectForKey:fileName];
            [tableView deleteRowsAtIndexPaths:[ NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            if ([UploadItemStore sharedStore].uploadedItems.count == 0) {
                [self.uploadTableView reloadData];
            }
        }
    }
}

- (void)continueUploadForView:(UITableView *)tableView
{
    ALAsset *firstAsset = [[UploadItemStore sharedStore].uploadingItems objectAtIndex:0];
    NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView reloadRowsAtIndexPaths:@[first] withRowAnimation:UITableViewRowAnimationNone];
    [self uploadFileWithAsset:firstAsset AtIndexPath:first];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, tableView.bounds.size.width, 20.0)];
    customView.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
    if (section == 0) {
        if (_uploadingLabel.text == nil) {
            return nil;
        } else {
            [customView addSubview:_uploadingLabel];
            return customView;
        }
    } else {
        if (_uploadedLabel.text == nil) {
            return nil;
        } else {
            [customView addSubview:_uploadedLabel];
            return customView;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger uploadingCounts = [UploadItemStore sharedStore].uploadingItems.count;
    NSInteger uploadedCounts = [UploadItemStore sharedStore].uploadedItems.count;
    if (section == 0) {
        return uploadingCounts > 0 ? 20.0 : 0;
    } else {
        return uploadedCounts > 0 ? 20.0 : 0;
    }
}

#pragma mark - 选择行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEditing]) {
        if (_selectedIndexpath == nil) {
            _selectedIndexpath = [[NSMutableArray alloc] init];
        }
        [_selectedIndexpath addObject:indexPath];
        [self setDeleteButtonWithCount:_selectedIndexpath.count];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEditing]) {
        [_selectedIndexpath removeObject:indexPath];
        [self setDeleteButtonWithCount:_selectedIndexpath.count];
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

#pragma mark 移除进度条
- (void)removeProgressViewInTableViewCell:(UploadCell *)cell
{
    cell.accessoryView = nil;
}

#pragma mark 刷新进度条
- (void)updateProgressViewWithComplete:(NSInteger)progressCounter atIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [[UploadItemStore sharedStore].uploadingItems objectAtIndex:indexPath.row];
    UploadCell *cell = (UploadCell*)[self.uploadTableView cellForRowAtIndexPath:indexPath];
    MDRadialProgressView *progressView = nil;
    long long size = [asset.defaultRepresentation size]/1024;
   
    progressView = (MDRadialProgressView*)cell.accessoryView;
    progressView.progressCounter = progressCounter;
    _currentProgressCounter = progressCounter;
    
    if (progressCounter < 1000 && size < 1000) {
        cell.dateLabel.text = [NSString stringWithFormat:@"%lliK/%lliK",size*progressCounter/100,size];
    } else if (progressCounter < 1000 && size > 1000) {
        cell.dateLabel.text = [NSString stringWithFormat:@"%lliK/%.2fMB",size*progressCounter/100,size/1024.0];
    } else if (progressCounter > 1000 && size > 1000) {
        cell.dateLabel.text = [NSString stringWithFormat:@"%.2fMB/%.2fMB",size*progressCounter/102400.0,size/1024.0];
    }
}

#pragma mark - 上传
- (void)uploadFileWithAsset:(ALAsset *)asset AtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableURLRequest *request = nil;
    if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto) {
        request = [self httpHeaderForUploadImageWithAsset:asset AtIndexPath:indexPath];
    } else {
        request = [self httpHeaderForUploadVideoWithAsset:asset AtIndexPath:indexPath];
    }
    _requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;
    [_requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSInteger progressCounter = (int)((totalBytesWritten*100)/totalBytesExpectedToWrite);
        [weakSelf updateProgressViewWithComplete:progressCounter atIndexPath:indexPath];  //刷新进度条
    }];
    
    [_requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf parseUploadXMLWithData:operation.responseData];
        [operation cancel];
        operation = nil;

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation != nil) {
            [operation cancel];
            operation = nil;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([error code] != NSURLErrorCancelled) {
             NSLog(@"上传失败:%@",error);
        }
    }];
    
    [_requestOperation start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - 解析上传结果
- (void)parseUploadXMLWithData:(NSData *)data
{
    TBXML *xml = [[TBXML alloc] initWithXMLData:data error:nil];
    TBXMLElement *root = [xml rootXMLElement];
    TBXMLElement *uploadNode = [TBXML childElementNamed:@"Upload" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:uploadNode];
    NSString *errorNum = [NSString stringWithCString:statusNode->firstAttribute->value encoding:NSUTF8StringEncoding];
    if ([errorNum isEqualToString:@""]) {
        
        ALAsset *asset = [[UploadItemStore sharedStore].uploadingItems objectAtIndex:0];
        [[UploadItemStore sharedStore].uploadingItems  removeObject:asset];
        NSIndexPath *uploadingIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *uploadedIndexPath = [NSIndexPath indexPathForRow:[UploadItemStore sharedStore].uploadedItems.count inSection:1];
        [self.uploadTableView beginUpdates];
        [self.uploadTableView deleteRowsAtIndexPaths:@[uploadingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [[UploadItemStore sharedStore].uploadedItems addObject:asset];
        [self.uploadTableView insertRowsAtIndexPaths:@[uploadedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.uploadTableView endUpdates];
        
        if ([UploadItemStore sharedStore].uploadingItems.count == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            _request = nil;
            _shouldBegin = YES;
        } else {
            [self.uploadTableView reloadRowsAtIndexPaths:@[uploadingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            //在这里请求
            ALAsset *firstAsset = [[UploadItemStore sharedStore].uploadingItems objectAtIndex:0];
            [self uploadFileWithAsset:firstAsset AtIndexPath:uploadingIndexPath];
        }
    } else {
        NSLog(@"上传返回数据错误%@",errorNum);
    }
    
    //从_selectIndexpath中删除之前选择的正在上传的cell
    [_selectedIndexpath removeObject:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (NSMutableURLRequest *)httpHeaderForUploadImageWithAsset:(ALAsset *)asset AtIndexPath:(NSIndexPath *)indexPath
{
    //分界线的标识符
    NSString *boundary = @"AaB03x";
    //根据url初始化request
    NSString *url = [NSString stringWithFormat:@"%@cndupload.cgi",HOST_URL];
    if (!_request) {
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:30];
        [_request setHTTPMethod:@"POST"];
    }
    
    //分界线 --AaB03x
    NSString *beginBoundary=[[NSString alloc]initWithFormat:@"--%@",boundary];
    NSString *endBoundary=[[NSString alloc]initWithFormat:@"%@--",beginBoundary];
    //要上传的图片
    CGImageRef imageRef = asset.defaultRepresentation.fullResolutionImage;
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    NSData *imgData = nil;
    NSString *imgName = asset.defaultRepresentation.filename;
    NSString *imgExtetion = [imgName pathExtension]; //文件扩展名
    if ([imgExtetion isEqualToString:@"JPG"] || [imgExtetion isEqualToString:@"jpg"]) {
        imgData = UIImageJPEGRepresentation(image, 1.0);
    } else {
        imgData = UIImagePNGRepresentation(image);
    }
   
    NSString *uploadPath = @"/";
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"]; 
    NSMutableData *bodyData = [NSMutableData data];
    NSDictionary *paramters = [[NSDictionary alloc] initWithObjectsAndKeys:uploadPath,@"path",sid,@"sid", nil];//imgName,@"name",
    
    for (NSString *param in paramters) {
        [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n",beginBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",param]  dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n", [paramters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n",beginBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",imgName] dataUsingEncoding:NSUTF8StringEncoding]];
    if ([imgExtetion isEqualToString:@"JPG"] || [imgExtetion isEqualToString:@"jpg"]) {
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n",imgExtetion] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [bodyData appendData:imgData];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n",endBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [_request setHTTPBody:bodyData];
    
    //设置HTTPHeader
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [_request setValue:content forHTTPHeaderField:@"Content-Type"];
    [_request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    return _request;
}

- (NSMutableURLRequest *)httpHeaderForUploadVideoWithAsset:(ALAsset *)asset AtIndexPath:(NSIndexPath *)indexPath
{
    //分界线的标识符
    NSString *boundary = @"AaB03x";
    //根据url初始化request
    NSString *url = [NSString stringWithFormat:@"%@cndupload.cgi",HOST_URL];
    if (!_request) {
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:30];
        [_request setHTTPMethod:@"POST"];
    }
    
//    NSString *path = NSTemporaryDirectory();
//    [UploadViewController writeDataToPath:path andAsset:asset];
    
//    NSInputStream *videoStream = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] objectForKey:NSFileSize];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc(rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    NSData *videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    
    //分界线 --AaB03x
    NSString *beginBoundary=[[NSString alloc]initWithFormat:@"--%@",boundary];
    NSString *endBoundary=[[NSString alloc]initWithFormat:@"%@--",beginBoundary];
    //要上传的视频
    NSURL *videoURL = asset.defaultRepresentation.url;
    NSLog(@"%@",[videoURL absoluteString]);
    NSString *videoName = asset.defaultRepresentation.filename;
//    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    
    NSString *uploadPath = @"/";
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
    NSMutableData *bodyData = [NSMutableData data];
    NSDictionary *paramters = [[NSDictionary alloc] initWithObjectsAndKeys:uploadPath,@"path",sid,@"sid", nil];//imgName,@"name",
    
    for (NSString *param in paramters) {
        [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n",beginBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",param]  dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n", [paramters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n",beginBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",videoName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: video/quicktime\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
   
    [bodyData appendData:videoData];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n",endBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [_request setHTTPBody:bodyData];
    
    //设置HTTPHeader
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [_request setValue:content forHTTPHeaderField:@"Content-Type"];
    [_request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    return _request;
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

- (void)addNotificationForNetStatus
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
//    _internetReachability = [Reachability reachabilityForInternetConnection];
//	[_internetReachability startNotifier];
    
//    _wifiReachability = [Reachability reachabilityForLocalWiFi];
//	[_wifiReachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    switch (netStatus)
    {
        case NotReachable:
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//            [self createHUDWithCustomView];
//            UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/error.png"];
//            [self showHUDWithImage:img messege:@"当前网络不可用"];
            NSLog(@"上传页面网络不可用");
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"上传2G/3G网络可用！");
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"上传wifi可用");
            //如果有未完成的请求，则继续请求
            if ([UploadItemStore sharedStore].uploadingItems.count > 0) {
                _currentProgressCounter = 0;
                NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.uploadTableView reloadRowsAtIndexPaths:@[firstRow] withRowAnimation:UITableViewRowAnimationNone];
                //在这里请求
                ALAsset *firstAsset = [[UploadItemStore sharedStore].uploadingItems objectAtIndex:0];
                [self uploadFileWithAsset:firstAsset AtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
           
            break;
        }
    }
}

+ (BOOL)writeDataToPath:(NSString*)filePath andAsset:(ALAsset*)asset
{
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle*handle =[NSFileHandle fileHandleForWritingAtPath:filePath];
    if(!handle) {
        return NO;
    }
    static const NSUInteger BufferSize=1024*1024*8;  //设置1MB的缓存
    ALAssetRepresentation*rep =[asset defaultRepresentation];
    uint8_t*buffer = calloc(BufferSize,sizeof(*buffer));
    NSUInteger offset =0, bytesRead =0;
    
    do{
        @try{
            bytesRead =[rep getBytes:buffer fromOffset:offset length:BufferSize error:nil];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        }
        @catch(NSException*exception){
            free(buffer);
            return NO;
        }
     }while(bytesRead >0);
    
    free(buffer);
    return YES;
}

#pragma mark - 多选
- (void)mutableSelect:(id)sender
{
    UIBarButtonItem *rightBtnItem = sender;
    if ([rightBtnItem.title isEqualToString:@"多选"]) {
        _isMutableSelect = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        [self.navigationItem.leftBarButtonItem setTitle:@"全选"];
        [self.uploadTableView setEditing:YES animated:NO];
        [self hideTabBar:YES];
    } else if ([rightBtnItem.title isEqualToString:@"取消"]) {
        [self recover];
    }
}

- (void)recover
{
    _isMutableSelect = NO;
    [self.navigationItem.rightBarButtonItem setTitle:@"多选"];
    [self.navigationItem.leftBarButtonItem setTitle:@"上传"];
    [self.uploadTableView setEditing:NO animated:NO];
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

#pragma mark 删除所选行
- (void)deleteCell:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"仅移除上传记录,不会删除文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定删除" otherButtonTitles: nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        BOOL isExistUploadingCell = NO;
        NSMutableIndexSet *uploadingIndexes = [[NSMutableIndexSet alloc] init];
        NSMutableIndexSet *uploadedIndexes = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *indexpath in _selectedIndexpath) {
            if (indexpath.section == 0) {
                [uploadingIndexes addIndex:indexpath.row];
                if (indexpath.row == 0) {
                    isExistUploadingCell = YES;
                    [_requestOperation cancel];
                    _requestOperation = nil;
                }
            } else {
                [uploadedIndexes addIndex:indexpath.row];
            }
        }
        
        NSInteger uploadingCount = [UploadItemStore sharedStore].uploadingItems.count;
        NSInteger uploadedCount = [UploadItemStore sharedStore].uploadedItems.count;
        
        if (uploadingCount > 0) {
            [[UploadItemStore sharedStore].uploadingItems removeObjectsAtIndexes:uploadingIndexes];
        }
        if (uploadedCount > 0) {
            [[UploadItemStore sharedStore].uploadedItems removeObjectsAtIndexes:uploadedIndexes];
        }
        
        [self.uploadTableView deleteRowsAtIndexPaths:_selectedIndexpath withRowAnimation:UITableViewRowAnimationNone];
        if ([UploadItemStore sharedStore].uploadedItems.count == 0) {
            [self.uploadTableView reloadData];
        }
        [self recover];
        [_selectedIndexpath removeAllObjects];
        
        if (isExistUploadingCell && [UploadItemStore sharedStore].uploadingItems.count>0) {
            [self continueUploadForView:self.uploadTableView];
        }
    }
}

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

@end











