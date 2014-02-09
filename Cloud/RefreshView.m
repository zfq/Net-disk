//
//  RefreshView.m
//  TestRefreshView
//
//  Created by Jason Liu on 12-1-10.
//  Copyright 2012年 Yulong. All rights reserved.
//

#import "RefreshView.h"

@implementation RefreshView
@synthesize refreshIndicator;
@synthesize refreshStatusLabel;
@synthesize refreshLastUpdatedTimeLabel;
@synthesize refreshArrowImageView;
@synthesize isLoading;
@synthesize isDragging;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
