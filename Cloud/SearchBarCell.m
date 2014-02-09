//
//  SearchBarCell.m
//  Cloud
//
//  Created by zzti on 13-11-18.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "SearchBarCell.h"

@implementation SearchBarCell
@synthesize searchBar;

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbar.png"] forState:UIControlStateNormal];
    /*覆盖searchBar下面的线条*/
    CGRect rect = self.searchBar.frame;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.height-1,rect.size.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.searchBar addSubview:lineView];
    /*添加分割线*/
    UILabel *separatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.contentView.frame.origin.y+0.8, 305, 0.8)];
    separatorLabel.backgroundColor = [UIColor colorWithRed:0.8274 green:0.8274 blue:0.8274 alpha:1.0];
    
    [self.contentView addSubview:separatorLabel];
}

- (UIButton *)newFolderButton
{
    return _newFolderButton;
}

@end
