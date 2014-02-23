//
//  DownloadItemStore.m
//  Cloud
//
//  Created by zhaofuqiang on 14-2-13.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "DownloadItemStore.h"

@implementation DownloadItemStore

+ (DownloadItemStore *)sharedItemStore
{
    static DownloadItemStore *sharedDownloadItemInstance = nil;
    static dispatch_once_t downloadItemPredicate;
    dispatch_once(&downloadItemPredicate, ^{
        sharedDownloadItemInstance = [[self alloc] init];
        sharedDownloadItemInstance.downloadingItems = [NSMutableArray array];
        sharedDownloadItemInstance.downloadItems = [NSMutableArray array];
    });
    
    return sharedDownloadItemInstance;
}

@end
