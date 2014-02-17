//
//  DownloadItemStore.m
//  Cloud
//
//  Created by zhaofuqiang on 14-2-13.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "DownloadItemStore.h"

@implementation DownloadItemStore

+ (DownloadItemStore *)shareItemStore
{
    static DownloadItemStore *sharedDownloadItemInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDownloadItemInstance = [[self alloc] init];
        sharedDownloadItemInstance.downloadingItems = [NSMutableArray array];
        sharedDownloadItemInstance.downloadItems = [NSMutableArray array];
        
    });
    
    return sharedDownloadItemInstance;
}

//+ (id)allocWithZone:(struct _NSZone *)zone
//{
//    return [self shareItemStore];
//}

@end
