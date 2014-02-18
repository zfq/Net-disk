//
//  MyFileViewController.h
//  Cloud
//
//  Created by zzti on 13-11-12.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQMenuViewController.h"
#import "NewFolderViewController.h"
#import "RefreshView.h"

@class MyFileItemStore;
@protocol MyFileViewControllerDelegate;
@interface MyFileViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
FQMenuViewControllerDelegate,NewFolderViewControllerDelegate,UISearchDisplayDelegate>
{
    FQMenuViewController *mvc;
//    NewFolderViewController *nfvc;
    UITapGestureRecognizer *gestureRecognizer;
}

@property (nonatomic,weak) IBOutlet UITableView *myFileTableView;
@property (nonatomic, strong) RefreshView *refreshView;
@property (nonatomic,strong) UISearchDisplayController *searchDisplayController;

@property (nonatomic,strong) MyFileItemStore *itemSotre;
@property (nonatomic,strong) NSMutableDictionary *itemDictionaryStore;  //文件 forkey filename

@property (nonatomic,strong) NSString *currentPath;
@property (nonatomic,strong) NSString *navTitle;

@property (nonatomic,weak) id<MyFileViewControllerDelegate> mfvcDelegate;

- (MyFileViewController *)initWithDirectoryAtPath:(NSString *)dirPath;
- (void)rebuildFileList:(NSString *)dirPath;

- (void)setExtraCellLineHidden:(UITableView *)tableView;
- (void)showMenuView:(id)sender withEvent:(UIEvent*)senderEvent;
- (void)mutableSelect:(id)sender;
- (void)removeMenuView;

@end

@protocol MyFileViewControllerDelegate <NSObject>
@optional
- (void)downloadItem:(MyFileViewController *)viewController;

@end