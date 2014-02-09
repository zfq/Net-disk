//
//  MoreViewController.m
//  Cloud
//
//  Created by zzti on 13-11-12.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "MoreViewController.h"
#import "SwitchDetailCell.h"
#import "SwitchCell.h"
#import "ProgressCell.h"

#import "AdviceViewController.h"
#import "AppDelegate.h"
#import "SSKeychain.h"
#import "Constant.h"
#import "LoginViewController.h"
#import "ICETutorialController.h"

#import "TBXML.h"
//#import "NetworkState.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "URLOperation.h"
#import "KKPasscodeSettingsViewController.h"
#import "KKPasscodeLock.h"

@interface MoreViewController ()<UIActionSheetDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,URLOperationDelegate,UINavigationControllerDelegate>
{
    NSURLConnection *connection;
    MBProgressHUD *HUD;
    Reachability *_internetReachability;
    Reachability *_wifiReachability;
    NSOperationQueue *_queue;

    NSString *_maxSpace;
    NSString *_usedSpace;
    BOOL    _getSpaceFail;

    URLOperation *_operation;
}

- (NSString *)getAccount;

@end

@implementation MoreViewController
@synthesize tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"更多" image:[UIImage imageNamed:@"layes.png"] tag:3];
        self.tabBarItem = tabBarItem;
        self.title = @"更多";
        
        _getSpaceFail = NO;
        
    #ifdef IOS7_SDK_AVAILABLE
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    #endif
    }
    return self;
}

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.navigationController.delegate = self;
    UINib *switchCellNib = [UINib nibWithNibName:@"SwitchCell" bundle:nil];
    [self.tableView registerNib:switchCellNib forCellReuseIdentifier:@"SwitchCell"];
    
    UINib *switchDetailCellNib = [UINib nibWithNibName:@"SwitchDetailCell" bundle:nil];
    [self.tableView registerNib:switchDetailCellNib forCellReuseIdentifier:@"SwitchDetailCell"];
    
    UINib *progressCellNib = [UINib nibWithNibName:@"ProgressCell" bundle:nil];
    [self.tableView registerNib:progressCellNib forCellReuseIdentifier:@"ProgressCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _internetReachability = [Reachability reachabilityForInternetConnection];
	[_internetReachability startNotifier];
    
    _wifiReachability = [Reachability reachabilityForLocalWiFi];
	[_wifiReachability startNotifier];
    
    NetworkStatus wifiStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (wifiStatus == NotReachable && internetStatus == NotReachable) {
        [self createHUDWithCustomView];
        UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/error.png"];
        [self showHUDWithImage:img messege:@"当前网络不可用"];
        
        _getSpaceFail = YES;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        //获取space
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self getAvailebleSpace];
    }
}

#pragma mark - 获取space
- (void)getAvailebleSpace
{
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
    NSString *str = [NSString stringWithFormat:@"cndspace.cgi?sid=%@",sid];
    NSString *httpURLString = [HOST_URL stringByAppendingString:str];
    
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
    }
    if (_operation == nil) {
        _operation = [[URLOperation alloc] initWithURLString:httpURLString];
        _operation.uDelegate = self;
    }
    
   
    [_queue addOperation:_operation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark tableView代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 3;
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4; //
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [self setValueAtFirstSection:indexPath];
            break;
        case 1:
            return [self setValueAtSecondSection:indexPath];
            break;
        case 2:
            return [self setValueAtThirdSection:indexPath];
            break;
        case 3:
            return [self setValueAtFourthSection:indexPath];
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row <2) {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }else if (indexPath.section == 1) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

}

#pragma mark 选中某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 2) {
                //push购买容量视图
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    //push本地空间清理
                    break;
                case 1:
                    //push密码锁
                {
                    self.hidesBottomBarWhenPushed = YES;
                    KKPasscodeSettingsViewController *set =[[KKPasscodeSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:set animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                }
                    break;
                case 2:
                    //push分享账号绑定
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    //push用户反馈
                {
                    self.hidesBottomBarWhenPushed = YES;
                    AdviceViewController *avc = [[AdviceViewController alloc] init];
                    [self.navigationController pushViewController:avc animated:YES];
                    self.hidesBottomBarWhenPushed = NO;
                }
                    break;
                case 1:
                    //push开源组件声明
                    break;
                case 2:
                    //push关于
                    break;
                default:
                    break;
            }

            break;
        default:
            break;
    }
}

#pragma mark 自定义header

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        UILabel *headerLabel = [[UILabel alloc] init];
        NSString *headerTitle = @"电脑搜索飞云,管理云端文件";
        headerLabel.text = headerTitle;
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont systemFontOfSize:12];
        CGSize size = [headerTitle sizeWithFont:headerLabel.font];
        headerLabel.frame = CGRectMake(0, 0, size.width, size.height);
        headerLabel.textAlignment = NSTextAlignmentCenter;
      
        return headerLabel;
    } else
        return nil;
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    } else {
        return 1;
    }
}

