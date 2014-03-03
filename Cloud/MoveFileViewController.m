//
//  MoveFileViewController.m
//  自定义navigationBar
//
//  Created by zhaofuqiang on 14-2-25.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "MoveFileViewController.h"

@interface MoveFileViewController ()
{
    UINavigationItem *_item;
}
@end

@implementation MoveFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _leftItem = [[UINavigationItem alloc] init];
        self.customBarTintColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @"请选择移动位置";
//    label.textColor = self.customBarTintColor;
    label.textColor = [UINavigationBar appearance].tintColor;
    [label sizeToFit];
    CGSize size = label.frame.size;
    CGFloat titleViewWidth = 120;
    CGFloat titleViewHeight =45;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat x = (screenWidth-size.width)/2.0;
    x = x > 0 ? x : -x;
    label.frame = CGRectMake(x, 30, size.width, size.height); //
    
    //设置titleLabel
    self.titleLabel.text = self.navigationController.topViewController.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = [UINavigationBar appearance].tintColor;
    CGSize titleSize = self.titleLabel.frame.size;
    self.titleLabel.frame = CGRectMake((titleViewWidth-titleSize.width)/2.0, 15, titleSize.width, titleSize.height);
    
    _item = [[UINavigationItem alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-titleViewHeight)/2.0, 0, titleViewWidth, titleViewHeight)];

    [view addSubview:self.titleLabel];
    _item.titleView = view;

    _customBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    _customBar.delegate = self;
    [_customBar addSubview:label];
    [_customBar setItems:@[_item] animated:NO];
//    [_customBar setBarTintColor:[UIColor colorWithRed:0.145 green:0.56 blue:0.913 alpha:1.0]];
    [_customBar setBarTintColor:[UINavigationBar appearance].barTintColor];
    [self.view addSubview:_customBar];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.navigationController != nil) {
        NSInteger prevIndex = self.navigationController.viewControllers.count-2;
        if (prevIndex >=0) {
            UINavigationController *prevViewController = [self.navigationController.viewControllers objectAtIndex:prevIndex];
            UIImage *backImg = [UIImage imageNamed:@"file_webback_narmal"];
            UIImageView *backImgView = [[UIImageView alloc] initWithImage:backImg];
            UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            backLabel.text = prevViewController.title;
            [backLabel sizeToFit];
            backLabel.textColor = self.navigationController.navigationBar.tintColor;
            CGSize backLabelSize = backLabel.frame.size;
            CGFloat width = backLabelSize.width > 110 ? 110 :backLabelSize.width;
            backLabel.frame = CGRectMake(20, 0, width, backLabelSize.height);

            UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10, 5, width+backImg.size.width, 25)];
            [backView addSubview:backImgView];
            [backView addSubview:backLabel];
            backView.userInteractionEnabled = NO;
            backView.exclusiveTouch = NO;
            UIButton *backBtn = [[UIButton alloc] init];
            backBtn.frame = backView.frame;
            [backBtn addSubview:backView];
            [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
            _item.leftBarButtonItem = backItem;
            
            self.navigationController.interactivePopGestureRecognizer.delegate = self;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
    return YES;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)test:(id)sender {
    MoveFileViewController *mvc = [[MoveFileViewController alloc] init];
//    mvc.customBarTintColor = [UIColor whiteColor];
    mvc.title = @"第二ge对对对";

    mvc.titleLabel.text = @"对对对";
    if (self.navigationController != nil) {
        [self.navigationController pushViewController:mvc animated:YES];
    }

}
@end
