//
//  MyFileItemStore.h
//  Cloud
//
//  Created by zzti on 13-11-26.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MainContentItem;
@interface MyFileItemStore : NSObject
{
}

@property (nonatomic,strong) NSMutableArray *allItems;

- (MainContentItem *)createSingleFolderWithName:(NSString *)folderName date:(NSDate *)createdDate folderPath:(NSString *)path isDir:(BOOL)dir;
- (MainContentItem *)createFolderWithName:(NSString *)folderName date:(NSDate *)createdDate folderPath:(NSString *)path isDir:(BOOL)dir;
@end
