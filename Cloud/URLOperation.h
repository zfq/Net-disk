//
//  URLOperation.h
//  Cloud
//
//  Created by zhaofuqiang on 13-12-31.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol URLOperationDelegate;

@interface URLOperation : NSOperation<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSMutableURLRequest     *_request;
    NSURLConnection  *_connection;
    NSMutableData    *_data;
    NSStringEncoding _encoding;
    BOOL _isFinished;
}

@property (readonly) NSData *data;
@property (nonatomic,weak) id<URLOperationDelegate> uDelegate;
- (id)initWithURLString:(NSString *)url;
- (BOOL)isFinished;
@end

@protocol URLOperationDelegate <NSObject>

@optional
- (void)completeDataReception:(NSData *)data;
- (void)errorInfo:(NSError *)error;
@end