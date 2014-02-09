//
//  AdviceViewController.h
//  SettingsExample
//
//  Created by lab on 13-12-2.
//  Copyright (c) 2013年 Rubber Duck Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIKeyboardViewController.h"

@interface AdviceViewController : UIViewController<UITableViewDelegate,UIKeyboardViewControllerDelegate>
{
    UIKeyboardViewController *keyBoardController;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UITextView *textView1;

@end
