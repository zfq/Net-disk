//
//  Encryption.h
//  加密
//
//  Created by lab on 13-12-13.
//  Copyright (c) 2013年 test2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<CommonCrypto/CommonCryptor.h>
@interface Encryption : NSObject

int decrypt_ciphertxt(char *ciphertext, char *plain);
int encrypt_plain(char *plain, char *ciphertext);

+ (NSString *)decrypt:(NSString *)ciphertext;
+ (NSString *)encrypt:(NSString *)plainText;

@end
