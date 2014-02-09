//
//  MainContentItem.m
//  Cloud
//
//  Created by zhaofuqiang on 13-11-23.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "MainContentItem.h"

@implementation MainContentItem

@synthesize thumbnailImage;
@synthesize fileName;
@synthesize dateCreated;
@synthesize currentFolderPath;
@synthesize isDir;

- (id)initWithMainCntentItem:(NSString *)fName Image:(UIImage *)tImage Date:(NSDate *)dCreated
{
    self = [super init];
    if (self) {
        self.fileName = fName;
        self.thumbnailImage = tImage;
        self.dateCreated = dCreated;
    }
    return self;
}

- (void)setThumbnailImageFromData:(NSData *)imageData
{
    UIImage *img = [UIImage imageWithData:imageData];
    CGSize originImageSize = img.size;
    
    CGRect thumbnailRect = CGRectMake(0, 0, 40, 40);
    float ratio = MAX(thumbnailRect.size.width/originImageSize.width, thumbnailRect.size.height/originImageSize.height);

    UIGraphicsBeginImageContextWithOptions(thumbnailRect.size, NO, 0.0);
    
    CGRect projectRect;
    projectRect.size.width = ratio * originImageSize.width;
    projectRect.size.height = ratio * originImageSize.height;
    projectRect.origin.x = (thumbnailRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (thumbnailRect.size.height - projectRect.size.height) / 2.0;
    
    [img drawInRect:projectRect];
    
    self.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
@end
