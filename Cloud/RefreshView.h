//
//  RefreshView.h
//  TestRefreshView
//
//  Created by Jason Liu on 12-1-10.
//  Copyright 2012年 Yulong. All rights reserved.
//

// Refresh view controller show label 
#define REFRESH_LOADING_STATUS @"加载中..."
#define REFRESH_PULL_DOWN_STATUS @"下拉可以刷新..."
#define REFRESH_RELEASED_STATUS @"松开即刷新..."
#define REFRESH_UPDATE_TIME_PREFIX @"最后更新: "
#define REFRESH_HEADER_HEIGHT 60
#import <UIKit/UIKit.h>

@interface RefreshView : UIView {
    UIImageView *refreshArrowImageView;
    UIActivityIndicatorView *refreshIndicator;
    UILabel *refreshStatusLabel;
    UILabel *refreshLastUpdatedTimeLabel;
    
    BOOL isLoading;
    BOOL isDragging;
}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *refreshIndicator;
@property (nonatomic, retain) IBOutlet UILabel *refreshStatusLabel;
@property (nonatomic, retain) IBOutlet UILabel *refreshLastUpdatedTimeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *refreshArrowImageView;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isDragging;
@end
