//
//  SetFolderCell.m
//  Cloud
//
//  Created by zzti on 13-12-6.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "SetFolderCell.h"

@implementation SetFolderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)downloadFiles:(id)sender
{
    [_sDelegate tapDownloadButtonInSetFolderCell:self];
}

- (IBAction)shareFiles:(id)sender
{
    [_sDelegate tapShareButtonInSetFolderCell:self];
}
@end
