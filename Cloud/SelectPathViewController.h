//
//  SelectPathViewController.h
//  Cloud
//
//  Created by zhaofuqiang on 13-11-30.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFolderViewController.h"

@protocol SelectPathViewControllerDelegate;
@class NewFolderViewController;
@class MyFileItemStore;

@interface SelectPathViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,
NewFolderViewControllerDelegate>
{
    NewFolderViewController *nfvc;
    __weak id<SelectPathViewControllerDelegate> _sDelegate;
}

@property (nonatomic,weak) id<SelectPathViewControllerDelegate> sDelegate;
@property (nonatomic,strong) UITableView *selectPathTableView;
@property (nonatomic,strong,getter = theNewFolderBtn) UIButton *newFolderBtn;

@property (nonatomic,strong) NSString *currentPath;
@property (nonatomic,strong) MyFileItemStore *itemSotre;
@property (nonatomic,strong) NSMutableDictionary *itemDictionaryStore;
@property (nonatomic,strong) NSString *navTitle;

- (SelectPathViewController *)initWithDirectoryAtPath:(NSString *)dirPath;
- (void)rebuildFileList:(NSString *)dirPath;

- (void)setExtraCellLineHidden:(UITableView *)tableView;
- (void)addToolbar;
@end

@protocol SelectPathViewControllerDelegate <NSObject>

@optional

- (void)selected:(SelectPathViewController *)spvc;
- (void)cancelSelect:(SelectPathViewController *)spvc;

@end
