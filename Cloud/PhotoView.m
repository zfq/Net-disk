//
//  PhotoView.m
//  单视图平时测试
//
//  Created by zhaofuqiang on 13-12-11.
//  Copyright (c) 2013年 zhaofuqiang. All rights reserved.
//

#import "PhotoView.h"

@interface PhotoView()
@property(nonatomic) BOOL isDoubleTap ;

@property(nonatomic) BOOL isMediumImage;


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation PhotoView

- (id)initImageScrollViewWithFrame:(CGRect)frame imageName:(NSString *)imageName
{
    self = [super initWithFrame:frame];

    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    if (self) {
        _isSmallImage = NO;
        _isMediumImage = NO;
        _isDoubleTap = NO;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.delegate = self;
        _imageView = [[UIImageView alloc] init];
        
        if ([imageName isEqualToString:@""]) {
            //显示该文件暂时无法预览
            _imageView.frame = CGRectMake(0, 0, width, height);
            _imageView.image = nil;
            UILabel *label = [[UILabel alloc] init];
            label.text = @"抱歉，该文件暂时无法预览";
            label.font = [UIFont boldSystemFontOfSize:17.0];
            CGSize size = [label.text sizeWithFont:label.font];
            label.frame = CGRectMake((frame.size.width-size.width)/2.0, (frame.size.height-size.height)/2.0, size.width, size.height);
            label.textColor = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
            [label sizeToFit];
            
            [_imageView addSubview:label];
            self.minimumZoomScale = 1.0;
            self.maximumZoomScale = 2.0;
            self.zoomScale = 1.0;
        } else {
            _imageView.image = [UIImage imageNamed:imageName];
            
            CGFloat x = width/_imageView.image.size.width;
            CGFloat y = height/_imageView.image.size.height;
            CGFloat minScale = 1.0;
            if (x>1 || y>1) {
                _isSmallImage = YES;
                minScale = 1.0;
            } else {
                minScale = MIN(x, y);
            }

            CGFloat newImgWidth = minScale * _imageView.image.size.width;
            CGFloat newImgHeight = minScale * _imageView.image.size.height;

            CGFloat newX = (width - newImgWidth)/2.0;
            CGFloat newY = (height - newImgHeight)/2.0;
            _imageView.frame = CGRectMake(newX, newY, newImgWidth, newImgHeight);
            _imageView.userInteractionEnabled = YES;
            self.minimumZoomScale = 1.0;
            self.maximumZoomScale = 2.0;
            self.zoomScale = minScale;

        }

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        singleTap.numberOfTapsRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
     }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;

    CGPoint contentOffset = self.contentOffset;
    
    // ensure horizontal offset is reasonable
    if (frameToCenter.origin.x != 0.0)
        contentOffset.x = 0.0;
    
    // ensure vertical offset is reasonable
    if (frameToCenter.origin.y != 0.0)
        contentOffset.y = 0.0;
    
    self.contentOffset = contentOffset;
    
    // ensure content insert is zeroed out using translucent navigation bars
    self.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}
/*
- (void)ajustImageView
{
    CGFloat x = WIDTH/_imageView.image.size.width;
    CGFloat y = HEIGHT/_imageView.image.size.height;
    CGFloat minScale = 1.0;
    if (x>1 || y>1) {
        _isSmallImage = YES;
        minScale = 1.0;
    } else {
        minScale = MIN(x, y);
    }
    
    CGFloat newImgWidth = minScale * _imageView.image.size.width;
    CGFloat newImgHeight = minScale * _imageView.image.size.height;
    CGFloat newX = (WIDTH - newImgWidth)/2.0;
    CGFloat newY = (HEIGHT - newImgHeight)/2.0;
    _imageView.frame = CGRectMake(newX, newY, newImgWidth, newImgHeight);
//    NSLog(@"%@",NSStringFromCGSize(_imageView.frame.size));
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    _imageView.userInteractionEnabled = YES;

}*/
- (void)reloadImageViewWithName:(NSString *)imageName
{

    if (_imageView.image != nil) {
         _imageView.image = nil;
    }
    for (UIView *view in _imageView.subviews) {
            [view removeFromSuperview];
    }
    _imageView.image = [UIImage imageNamed:imageName];
    CGFloat x = self.frame.size.width/_imageView.image.size.width;
    CGFloat y = self.frame.size.height/_imageView.image.size.height;
    CGFloat minScale = 1.0;
    if (x>1 || y>1) {
        _isSmallImage = YES;
        minScale = 1.0;
    } else {
        minScale = MIN(x, y);
    }

    CGFloat newImgWidth = minScale * _imageView.image.size.width;
    CGFloat newImgHeight = minScale * _imageView.image.size.height;
    CGFloat newX = (self.frame.size.width - newImgWidth)/2.0;
    CGFloat newY = (self.frame.size.height - newImgHeight)/2.0;
    _imageView.frame = CGRectMake(newX, newY, newImgWidth, newImgHeight);

    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    _imageView.userInteractionEnabled = YES;

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *v = [scrollView.subviews objectAtIndex:0];
    if ([v isKindOfClass:[UIImageView class]]){
        if (_isSmallImage) {
            v.center = CGPointMake(scrollView.frame.size.width/2.0, scrollView.frame.size.height/2.0);
        }
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tapGesture
{
    if ([_tapDelegate respondsToSelector:@selector(handleSingleTap:)]) {
        [_tapDelegate handleSingleTap:tapGesture];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tapGesture
{
    if ([_tapDelegate respondsToSelector:@selector(handleDoubleTap:)]) {
        [_tapDelegate handleDoubleTap:tapGesture];
    }
    
    _isDoubleTap = YES;
    
    if (self.zoomScale > self.minimumZoomScale) {
//        [_photoBrowser setToolBarViewsHidden:NO animated:YES];
		[self setZoomScale:self.minimumZoomScale animated:YES];
		_isDoubleTap = NO;
	} else {
        CGRect zoomRect = [self zoomRectForScale:self.maximumZoomScale withCenter:[tapGesture locationInView:tapGesture.view]];
        [self zoomToRect:zoomRect animated:YES];
		
	}

}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)resizePhotoView
{
    [self setZoomScale:self.minimumZoomScale animated:NO];
}
@end












