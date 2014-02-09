//
//  UploadCell.h
//  Cloud
//
//  Created by zhaofuqiang on 14-1-23.
//  Copyright (c) 2014年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *thumbnailView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *sizeLabel;
@end
