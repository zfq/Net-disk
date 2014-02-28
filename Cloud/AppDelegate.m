//
//  AppDelegate.m
//  Cloud
//
//  Created by zzti on 13-11-19.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "AppDelegate.h"

#import "ICETutorialController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

#import "MyFileViewController.h"
#import "UploadViewController.h"
#import "DownloadViewController.h"
#import "MoreViewController.h"

#import "Constant.h"
#import "SSKeychain.h"
#import "KKPasscodeLock.h"
#import "TBXML.h"
#import "Encryption.h"
#import "Reachability.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.isSuccessLogin = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"succeedLogin"];
    [[KKPasscodeLock sharedLock] setDefaultSettings];
    [KKPasscodeLock sharedLock].eraseOption = NO;
    
    NSDictionary *dictionary = [[SSKeychain accountsForService:ServiceName] objectAtIndex:0];
    NSString *account = [dictionary objectForKey:@"acct"];
    NSString *password = [SSKeychain passwordForService:ServiceName account:account];
    
    if ( [account isEqualToString:@""] || account == nil) {
        [self initLoginView];
        [self.viewController startScrolling];
        //        _navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
        [self.window setRootViewController:self.viewController];
    } else {
        [self initTabBarController];
        
        //设置navigationBar
        [[UINavigationBar appearance] setBarTintColor:NavigationBarColor];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        shadow.shadowOffset = CGSizeMake(0, 1);
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil, NSShadowAttributeName,
          [UIFont boldSystemFontOfSize:30.0], NSFontAttributeName, nil]];
        [self.window setRootViewController:_tbController];
       
        if (self.isSuccessLogin == NO && [self networkReachable]) { //[boolStr isEqualToString:@"NO"]
            [self loginAndConnectyWithAccount:account password:password];
        }
        [self addNetworkStateNotification];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
     KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
     vc.mode = KKPasscodeModeEnter;
     vc.delegate = self;
     
     dispatch_async(dispatch_get_main_queue(),^ {
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
     
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
     nav.modalPresentationStyle = UIModalPresentationFormSheet;
     nav.navigationBar.barStyle = UIBarStyleBlack;
     nav.navigationBar.opaque = NO;
     } else {
     nav.navigationBar.tintColor = _navigationController.navigationBar.tintColor;
     nav.navigationBar.translucent = _navigationController.navigationBar.translucent;
     nav.navigationBar.opaque = _navigationController.navigationBar.opaque;
     nav.navigationBar.barStyle = _navigationController.navigationBar.barStyle;
     }
     
     [_navigationController presentViewController:nav animated:NO completion:nil];
     });
     
     }
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)initTabBarController
{
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    MyFileViewController *myFileVC = [[MyFileViewController alloc] initWithDirectoryAtPath:ROOT_PATH];
    
    UINavigationController *nvcMyFile = [[UINavigationController alloc] initWithRootViewController:myFileVC];
    
    UploadViewController *uploadVC = [[UploadViewController alloc] init];
    UINavigationController *nvcUpload = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    
    DownloadViewController *downloadVC = [[DownloadViewController alloc] init];
    UINavigationController *nvcDownload = [[UINavigationController alloc] initWithRootViewController:downloadVC];
    
    MoreViewController *moreVC = [[MoreViewController alloc] init];
    UINavigationController *nvcMore = [[UINavigationController alloc] initWithRootViewController:moreVC];
    
    NSArray *viewControllers = [NSArray arrayWithObjects:nvcMyFile,nvcUpload,nvcDownload,nvcMore, nil];
    
    _tbController = [[UITabBarController alloc] init];
    _tbController.viewControllers = viewControllers;
}

