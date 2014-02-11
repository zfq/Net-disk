//
//  MainContentItem.h
//  Cloud
//
//  Created by zhaofuqiang on 13-11-23.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <Foundation/Foundation.h>
//应添加enum枚举文件属性
typedef enum  {
    kFilePropertyDir = 0,
    kFilePropertyDoc,
    kFilePropertyXls,
    kFilePropertyPpt,
    kFilePropertyPic,
}FileProperty;

@interface MainContentItem : NSObject

@property (nonatomic,strong) UIImage *thumbnailImage;
@property (nonatomic,strong) NSString *fileName;  //当前文件名,如果是文件夹就是文件夹名
@property (nonatomic,strong) NSDate *dateCreated;
@property (nonatomic,strong) NSString *currentFolderPath;  //当前文件夹所在路径
@property (nonatomic,assign) BOOL isDir;           //是否是文件夹
//@property (nonatomic,strong) NSString *fileProperty; //文件属性，图片 文件夹 文档 表格 幻灯片
@property (nonatomic,strong) NSMutableArray *files; //当前文件夹内的所有文件

@property (nonatomic,assign) FileProperty fileProperty;
//@property (nonatomic,strong) NSString *modifyDate; //文件修改日期
//@property (nonatomic,assign) double fileSize; //文件大小
@property (nonatomic,strong) NSString *fileSize;
- (id)initWithMainCntentItem:(NSString *)fName Image:(UIImage *)tImage Date:(NSDate *)dCreated;
- (void)setThumbnailImageFromData:(NSData *)imageData;

@end