#pragma mark 自定义footer
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((self.tableView.frame.size.width-290)/2.0, 20, 290, 35);
        [btn setTitle:@"退出当前账号" forState:UIControlStateNormal];
        [btn setTitle:@"退出当前账号" forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"quit.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(quit:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width-290)/2.0, 0, 290, 75)];
        footerView.backgroundColor = [UIColor clearColor];
        [footerView addSubview:btn];
        
        return footerView;
    }
    else {
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 75;
    } else {
        return 20;
    }
}

#pragma mark 设置cell内容
- (UITableViewCell *)setValueAtFirstSection:(NSIndexPath *)indexPath
{
    UITableViewCell *cellValue1 = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleValue1"];
    if (!cellValue1){
        cellValue1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
    }
    ProgressCell *progressCell = [self.tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
    if (!progressCell) {
        progressCell = [[ProgressCell alloc] init];
    }
    
    switch (indexPath.row) {
        case 0:
            cellValue1.textLabel.text = @"飞云账号";
            cellValue1.detailTextLabel.text = [self getAccount];
            break;
        case 1:
        {
            //自定义cell,return cell
            if (_getSpaceFail == YES) {
                progressCell.label.text = @"读取失败";
                progressCell.label.textColor = [UIColor redColor];
                progressCell.progressView.progress = 0.0;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            } else if (_maxSpace == nil || [_maxSpace isEqualToString:@""]) {
                progressCell.label.text = @"正在读取";
                progressCell.detailLabel.hidden = YES;
                progressCell.progressView.progress = 0.0;
            } else {
                progressCell.label.text = @"容量";
                progressCell.detailLabel.hidden = NO;
                double maxByte = [_maxSpace doubleValue];
                double maxGB = maxByte/1073741824;
                double usedByte = [_usedSpace doubleValue];
                double usedGB = usedByte/1073741824;
            
                NSString *spaceString = [NSString stringWithFormat:@"(%.2lfG/%.2lfG %.2lf%%)",usedGB,maxGB,usedByte/maxByte];
                progressCell.detailLabel.text = spaceString;
                progressCell.progressView.progress = usedGB/maxGB;
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
            return progressCell;
        }
            break;
        case 2:
            cellValue1.textLabel.text = @"购买容量";
            cellValue1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    return cellValue1;
}

- (UITableViewCell *)setValueAtSecondSection:(NSIndexPath *)indexPath
{
    //wifi 相册备份
    SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    SwitchDetailCell *detailCell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchDetailCell"];
    
    if (indexPath.row == 0) {
        cell.label.text = @"仅在wifi下上传/下载";
        return cell;
    } else {
        detailCell.label.text = @"通讯录自动同步";
        
        //获取同步时间，这里仅仅用的是当前的时间
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *date = [dateFormatter stringFromDate:currentDate];
        detailCell.detailLabel.text = [NSString stringWithFormat:@"最近同步:%@",date];
        return detailCell;
    }
}

- (UITableViewCell *)setValueAtThirdSection:(NSIndexPath *)indexPath
{
    UITableViewCell *cellValue1 = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleValue1"];
    if (!cellValue1){
        cellValue1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
    }
    
    switch (indexPath.row) {
        case 0:
            cellValue1.textLabel.text = @"本地空间清理";
            break;
        case 1:
            cellValue1.textLabel.text = @"飞云密码锁";
            if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
                cellValue1.detailTextLabel.text = NSLocalizedString(@"开启", nil);
            } else {
                cellValue1.detailTextLabel.text = NSLocalizedString(@"关闭", nil);
            }
            break;
        case 2:
            cellValue1.textLabel.text = @"分享账号绑定";
            break;
        default: break;
    }
    cellValue1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cellValue1;
}

- (UITableViewCell *)setValueAtFourthSection:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleDefault"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleDefault"];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"意见反馈";
            break;
        case 1:
            cell.textLabel.text = @"开源组件声明";
            break;
        case 2:
            cell.textLabel.text = @"关于";
            break;
        default: break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark 获取账号
- (NSString *)getAccount
{
    NSDictionary *dictionary = [[SSKeychain accountsForService:ServiceName] objectAtIndex:0];
    NSString *account = [dictionary objectForKey:@"acct"];
    return account;
}

- (void)quit:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确认退出账号吗?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认退出" otherButtonTitles:nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NetworkStatus wifiStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (buttonIndex == 0) {
        if(wifiStatus == NotReachable && internetStatus == NotReachable)
        {
            [self createHUDWithCustomView];
            UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/error.png"];
            [self showHUDWithImage:img messege:@"设备没有联网!"];
        } else {
            xml = nil;
            NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"Sid"];
            NSString *logoutURLString = [NSString stringWithFormat:@"cndlogout.cgi?sid=%@",sid];
            NSURL *url = [NSURL URLWithString:[HOST_URL stringByAppendingString:logoutURLString]];
       
            urlRequest = [self xmlGetRequestWithURL:url];
            connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
            receivedData = [[NSMutableData alloc] init];
            
            if (HUD == nil) {
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
            }
            
            HUD.labelText = @"正在退出";
            [self.view addSubview:HUD];
            [HUD show:YES];
        }
    }
}

