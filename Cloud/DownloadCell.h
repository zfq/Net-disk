//
//  DownloadCell.h
//  Cloud
//
//  Created by zhaofuqiang on 14-2-15.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *thumbnailView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *sizeLabel;

@end
