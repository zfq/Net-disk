//
//  PreViewDocument.h
//  Cloud
//
//  Created by zhaofuqiang on 13-12-22.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreViewDocument : UIViewController<UIDocumentInteractionControllerDelegate>

@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *extension;
@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;

@end
