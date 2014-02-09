//
//  URLOperation.m
//  Cloud
//
//  Created by zhaofuqiang on 13-12-31.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import "URLOperation.h"

@implementation URLOperation
@synthesize data = _data;

- (id)initWithURLString:(NSString *)url {
	if (self = [self init]) {
		_request = [[NSMutableURLRequest alloc] init];
        [_request setURL:[NSURL URLWithString:url]];
        [_request setTimeoutInterval:60];
		//构建utf-8的encoding
		_encoding =NSUTF8StringEncoding;
		
		_data = [NSMutableData data];
	}
	return self;
}

- (BOOL)isFinished  //重载NSOperation里的isFinished方法
{
    return _isFinished;
}

- (BOOL)isConcurrent //是否允许并发
{
    return YES;
}

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString*)key
{
	//当这个值改变时，使用自动通知已注册过的观察者，观察者应实现observeValueForKeyPath:ofObject:change:context:方法
    if ([key isEqualToString:@"isFinished"])
    {
        return YES;
    }
	
    return [super automaticallyNotifiesObserversForKey:key];
}

- (void)start
{
	if (![self isCancelled]) {
		// 以异步方式处理事件，并设置代理
		_connection=[NSURLConnection connectionWithRequest:_request delegate:self];
		while(_connection != nil) {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		}
	}
}

#pragma mark NSURLConnection delegate Method
// 接收到数据（增量）时
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
//	NSLog(@"URLOperation:%@",[[NSString alloc] initWithData:data encoding:_encoding]);
	// 添加数据
	[_data appendData:data];
}

// HTTP请求结束时
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [_uDelegate completeDataReception:_data];
	_isFinished=YES;
	_connection=nil;
}

-(void)connection: (NSURLConnection *) connection didFailWithError: (NSError *) error
{
    [_uDelegate errorInfo:error];
}

@end
