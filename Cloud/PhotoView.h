//
//  PhotoView.h
//  单视图平时测试
//
//  Created by zhaofuqiang on 13-12-11.
//  Copyright (c) 2013年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoViewDelegate;
@interface PhotoView : UIScrollView<UIScrollViewDelegate>
{

}
@property (nonatomic,weak) id<PhotoViewDelegate> tapDelegate;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic) BOOL isSmallImage;

- (id)initImageScrollViewWithFrame:(CGRect)frame imageName:(NSString *)imageName;
- (void)reloadImageViewWithName:(NSString *)imageName;
- (void)resizePhotoView;
//- (void)ajustImageView;
@end

@protocol PhotoViewDelegate <NSObject>
@optional
- (void) handleSingleTap:(UITapGestureRecognizer *)tapGesture;
- (void) handleDoubleTap:(UITapGestureRecognizer *)tapGesture;
@end