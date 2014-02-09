//
//  Encryption.m
//  加密
//
//  Created by lab on 13-12-13.
//  Copyright (c) 2013年 test2. All rights reserved.
//

#import "Encryption.h"
#import "Des3.h"
#import "Base64.h"
@implementation Encryption

/* for encrypt and decrypt */
static unsigned char hexkey[24] = {'y', 'q', 'l', 'x'};

int decrypt_ciphertxt(char *ciphertext, char *plain) //解密 返回plain
{
	unsigned long en_keyout[96] = {0};
	unsigned long de_keyout[96] = {0};
	char *de_str = NULL;
    
	make_key_pair(hexkey, en_keyout, de_keyout);
    
	de_str = triple_des_encrypt((unsigned char*)ciphertext, de_keyout);
    
   
	if (de_str)
		strcpy(plain, de_str);
	else
		return -1;
    
	free(de_str);
	return 0;
}

int encrypt_plain(char *plain, char *ciphertext) //加密 返回ciphertext
{
	unsigned long en_keyout[96] = {0};
	unsigned long de_keyout[96] = {0};
	char *en_str = NULL;
    
	make_key_pair(hexkey, en_keyout, de_keyout);
    
	en_str = triple_des_encrypt((unsigned char*)plain, en_keyout);
    
	if (en_str)
		strcpy(ciphertext, en_str);
	else
		return -1;
    
	free(en_str);
	return 0;
}

+ (NSString *)decrypt:(NSString *)cipherText  //解密
{
    const char *ciphertext = [cipherText UTF8String];
    
    char *out_str = NULL;
    base64_decoder(ciphertext,strlen(ciphertext),&out_str);
    
    unsigned long en_keyout[96] = {0};
	unsigned long de_keyout[96] = {0};
	char *de_str = NULL;
    
	make_key_pair(hexkey, en_keyout, de_keyout);
    
	de_str = triple_des_encrypt((unsigned char*)out_str, de_keyout);
    
    NSString *result = [NSString stringWithUTF8String:de_str];
    free(de_str);
    
	if (result)
        return result;
	else
		return nil;
}

+ (NSString *)encrypt:(NSString *)plainText //加密 
{
    const char *plain = [plainText UTF8String];
    unsigned long en_keyout[96] = {0};
	unsigned long de_keyout[96] = {0};
	char *en_str = NULL;
    char *out_str = NULL;
    
	make_key_pair(hexkey, en_keyout, de_keyout);
    
	en_str = triple_des_encrypt((unsigned char*)plain, en_keyout);
    
    base64_encoder(en_str,strlen(en_str),&out_str);
    
    NSString *result = [NSString stringWithUTF8String:out_str];
    free(en_str);
    
    if (result)
        return result;
	else
		return nil;
}

@end
