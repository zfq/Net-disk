//
//  MainContentCell.h
//  Cloud
//
//  Created by zzti on 13-11-21.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainContentCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *thumbnailView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *sizeLabel;
@property (nonatomic,weak) IBOutlet UIButton *unfoldBtn;

@end