- (void)initLoginView
{
    // Init the pages texts, and pictures.
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithSubTitle:@"Picture 1"
                                                            description:@"Champs-Elysées by night"
                                                            pictureName:@"tutorial_background_00@2x.jpg"];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithSubTitle:@"Picture 2"
                                                            description:@"The Eiffel Tower with\n cloudy weather"
                                                            pictureName:@"tutorial_background_01@2x.jpg"];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithSubTitle:@"Picture 3"
                                                            description:@"An other famous street of Paris"
                                                            pictureName:@"tutorial_background_02@2x.jpg"];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithSubTitle:@"Picture 4"
                                                            description:@"The Eiffel Tower with a better weather"
                                                            pictureName:@"tutorial_background_03@2x.jpg"];
    ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithSubTitle:@"Picture 5"
                                                            description:@"The Louvre's Museum Pyramide"
                                                            pictureName:@"tutorial_background_04@2x.jpg"];
    
    // Set the common style for SubTitles and Description (can be overrided on each page).
    ICETutorialLabelStyle *subStyle = [[ICETutorialLabelStyle alloc] init];
    [subStyle setFont:TUTORIAL_SUB_TITLE_FONT];
    [subStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [subStyle setLinesNumber:TUTORIAL_SUB_TITLE_LINES_NUMBER];
    [subStyle setOffset:TUTORIAL_SUB_TITLE_OFFSET];
    
    ICETutorialLabelStyle *descStyle = [[ICETutorialLabelStyle alloc] init];
    [descStyle setFont:TUTORIAL_DESC_FONT];
    [descStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [descStyle setLinesNumber:TUTORIAL_DESC_LINES_NUMBER];
    [descStyle setOffset:TUTORIAL_DESC_OFFSET];
    
    // Load into an array.
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPhone"
                                                                      bundle:nil
                                                                    andPages:tutorialLayers];
    } else {
        self.viewController = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPad"
                                                                      bundle:nil
                                                                    andPages:tutorialLayers];
    }
    
    // Set the common styles, and start scrolling (auto scroll, and looping enabled by default)
    [self.viewController setCommonPageSubTitleStyle:subStyle];
    [self.viewController setCommonPageDescriptionStyle:descStyle];
    
    __weak typeof(self) weakself = self;
    
    // Set button 1 action.
    [self.viewController setButton1Block:^(UIButton *button){
        LoginViewController *loginVc = [[LoginViewController alloc] init];
        UINavigationController *controller=[[UINavigationController alloc]initWithRootViewController:loginVc];
        [weakself.viewController presentViewController:controller animated:YES completion:nil];
    }];
    
    // Set button 2 action, stop the scrolling.
    
    [self.viewController setButton2Block:^(UIButton *button){
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        RegisterViewController *rv = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
        
        UINavigationController *controller=[[UINavigationController alloc]initWithRootViewController:loginVC];
        [controller pushViewController:rv animated:NO];
        [weakself.viewController presentViewController:controller animated:YES completion:nil];
    }];
}

- (void)loginAndConnectyWithAccount:(NSString *)account password:(NSString *)password
{
    NSString *act = [Encryption encrypt:account];
    NSString *pwd  = [Encryption encrypt:password];
    NSString *urlString = [NSString stringWithFormat:@"%@cndlogin.cgi?name=%@&pwd=%@",HOST_URL,act,pwd];
    [self asynchronousRequestWithURL:urlString];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - 创建request
- ( NSMutableURLRequest *)createRequestWithURL:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	[request setHTTPMethod:@"GET"];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    request.timeoutInterval = 60;
    
    return request;
}

