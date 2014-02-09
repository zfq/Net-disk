//
//  CTAssetsViewController.h
//  Cloud
//
//  Created by zzti on 13-12-2.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "SelectPathViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class CTAssetsViewCell;
@protocol CTAssetsViewControllerDelegate;

@interface CTAssetsViewController : UICollectionViewController<SelectPathViewControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) CTAssetsViewCell *assetItem;
@property (nonatomic,strong) UIButton  *uploadBtn;
@property (nonatomic,strong) UIButton  *pathBtn;
@property (nonatomic,strong)   NSString  *storePath;
@property (nonatomic,assign) NSInteger numberOfSelected;

@property (nonatomic,weak) id<CTAssetsViewControllerDelegate> catvcDelegate;  //上传 按钮的代理方法
- (void)addButtons;
@end

@protocol CTAssetsViewControllerDelegate <NSObject>

@optional

- (void)tapUpload:(id)sender;

@end



