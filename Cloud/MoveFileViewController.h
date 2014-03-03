//
//  MoveFileViewController.h
//  自定义navigationBar
//
//  Created by zhaofuqiang on 14-2-25.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoveFileViewController : UIViewController<UINavigationBarDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UINavigationItem *leftItem;
@property (nonatomic,strong) UINavigationBar *customBar;
@property (nonatomic,strong) UIColor *customBarTintColor;   //默认是黑色

- (IBAction)test:(id)sender;

@end
