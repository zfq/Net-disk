//
//  UploadItemStore.h
//  Cloud
//
//  Created by zzti on 13-11-26.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTAssetsPickerController.h"
@interface UploadItemStore : NSObject<UINavigationControllerDelegate,CTAssetsPickerControllerDelegate>
{
}

@property (nonatomic,strong) NSMutableArray *assets;     //assets存放的是ALAsset对象,
@property (nonatomic,strong) NSMutableDictionary *assetsPath; //这个是指存放在本地的路径 path forkey itemName
@property (nonatomic,strong) NSMutableDictionary *itemName;  //ALAsset forkey itemName
@property (nonatomic,strong) NSMutableArray *uploadingItems; //正在上传或等待上传项
@property (nonatomic,strong) NSMutableArray *uploadedItems;  //已完成上传项
@property (nonatomic,strong) UITableView *refreshTableView;

+ (UploadItemStore *)sharedStore;

@end