//url请求
- ( NSMutableURLRequest *)xmlGetRequestWithURL:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	[request setHTTPMethod:@"GET"];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    request.timeoutInterval = 60;
    
    return request;
}

#pragma mark -
#pragma mark NSURLConnection代理
//连接错误处理
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error != nil) {
        if (error.code == -1004) {
            [self showHUDWithMessage:@"无法连接到服务器"];
        } else {
            [self showHUDWithMessage:@"请求超时"];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}
//接收NSData数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

//接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    xml = [[TBXML alloc] initWithXMLData:receivedData error:&error];
    if (error != nil) {
        NSLog(@"%@",error.localizedDescription);
        return;
    }
    
    //解析结果
    if (![self parseLogoutXML]) {
        [self showHUDWithMessage:@"退出失败"];
    } else {
        NSDictionary *dictionary = [[SSKeychain accountsForService:ServiceName] objectAtIndex:0];
        NSString *account = [dictionary objectForKey:@"acct"];
        [SSKeychain deletePasswordForService:ServiceName account:account];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate initLoginView];
        [appDelegate.viewController startScrolling];
        [appDelegate.window setRootViewController:appDelegate.viewController];
        [appDelegate.window makeKeyAndVisible];
        
        appDelegate.tbController = nil;
    }
}

#pragma mark - 解析logout
- (BOOL)parseLogoutXML
{
    TBXMLElement *root = xml.rootXMLElement;
    
    TBXMLElement *logoutNode = [TBXML childElementNamed:@"Logout" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:logoutNode];
    
    //获取error信息
    NSError *error = nil;
    NSString *errorContent = [TBXML textForElement:statusNode error:&error];
    if (!error) {
        if ( errorContent!= nil ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 解析space
- (void)parseSpaceXMLWithData:(NSData *)data
{
    if (data == nil) {
        return;
    }
    if (xml == nil) {
        xml = [[TBXML alloc] initWithXMLData:data error:nil];
    }
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *spaceNode =[TBXML childElementNamed:@"Space" parentElement:root];
    TBXMLElement *diskNode =[TBXML childElementNamed:@"Disk" parentElement:spaceNode];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:spaceNode];
    
    //获取error
    TBXMLAttribute *errorNum = statusNode->firstAttribute;
    NSString *errorContent = [NSString stringWithUTF8String:errorNum->value];
    
    if ([errorContent isEqualToString:@""]) {
        TBXMLAttribute *max = diskNode->firstAttribute;
        TBXMLAttribute *used = max->next;
        
        _maxSpace = [NSString stringWithUTF8String:max->value];
        _usedSpace = [NSString stringWithUTF8String:used->value];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        //更新cell
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSString *formatError = [NSString stringWithFormat:@"获取空间出错:%@",errorContent];
        [self showHUDWithMessage:formatError];
        _getSpaceFail = YES;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark 显示提示框
- (void)createHUDWithCustomView
{
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeCustomView;
    }
}

- (void)showHUDWithImage:(UIImage *)image messege:(NSString *)string
{
    if (HUD==nil)
        return;
    HUD.customView = [[UIImageView alloc] initWithImage:image];
    HUD.labelText = string;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(3);
    } completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}

- (void)showHUDWithMessage:(NSString *)string
{
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeText;
    }
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = string;
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(3);
    } completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}

#pragma mark - URLOperation代理方法
- (void)completeDataReception:(NSData *)data
{
    [self parseSpaceXMLWithData:data];
}

- (void)errorInfo:(NSError *)error
{
    if (error != nil) {
        if (error.code == -1004) {
            [self showHUDWithMessage:@"无法连接到服务器"];
        } else {
            [self showHUDWithMessage:@"请求超时!"];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _getSpaceFail = YES;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        //更新cell
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            NSLog(@"更多页面wifi可用");
            if (_getSpaceFail == YES) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                [self getAvailebleSpace];
            }
            break;
        }
    }
}

@end











