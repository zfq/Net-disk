//
//  Constant.h
//  Cloud
//
//  Created by zhaofuqiang on 13-12-28.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#ifndef Cloud_Constant_h
#define Cloud_Constant_h

#define ServiceName @"com.ccm.Cloud"
#define AccountName @"AccountName"

#define HOST_URL        @"http://202.85.212.220:8080/paas/"
#define ROOT_PATH       @"/"
#define DOWNLOAD_DIR    @"Download"
#define MAX_SHOW_NUM    100

#define kLoginStatusChangedNotification @"kLoginStatusChangedNotification"
#define kDownloadNotification           @"kDownloadNotification"

#define NavigationBarColor [UIColor colorWithRed:0.118 green:0.564 blue:0.95 alpha:1.0]

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define X_OFFSET 81.0

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define IOS7_SDK_AVAILABLE 1
#endif

#endif
