//
//  SetMainContentCell.m
//  Cloud
//
//  Created by zzti on 13-12-4.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "SetMainContentCell.h"

@implementation SetMainContentCell

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

- (IBAction)saveFile:(id)sender
{
    [_sDelegate tapSaveButtonInSetMainContentCell:self];
}

- (IBAction)shareFile:(id)sender
{
    [_sDelegate tapShareButtonInSetMainContentCell:self];
}

- (IBAction)deleteFile:(id)sender
{
    [_sDelegate tapDeleteButtonInSetMainContentCell:self];
}

- (IBAction)moreFile:(id)sender
{
    [_sDelegate tapMoreButtonInSetMainContentCell:self];
}
@end
