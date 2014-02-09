//
//  des3.h
//  Cloud
//
//  Created by zhaofuqiang on 13-12-27.
//  Copyright (c) 2013年 zzti. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void des2key( unsigned char hexkey[16], short mode,
                    unsigned long keyout[96] );
extern void des3key( unsigned char hexkey[24], short mode,
                    unsigned long keyout[96] );

extern void des3( unsigned char inblock[8], unsigned char outblock[8],
                 unsigned long keysched[96] );

#define EN0    0        /* MODE == encrypt */
#define DE1    1        /* MODE == decrypt */

@interface Des3 : NSObject

void make_key_pair(unsigned char hexkey[16],
                   unsigned long en_keyout[96],
                   unsigned long de_keyout[96]);
char* triple_des_encrypt(unsigned char *in_buf, unsigned long key_sched[96]);
@end
