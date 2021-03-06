//
//  NewFolderViewController.m
//  Cloud
//
//  Created by zzti on 13-11-20.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "NewFolderViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface NewFolderViewController ()

@end

@implementation NewFolderViewController

@synthesize nDelegate = _nDelegate;
@synthesize cellView;
@synthesize folderName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNew:)];
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeNew:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        self.navigationItem.title = @"新建文件夹";
        
        self.folderName = [[UITextField alloc] init];
        self.folderName.placeholder = @"输入新名称";
    }
    return self;
}


- (void)viewDidLoad
{
    CGFloat height = self.navigationController.navigationBar.frame.size.height;
    
    CGFloat y = height + self.navigationController.navigationBar.frame.origin.y;

    CGFloat cellWidth = 300;
    CGFloat cellHeight = 44;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        cellView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-cellWidth)/2.0, 20, 300, cellHeight)];
    else
        cellView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-cellWidth)/2.0, y+20, 300, cellHeight)];

    /*添加阴影*/
    CALayer *layer = [cellView layer];
    cellView.backgroundColor = [UIColor whiteColor];
    layer.shadowOffset = CGSizeMake(0, 2);
    layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    layer.shadowOpacity = 1.0; //必须设置，因为默认是0
    
    /*添加文件夹图标*/
    if (!self.folderImage) {
        self.folderImage = [UIImage imageNamed:@"mainFolder"];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, (cellHeight-self.folderImage.size.height)/2.0, self.folderImage.size.width, self.folderImage.size.height)];
    imageView.image = self.folderImage;
    [cellView addSubview:imageView];
    
    /*添加UITextField*/
    if ([self.folderName.text isEqualToString:@""]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    CGFloat fontHeight = [[UIFont systemFontOfSize:12] lineHeight]+8;
    self.folderName.frame = CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+15.0, (cellView.frame.size.height-fontHeight)/2.0, 240, fontHeight);
    
    folderName.clearButtonMode = UITextFieldViewModeWhileEditing;
    folderName.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(valueChanged)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    [cellView addSubview:folderName];
    
    [self.view addSubview:cellView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    folderName.text = @"";
    [self performSelector:@selector(showKeyBoard:) withObject:folderName afterDelay:0.3]; //让键盘延迟显示
}

- (void)valueChanged
{
    if ([folderName.text isEqualToString:@""])
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark 让键盘显示
- (void)showKeyBoard:(id)sender
{
    [sender becomeFirstResponder];
}

- (IBAction)tapBackground:(id)sender
{
    if (![folderName.text isEqualToString:@""]) {
          [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

#pragma mark 取消和完成按钮事件
- (void)cancelNew:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [_nDelegate cancelNewFolder:self];
}

- (void)completeNew:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
     [_nDelegate completeNewFolder:self];
}

#pragma mark - 实现UITextFieldDelegate方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        [textField resignFirstResponder];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        [_nDelegate completeNewFolder:self];
        return YES;
    }
    return NO;
}

@end







