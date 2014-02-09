//
//  PhotoBrowser.h
//  单视图平时测试
//
//  Created by zhaofuqiang on 13-8-24.
//  Copyright (c) 2013年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoView.h"
@class PhotoView;
@interface PhotoBrowser : UIViewController <PhotoViewDelegate,UIScrollViewDelegate>
{
    UIScrollView *_mainScrollView;
}

- (void)showPhotoViewFromCurrentIndex:(NSUInteger)currentPhotoIndex;
- (void)setNavBarAppearance:(BOOL)animated;

@property (nonatomic,strong) NSMutableArray *photoArray;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
@property (nonatomic,strong) PhotoView *photoView;
@end
