//
//  LoginViewController.m
//  ICETutorial
//
//  Created by lab on 13-11-19.
//  Copyright (c) 2013年 Patrick Trillsam. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ICETutorialController.h"
#import "TBXML.h"
#import "Encryption.h"
#import "NetworkState.h"
#import "MBProgressHUD.h"

#import "Constant.h"
#import "AppDelegate.h"
#import "SSKeychain.h"

@interface LoginViewController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UIApplicationDelegate>
{
    UITableView *loginView;
    NSURLConnection *connectionForLogin;
    MBProgressHUD *HUD;
}
@end

@implementation LoginViewController
@synthesize nameField, pwdField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"登陆";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goback)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登陆" style:UIBarButtonItemStylePlain target:self action:@selector(doLogin)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    CGSize size = [UIScreen mainScreen].bounds.size;
    loginView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
    loginView.delegate = self;
    loginView.dataSource = self;
    
    loginView.scrollEnabled = NO;
    loginView.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
   
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(75, 7, 230, 30)];
    [self.nameField setBorderStyle:UITextBorderStyleNone]; //外框类型
    self.nameField.placeholder = @"请输入账号";
    self.nameField.clearButtonMode = YES;
    self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameField.delegate = self;
    self.nameField.returnKeyType = UIReturnKeyNext;
    
    self.pwdField = [[UITextField alloc] initWithFrame:CGRectMake(75, 7, 230, 30)];
    [self.pwdField setBorderStyle:UITextBorderStyleNone]; //外框类型
    self.pwdField.placeholder = @"请输入密码";
    self.pwdField.clearButtonMode = YES;
    self.nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.pwdField.secureTextEntry = YES;
    pwdField.delegate = self;
    self.pwdField.returnKeyType = UIReturnKeyDone;
    
    [self.view addSubview:loginView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [loginView deselectRowAtIndexPath:[loginView indexPathForSelectedRow] animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(valueChanged)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    NSDictionary *dictionary = [[SSKeychain accountsForService:ServiceName] objectAtIndex:0];
    NSString *account = [dictionary objectForKey:@"acct"];
    if (account != nil) {
        nameField.text = account;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.returnKeyType == UIReturnKeyDone) {
        [self doLogin];
    }
    return YES;
}

- (void)valueChanged
{
    BOOL b1 = [nameField.text isEqualToString:@""];
    BOOL b2 = [pwdField.text isEqualToString:@""];
    
    if (b1 || b2 || nameField.text==nil || pwdField.text == nil)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}

// 登陆
- (void)doLogin
{
    [nameField resignFirstResponder];
    [pwdField resignFirstResponder];
   
    if(![NetworkState networkState])
    {
        [self createHUDWithCustomView];
         UIImage *img = [UIImage imageNamed:@"MBProgressHUD.bundle/error.png"];
        [self showHUDWithImage:img messege:@"设备没有联网!"];
    } else {
        //获取加密后的字符串
        NSString *name = [Encryption encrypt:nameField.text];
        NSString *pwd  = [Encryption encrypt:pwdField.text];

        NSString *httpURLString = [NSString stringWithFormat:@"cndlogin.cgi?name=%@&pwd=%@",name,pwd];
        NSURL *url = [NSURL URLWithString:[HOST_URL stringByAppendingString:httpURLString]];
//        NSLog(@"%@",url);
        urlRequest = [self createRequestWithURL:url];
        connectionForLogin = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
        receivedData = [[NSMutableData alloc] init];
    
        if (HUD == nil) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
        }
        HUD.labelText = @"正在登陆";
        [self.view addSubview:HUD];
        [HUD show:YES];
    }
}

 // 返回
-(void)goback
{
    [connectionForLogin cancel];
    connectionForLogin = nil;
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

// 到注册页面
- (void)doRegister
{
    [connectionForLogin cancel];
    connectionForLogin = nil;
    RegisterViewController *rv = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:rv animated:YES];
}

#pragma mark -
#pragma mark Table Data Source Methods
// 返回两栏table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// 第一栏返回2个cell，第二栏返回1个cell
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)  // 等于0，返回第一组，2行
        return 2;
    else
        return 1;  // 等于1，返回第二组，1行
}

// 设置tableview第二栏头文字内容
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return @"忘记密码？请点击这里>";
    return nil;
}

// 设置tableview第二栏头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return 20;
    return 0;
}

// 设置登陆框
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier = @"loginCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellWithIdentifier];
    }
    if (indexPath.section == 0) {  // 设置第一组的登陆框内容
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = @"账 号"; // 设置label的文字
                cell.selectionStyle = UITableViewCellSelectionStyleNone; // 设置不能点击
                [cell.contentView addSubview:self.nameField];
                break;
            default:
                cell.textLabel.text = @"密 码";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.contentView addSubview:self.pwdField];
                break;
        }
    } else {  // 设置第二组注册框内容
        cell.textLabel.text = @"赶快去注册吧！";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // 设置向>箭头
    }
    return cell;
}

// 用户点击注册
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 用户点击tableview第二栏，第一行的时候
    if (indexPath.section == 1 && [indexPath row] == 0)
    {
        [nameField resignFirstResponder];
        [pwdField resignFirstResponder];
        [self doRegister];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark 显示提示框
- (void)createHUDWithCustomView
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

- ( NSMutableURLRequest *)createRequestWithURL:(NSURL *)url
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error != nil) {
        if (error.code == -1004) {
            [self showHUDWithMessage:@"无法连接到服务器"];
        } else {
            [self showHUDWithMessage:@"请求超时!"];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseLoginXMLWithData:receivedData];
}

#pragma mark 解析数据
- (void)parseLoginXMLWithData:(NSData *)data
{
    NSError *error = nil;
    TBXML  *xml = [[TBXML alloc] initWithXMLData:receivedData error:&error];
    if (error != nil) {
        NSLog(@"%@",error.localizedDescription);
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
//        NSLog(@"%@",connectString);
        NSData *receiveData = [NSData dataWithContentsOfURL:[NSURL URLWithString:connectString]];
        [self parseConnectXMLWithData:receiveData];
    } else {
        NSError *error = nil;
        NSString *errorContent = [TBXML textForElement:statusNode error:&error];
        if (error == nil) {
            if ( errorContent!= nil ) {
                //用HUD提示框显示
                if ([errorNum isEqualToString:@"02001001"])
                    [self showHUDWithMessage:@"用户名无效!"];
                else if ([errorNum isEqualToString:@"02001004"])
                    [self showHUDWithMessage:@"密码错误!"];
                else if ([errorNum isEqualToString:@"02001005"])
                    [self showHUDWithMessage:@"该用户不存在!"];
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
        [self showHUDWithMessage:@"connecty失败"];
    } else {
        //保存用户名和密码
        [self saveUserInfo];
        
        //跳转主页面
        AppDelegate *appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.tbController == nil) {
            [appDelegate initTabBarController];
        }
        [self presentViewController:appDelegate.tbController animated:NO completion:nil];
        [self removeFromParentViewController];
    }
}

- (void)saveUserInfo
{
    [SSKeychain setPassword:pwdField.text forService:ServiceName account:nameField.text];
}

@end










