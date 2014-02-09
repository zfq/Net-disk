
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "Encryption.h"
#import "TBXML.h"
#import "AppDelegate.h"
#import "SSKeychain.h"
#import "Constant.h"

@interface RegisterViewController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UITextFieldDelegate>
{
    UITableView *registerView;
    BOOL registerEnable;
    
    NSURLConnection *connection;
    MBProgressHUD *HUD;
}
@end

@implementation RegisterViewController
@synthesize nameField1, pwdField1,emailField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=@"注册账号";
        
        registerEnable = NO;
        receivedData = [[NSMutableData alloc] init];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize size = [UIScreen mainScreen].bounds.size;
    registerView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
    registerView.delegate = self;
    registerView.dataSource = self;
    registerView.scrollEnabled = NO;
    registerView.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.view addSubview:registerView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(valueChanged)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
       
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// 第一栏返回2个cell，第二栏返回1个cell
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)  // 等于0，返回第一组，2行
        return 3;
    else
        return 1;  // 等于1，返回第二组，1行
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
                cell.textLabel.text = @"用户名"; // 设置label的文字
                cell.selectionStyle = UITableViewCellSelectionStyleNone; // 设置不能点击
                self.nameField1 = [[UITextField alloc] initWithFrame:CGRectMake(75, 7, 230, 30)];
                [self.nameField1 setBorderStyle:UITextBorderStyleNone]; //外框类型
                self.nameField1.placeholder = @"6-16位字母数字下划线";
                self.nameField1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                self.nameField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
                self.nameField1.clearButtonMode = YES; // 设置清楚按钮
                self.nameField1.autocorrectionType = UITextAutocorrectionTypeNo;
                self.nameField1.delegate = self;
                self.nameField1.returnKeyType = UIReturnKeyNext;
                [cell.contentView addSubview:self.nameField1];

                break;
            case 1:
                cell.textLabel.text = @"密 码";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.pwdField1 = [[UITextField alloc] initWithFrame:CGRectMake(75, 7, 230, 30)];
                [self.pwdField1 setBorderStyle:UITextBorderStyleNone]; //外框类型
                self.pwdField1.placeholder = @"至少6位";
                self.pwdField1.clearButtonMode = YES;
                self.pwdField1.secureTextEntry = YES;
                self.pwdField1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                self.pwdField1.delegate = self;
                self.pwdField1.returnKeyType = UIReturnKeyDone;
                [cell.contentView addSubview:self.pwdField1];
                break;
            default:
                cell.textLabel.text = @"邮 箱";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(75, 7, 230, 30)];
                [self.emailField setBorderStyle:UITextBorderStyleNone]; //外框类型
                self.emailField.clearButtonMode = YES;
                self.emailField.tag = 3;
                self.emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                self.emailField.delegate = self;
                self.emailField.returnKeyType = UIReturnKeyDone;
                self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
                [cell.contentView addSubview:self.emailField];
                break;
    
        }
    }else {  // 设置第二组注册框内容
        cell.textLabel.text = @"注    册";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:0.18f green:0.67f blue:0.84f alpha:1.0f];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row==0) {
            if (registerEnable) {
                [registerView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                
                [registerView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
                return nil;
            }
        }
    }
    return indexPath;
}

#pragma mark - 点击注册
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0) {
        if (indexPath.row == 0) {
            [self tapRegister];
        }
    }
}

- (void)tapRegister
{
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    HUD.labelText = @"请稍后…";
    [self.view addSubview:HUD];
    [HUD show:YES];
    
    [self dismissKeyboard];
    
    //获取加密后的字符串
    NSString *name = [Encryption encrypt:nameField1.text];
    NSString *pwd  = [Encryption encrypt:pwdField1.text];
    NSString *email = [Encryption encrypt:emailField.text];
    
    xml = nil;
    NSString *httpURLString = [NSString stringWithFormat:@"cndregister.cgi?name=%@&pwd=%@&email=%@",name,pwd,email];
    NSURL *url = [NSURL URLWithString:[HOST_URL stringByAppendingString:httpURLString]];
    urlRequest = [self xmlGetRequestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
}

- (void)dismissKeyboard
{
    [nameField1 resignFirstResponder];
    [pwdField1 resignFirstResponder];
    [emailField resignFirstResponder];
}

- (void)valueChanged
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    CGRect rect = [registerView cellForRowAtIndexPath:indexPath].frame;
    UIView *view = [[UIView alloc] initWithFrame:rect];
    
    BOOL b1 = [nameField1.text isEqualToString:@""];
    BOOL b2 = [pwdField1.text isEqualToString:@""];
    BOOL b3 = [emailField.text isEqualToString:@""];

    if (b1 || b2 || b3
        || nameField1.text==nil
        || pwdField1.text == nil
        || emailField.text == nil)
    {
        [registerView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor colorWithRed:0.18f green:0.67f blue:0.84f alpha:1.0f];
        [registerView cellForRowAtIndexPath:indexPath].selectedBackgroundView = view;
        registerEnable = NO;
    }
    else
    {
        [registerView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f];
        
        view.backgroundColor = [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0];
        [registerView cellForRowAtIndexPath:indexPath].selectedBackgroundView = view;
        registerEnable = YES;
    }

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

#pragma mark - 请求url

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
        [self showHUDWithMessage:@"请求超时!"];
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
    }
    
    [self parseRegisterXML];
}

#pragma mark -解析xml
- (void)parseRegisterXML
{
    TBXMLElement *root = xml.rootXMLElement;
    
    TBXMLElement *loginNode = [TBXML childElementNamed:@"Register" parentElement:root];
    TBXMLElement *statusNode = [TBXML childElementNamed:@"Status" parentElement:loginNode];
    
    //获取error信息
    TBXMLAttribute *statusAttribute = statusNode->firstAttribute;
    NSString *errorNum =[NSString stringWithCString:statusAttribute->value encoding:NSUTF8StringEncoding];

    if ([errorNum isEqualToString:@""]) {
        //保存信息
        [self saveUserInfo];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if ([errorNum isEqualToString:@"02001003"])
            [self showHUDWithMessage:@"邮箱地址无效!"];
        else if ([errorNum isEqualToString:@"02001001"])
            [self showHUDWithMessage:@"用户名无效!"];
        else if ([errorNum isEqualToString:@"02001002"])
            [self showHUDWithMessage:@"无效的密码!"];
        else
            [self showHUDWithMessage:@"该用户已存在!"];
    }
}

#pragma mark 保存信息
- (void)saveUserInfo
{
    
    [SSKeychain setPassword:nameField1.text forService:ServiceName account:pwdField1.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL b1 = [nameField1.text isEqualToString:@""];
    BOOL b2 = [pwdField1.text isEqualToString:@""];
    BOOL b3 = [emailField.text isEqualToString:@""];
    
    if (b1 || b2 || b3
        || nameField1.text==nil
        || pwdField1.text == nil
        || emailField.text == nil)
    {
        return YES;
    } else {
        [self tapRegister];
        return YES;
    }
}

@end





