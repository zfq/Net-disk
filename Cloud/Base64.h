//
//  Base64.h
//  Cloud
//
//  Created by zhaofuqiang on 13-12-27.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject

void free_string(char *string);
char *chunk_split(char *string, const int length);
void base64_encoder(const char *input,int len,char** out_str);
void base64_encoder_file(FILE *fin,FILE *fout);
void base64_decoder(const char *input,int len,char** out_str);

@end
