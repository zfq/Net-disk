//
//  MainContentCell.m
//  Cloud
//
//  Created by zzti on 13-11-21.
//  Copyright (c) 2013年 zzti. All rights reserved.


#import "MainContentCell.h"

@implementation MainContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    UILabel *separatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-1.2, 320, 1.2)];
//    separatorLabel.backgroundColor = [UIColor lightGrayColor];
    
    float indentPoints = self.indentationLevel * self.indentationWidth;
    self.contentView.frame = CGRectMake(
                                        indentPoints,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width - indentPoints,
                                        self.contentView.frame.size.height
                                        );
    if (self.editing) {
        self.contentView.frame = CGRectMake(35, self.contentView.frame.origin.y, self.contentView.frame.size.width - 35, self.contentView.frame.size.height);
    } else {
        self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
   
}


@end
