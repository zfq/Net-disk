//
//  MoreViewController.h
//  Cloud
//
//  Created by zzti on 13-11-12.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TBXML;
@interface MoreViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> //UUITableViewController
{
    NSMutableData *receivedData;
    NSMutableURLRequest *urlRequest;
    TBXML *xml;
}

@property (nonatomic,strong) UITableView *tableView;
@end
