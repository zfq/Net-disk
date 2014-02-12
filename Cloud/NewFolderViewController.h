//
//  NewFolderViewController.h
//  Cloud
//
//  Created by zzti on 13-11-20.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewFolderViewControllerDelegate;

@interface NewFolderViewController : UIViewController<UITextFieldDelegate>
{
    __weak id<NewFolderViewControllerDelegate> _nDelegate;
}

@property (nonatomic,weak) id<NewFolderViewControllerDelegate> nDelegate;

@property (nonatomic,strong) UIView *cellView;
@property (nonatomic,strong) UITextField *folderName;

- (IBAction)tapBackground:(id)sender;
@end

@protocol NewFolderViewControllerDelegate <NSObject>

@optional

- (void)cancelNewFolder:(NewFolderViewController *)nfvc;
- (void)completeNewFolder:(NewFolderViewController *)nfvc;

@end