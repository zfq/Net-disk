//
//  PreViewDocument.m
//  Cloud
//
//  Created by zhaofuqiang on 13-12-22.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "PreViewDocument.h"

@interface PreViewDocument ()

@end

@implementation PreViewDocument

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)previewDocument
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:_fileName withExtension:_extension];
    if (fileURL) {
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.documentInteractionController.delegate = self;
        [self.documentInteractionController presentPreviewAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self previewDocument];
}

//UIDocumentInteractionController代理方法
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

//用其他app打开文档
- (void)openDocument:(id)sender
{
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:_fileName withExtension:_extension];
    if (fileURL) {
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.documentInteractionController.delegate = self;
        [self.documentInteractionController presentOpenInMenuFromBarButtonItem:bbi animated:YES];
    }
}

@end
