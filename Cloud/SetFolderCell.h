//
//  SetFolderCell.h
//  Cloud
//
//  Created by zzti on 13-12-6.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetFolderCellDelegate;

@interface SetFolderCell : UITableViewCell
{
}

@property (nonatomic,weak) id<SetFolderCellDelegate> sDelegate;
@property (nonatomic,weak) IBOutlet UIButton *downloadBtn;
@property (nonatomic,weak) IBOutlet UIButton *shareBtn;

- (IBAction)downloadFiles:(id)sender;
- (IBAction)shareFiles:(id)sender;

@end

@protocol SetFolderCellDelegate <NSObject>

@optional

- (void)tapDownloadButtonInSetFolderCell:(SetFolderCell *)cell;
- (void)tapShareButtonInSetFolderCell:(SetFolderCell *)cell;

@end