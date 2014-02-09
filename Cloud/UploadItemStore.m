//
//  UploadItemStore.m
//  Cloud
//
//  Created by zzti on 13-11-26.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "UploadItemStore.h"

@implementation UploadItemStore
@synthesize assets,assetsPath,itemName;
- (id)init
{
    self = [super init];
    if (self)
    {
        assets    = [[NSMutableArray alloc] init];
        assetsPath = [[NSMutableDictionary alloc] init];
        itemName  = [[NSMutableDictionary alloc] init];
        _uploadedItems = [[NSMutableArray alloc] init];
        _uploadingItems = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (UploadItemStore *)sharedStore
{
    static UploadItemStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
        
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assetArray
{
    NSMutableArray *tempAssetArray = [[NSMutableArray alloc] init];
    
//    int count=[UploadItemStore sharedStore].assets.count;
    int count = self.uploadingItems.count;
    int repetition = 0;
    int t=0;
    for (int i = self.uploadingItems.count; i < self.uploadingItems.count + assetArray.count ; i++) //assets.count是新增加的
    {
        ALAsset *tempAsset = [assetArray objectAtIndex:t]; //按顺序获取选取的asset
        
        NSString *newAddItemName = tempAsset.defaultRepresentation.filename;
        if ([[UploadItemStore sharedStore].itemName objectForKey:newAddItemName]==nil) {
            [tempAssetArray addObject:[assetArray objectAtIndex:t]];
            [self.assetsPath setObject:picker.storePath forKey:newAddItemName]; //保存所选的路径
            count++;
        }else{
            repetition++;
        }
        t++;
    }
    
    if (repetition > 0) {
        NSString *msg = [NSString stringWithFormat:@"自动忽略%i个重复项",repetition];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    if (tempAssetArray.count > 0) {
        [[UploadItemStore sharedStore].assets addObjectsFromArray:tempAssetArray];
        [self.uploadingItems addObjectsFromArray:tempAssetArray];
    }
 
//    [self.uploadingItems addObjectsFromArray:assetArray];
//    for (ALAsset *asset in assetArray) {
//        NSString *fileName = asset.defaultRepresentation.filename;
//        NSLog(@"%@",fileName);
//    }
    [self.refreshTableView reloadData];
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    picker = nil;
}

@end