#pragma mark 解析数据
- (void)parseLoginXMLWithData:(NSData *)data
{
    NSError *error = nil;
    TBXML  *xml = [[TBXML alloc] initWithXMLData:data error:&error];
    if (error != nil) {
        NSLog(@"loginxml错误:%@",error.localizedDescription);
        return;
    }
    TBXMLElement *root = xml.rootXMLElement;
    
    TBXMLElement *loginNode = [TBXML childElementNamed:@"Login" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:loginNode];
    
    //获取sid
    TBXMLElement *hdrNode = [TBXML childElementNamed:@"Hdr" parentElement:loginNode];
    NSString *sid = [NSString stringWithCString:hdrNode->firstAttribute->value encoding:NSUTF8StringEncoding];
    //获取verify
    TBXMLElement *verifyNode = [TBXML childElementNamed:@"Verify" parentElement:loginNode];
    NSString *verify = [NSString stringWithCString:verifyNode->text encoding:NSUTF8StringEncoding];
    
    //获取error信息
    TBXMLAttribute *statusAttribute = statusNode->firstAttribute;
    
    NSString *errorNum = [[NSString alloc] initWithCString:statusAttribute->value encoding:NSASCIIStringEncoding];
    if ([errorNum isEqualToString:@""]) {
        //保存sid和verify
        [[NSUserDefaults standardUserDefaults] setObject:sid forKey:@"Sid"];
        [[NSUserDefaults standardUserDefaults] setObject:verify forKey:@"Verify"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //解析connect
        NSString *connectString = [NSString stringWithFormat:@"%@cndconnect.cgi?sid=%@&verify=%@",HOST_URL,sid,verify];
        NSData *receiveData = [NSData dataWithContentsOfURL:[NSURL URLWithString:connectString]];
        [self parseConnectXMLWithData:receiveData];
    } else {
        NSError *error = nil;
        NSString *errorContent = [TBXML textForElement:statusNode error:&error];
        if (error == nil) {
            if ( errorContent!= nil ) {
                if ([errorNum isEqualToString:@"02001001"])
                    NSLog(@"用户名无效");
                else if ([errorNum isEqualToString:@"02001004"])
                    NSLog(@"密码错误");
                else if ([errorNum isEqualToString:@"02001005"])
                    NSLog(@"该用户不存在");
                else
                    NSLog(@"未知错误号:%@",errorNum);
            }
            
        }
    }
}

- (void)parseConnectXMLWithData:(NSData *)data
{
    NSError *error = nil;
    
    TBXML *xml = [[TBXML alloc] initWithXMLData:data error:&error];
    TBXMLElement *root = xml.rootXMLElement;
    
    TBXMLElement *connectNode = [TBXML childElementNamed:@"Connect" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:connectNode];
    
    //获取error信息
    NSString *errorNum = [NSString stringWithUTF8String:statusNode->firstAttribute->value];
    
    if (![errorNum isEqualToString:@""]) {
        NSLog(@"connect解析 错误号:%@",errorNum);
        //清除sid和verify
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Sid"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Verify"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"connecty失败");
    } else {
        //        self.isSuccessLogin = YES;
        NSLog(@"一切OK");
        //通知myFileViewController
       
        MyFileViewController *vc = [[MyFileViewController alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName: kLoginStatusChangedNotification object: vc];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"succeedLogin"];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_connection cancel];
    _connection = nil;
}

- (void)asynchronousRequestWithURL:(NSString *)urlString
{
    NSMutableURLRequest *connectRequest = [self createRequestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:connectRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError != nil) {
                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                   [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"succeedLogin"];
                                   self.isSuccessLogin = NO;
                                   NSLog(@"%@",connectionError.localizedDescription);
                               } else {
                                   [self parseLoginXMLWithData:data];
                               }
                           }];
}

- (void)addNetworkStateNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _internetReachability = [Reachability reachabilityForInternetConnection];
	[_internetReachability startNotifier];
    _wifiReachability = [Reachability reachabilityForLocalWiFi];
	[_wifiReachability startNotifier];
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
            NSLog(@"代理3g不可用");
            break;
        }
        case ReachableViaWWAN:
        {
            if (!self.isSuccessLogin) {
                NSDictionary *dictionary = [[SSKeychain accountsForService:ServiceName] objectAtIndex:0];
                NSString *account = [dictionary objectForKey:@"acct"];
                NSString *password = [SSKeychain passwordForService:ServiceName account:account];
                [self loginAndConnectyWithAccount:account password:password];
            }
            break;
            NSLog(@"代理3g可用");
        }
        case ReachableViaWiFi:
        {
            if (!self.isSuccessLogin) {
                NSDictionary *dictionary = [[SSKeychain accountsForService:ServiceName] objectAtIndex:0];
                NSString *account = [dictionary objectForKey:@"acct"];
                NSString *password = [SSKeychain passwordForService:ServiceName account:account];
                [self loginAndConnectyWithAccount:account password:password];
            }
            NSLog(@"代理wifi可用");
            break;
        }
    }
}

@end


