//
//  FQMenuViewController.h
//  Cloud
//
//  Created by zzti on 13-11-14.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IrregularView;
@protocol FQMenuViewControllerDelegate;

@interface FQMenuViewController : UIViewController
{
    IrregularView *_menuView;
    __weak id<FQMenuViewControllerDelegate> _mdelegate;
}

@property (nonatomic,weak) id<FQMenuViewControllerDelegate> delegate;
@property CGRect menuViewFrame;
@property BOOL menuViewIsTapped;
@property (nonatomic,strong) IrregularView *menuView;

- (IrregularView *)customInitIrregularView;
- (BOOL)tapIsInMenuView:(UITapGestureRecognizer *)tapGesture;
- (void)showMenuViewInRect:(CGRect) senderRect;

/*”我的文件“*/
- (void)addMyFileMenuViewContent:(IrregularView *)mView;
- (void)addMyFileMenuViewContent;

/*上传*/
- (void)addUploadViewContent:(IrregularView *)mView;
- (void)addUploadViewContent;
- (void)btnAllTapped:(id)sender;

- (UIButton *)customButton:(CGFloat)width withHeight:(CGFloat)height withNormalImge:(UIImage *)normalImage withPressedImage:(UIImage *)pressedImage;
@end

@protocol FQMenuViewControllerDelegate <NSObject>

- (void) menuViewControllerIsVisible:(FQMenuViewController *)fmvc;

@optional

- (void)tapPhoto:(FQMenuViewController *)fmvc;
- (void)tapVideo:(FQMenuViewController *)fmvc;
@end
