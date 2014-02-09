//
//  UploadViewController.h
//  Cloud
//
//  Created by zzti on 13-11-12.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQMenuViewController.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsViewController.h"
@class UploadItemStore;


@interface UploadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,
    FQMenuViewControllerDelegate,CTAssetsViewControllerDelegate> //,CTAssetsPickerControllerDelegate
{
    FQMenuViewController *mvc;
    UITapGestureRecognizer *gestureRecognizer;
}

@property (nonatomic,weak)    IBOutlet UITableView *uploadTableView;
//@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) UploadItemStore *itemStore;

- (void)setExtraCellLineHidden:(UITableView *)tableView;
- (void)ShowMenuView:(id)sender withEvent:(UIEvent*)senderEvent;
- (void)removeMenuView;

@end
