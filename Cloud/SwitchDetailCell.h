//
//  SwitchDetailCell.h
//  Cloud
//
//  Created by zhaofuqiang on 13-12-27.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchDetailCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *label;
@property (nonatomic,weak) IBOutlet UILabel *detailLabel;
@property (nonatomic,weak) IBOutlet UISwitch *toggle;
@end
