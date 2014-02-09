//
//  CTAssetsViewCell.h
//  Cloud
//
//  Created by zzti on 13-12-2.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface CTAssetsViewCell : UICollectionViewCell

- (void)bind:(ALAsset *)asset;

@end

