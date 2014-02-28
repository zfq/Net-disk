//
//  MyFileItemStore.m
//  Cloud
//
//  Created by zzti on 13-11-26.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "MyFileItemStore.h"
#import "MainContentItem.h"
@implementation MyFileItemStore
@synthesize allItems;

- (id)init
{
    self = [super init];
    if (self) {
        allItems = [NSMutableArray array];
    }
    
    return self;
}

+ (MyFileItemStore *)sharedItemStore
{
    static MyFileItemStore *sharedMyFileItemInstance = nil;
    static dispatch_once_t myFileItemPredicate;
    dispatch_once(&myFileItemPredicate, ^{
        sharedMyFileItemInstance = [[self alloc] init];
        sharedMyFileItemInstance.allItems= [NSMutableArray array];
    });
    
    return sharedMyFileItemInstance;
}

- (MainContentItem *)createSingleFolderWithName:(NSString *)folderName date:(NSDate *)createdDate folderPath:(NSString *)path isDir:(BOOL)dir
{
    MainContentItem *item = [[MainContentItem alloc] init];
    item.fileName = folderName;
    item.dateCreated = createdDate;
    item.currentFolderPath = path;
    item.isDir = dir;
    return item;
}

- (MainContentItem *)createFolderWithName:(NSString *)folderName date:(NSDate *)createdDate folderPath:(NSString *)path isDir:(BOOL)dir
{
    MainContentItem *item = [[MainContentItem alloc] init];
    item.fileName = folderName;
    item.dateCreated = createdDate;
    item.currentFolderPath = path;
    item.isDir = dir;
    item.fileProperty = kFilePropertyDir;
//    [self.allItems addObject:item];

    return item;
}

@end
