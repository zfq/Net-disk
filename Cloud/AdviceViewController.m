//
//  adviceViewController.m
//  SettingsExample
//
//  Created by lab on 13-12-2.
//  Copyright (c) 2013年 Rubber Duck Software. All rights reserved.
//

#import "AdviceViewController.h"
#import "Constant.h"

@interface AdviceViewController ()
@end

@implementation AdviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGSize size = [UIScreen mainScreen].bounds.size;

    #ifdef IOS7_SDK_AVAILABLE
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    #endif
        
        self.title=@"意见反馈";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(doLogin)];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake((size.width-294)/2.0, 30, 294, 150)];
        _textView1 = [[UITextView alloc] initWithFrame:CGRectMake((size.width-294)/2.0, 200, 294, 35)];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	keyBoardController=[[UIKeyboardViewController alloc] initWithControllerDelegate:self];
	[keyBoardController addToolbarToKeyboard];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView.layer.borderWidth =0.5;
    self.textView.layer.cornerRadius = 3.0;
    self.textView1.backgroundColor = [UIColor whiteColor];
    self.textView1.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView1.layer.borderWidth =0.5;
    self.textView1.layer.cornerRadius = 3.0;
    self.textView1.keyboardType = UIKeyboardTypeEmailAddress;
    _textView.text = @"留下意见,我们将为您不断改进:";
    _textView1.text = @"您的邮箱:";
    
    [self.view addSubview:_textView];
    [self.view addSubview:_textView1];
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end




















