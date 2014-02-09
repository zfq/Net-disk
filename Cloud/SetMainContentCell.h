//
//  SetMainContentCell.h
//  Cloud
//
//  Created by zzti on 13-12-4.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetMainContentCellDelegate;

@interface SetMainContentCell : UITableViewCell
{
    
}

@property (nonatomic,weak) id<SetMainContentCellDelegate> sDelegate;
@property (nonatomic,weak) IBOutlet UIButton *saveBtn;
@property (nonatomic,weak) IBOutlet UIButton *shareBtn;
@property (nonatomic,weak) IBOutlet UIButton *deleteBtn;
@property (nonatomic,weak) IBOutlet UIButton *moreBtn;

- (IBAction)saveFile:(id)sender;
- (IBAction)shareFile:(id)sender;
- (IBAction)deleteFile:(id)sender;
- (IBAction)moreFile:(id)sender;

@end

@protocol SetMainContentCellDelegate <NSObject>

@optional

- (void)tapSaveButtonInSetMainContentCell:(SetMainContentCell *)cell;
- (void)tapShareButtonInSetMainContentCell:(SetMainContentCell *)cell;
- (void)tapDeleteButtonInSetMainContentCell:(SetMainContentCell *)cell;
- (void)tapMoreButtonInSetMainContentCell:(SetMainContentCell *)cell;

@end