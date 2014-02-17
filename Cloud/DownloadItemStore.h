//
//  DownloadItemStore.h
//  Cloud
//
//  Created by zhaofuqiang on 14-2-13.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadItemStore : NSObject

@property (nonatomic,strong) NSMutableArray *downloadItems;     //已完成的下载项
@property (nonatomic,strong) NSMutableArray *downloadingItems;  //未完成的下载项

+ (DownloadItemStore *)shareItemStore;
@end
