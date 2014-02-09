//
//  AppDelegate.h
//  Cloud
//
//  Created by zhaofuqiang on 14-2-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeLock.h"

@class ICETutorialController;
@class LoginViewController;
@class TBXML;

@interface AppDelegate : UIResponder <UIApplicationDelegate,KKPasscodeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ICETutorialController *viewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) UITabBarController *tbController;

@property (strong,nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (nonatomic) BOOL isSuccessLogin;

- (void)initLoginView;
- (void)initTabBarController;
@end
