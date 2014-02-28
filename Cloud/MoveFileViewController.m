//
//  MoveFileViewController.m
//  Cloud
//
//  Created by zhaofuqiang on 14-2-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "MoveFileViewController.h"

@interface MoveFileViewController ()

@end

@implementation MoveFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,width , 60)];
//       UINavigationController
//        self.navigationController.navigationBar
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
