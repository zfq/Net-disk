//
//  Base64.m
//  Cloud
//
//  Created by zhaofuqiang on 13-12-27.
//  Copyright (c) 2013年 zzti. All rights reserved.
//
/**********************************
 @author:kylin
 @home  :www.kylin-os.com
 @email :support@kylin-os.com
 @date  :2008/11/2
 **********************************/

#import "Base64.h"
#import <stdio.h>
#import <malloc/malloc.h>

@implementation Base64

static const char cb64[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static const char rstr[] = {
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
    -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
};

void free_string(char *string)
{
	if(string)
	{
		free(string);
		string = NULL;
	}
}

char *chunk_split(char *string, const int length)
{
	int i;
	int j = 0;
	int mod;
    
	int len = strlen(string) + 1;
    
	char *src = (char *)malloc(len * sizeof(char));
	char *dest = (char *)malloc((len + (len / length + 1) * 2) * sizeof(char));
    
	if(src == NULL) return NULL;
	if(dest == NULL) return NULL;
    
	memset(src, 0, sizeof(char) * len);
	memset(dest, 0, sizeof(char) * (len + (len / length + 1) * 2));
    
	memcpy(src, string, len * sizeof(char));
    
	if(len > length)
	{
		for(i = 0; i < len; i++)
		{
			mod = i % length;
			if(mod == 0)
			{
				dest[j] = '\r';
				j++;
				dest[j] = '\n';
				j++;
				dest[j] = src[i];
				j++;
			}
			else
			{
				dest[j] = src[i];
				j++;
			}
		}
		dest[j] = '\0';
	}
	
	free_string(src);
    
	return dest;
}
//remember free(out_str);
void base64_encoder(const char *input,int len,char** out_str)
{
	int new_buf_len = len+len/3;
    new_buf_len+=new_buf_len/76+2;
	char tmp_out[new_buf_len];
	char * tmp_out_str = NULL;
	int i=0;
	int o=0;
	int remain=0;
	int p=0;
	int mlen=0;
    
	while(i<len)
	{
	 	remain = len-i;
	 	//if(o&&o%76==0)
        //	tmp_out[p++]='\n';
	 	switch(remain)
	 	{
	 		case 1:
                tmp_out[p++]=cb64[((input[i] >> 2) & 0x3f)];
                tmp_out[p++]=cb64[((input[i] << 4) & 0x30)];
                tmp_out[p++]='=';
                tmp_out[p++]='=';
                break;
	 		case 2:
                tmp_out[p++]=cb64[((input[i] >> 2) & 0x3f)];
                tmp_out[p++]=cb64[((input[i] << 4) & 0x30) + ((input[i + 1] >> 4) & 0x0f)];
                tmp_out[p++]=cb64[((input[i + 1] << 2) & 0x3c)];
                tmp_out[p++]='=';
                break;
	 	    default:
                tmp_out[p++]=cb64[((input[i] >> 2) & 0x3f)];
                tmp_out[p++]=cb64[ ((input[i] << 4) & 0x30) + ((input[i + 1] >> 4) & 0x0f) ];
                tmp_out[p++]=cb64[((input[i + 1] << 2) & 0x3c) + ((input[i + 2] >> 6) & 0x03)];
                tmp_out[p++]=cb64[(input[i + 2] & 0x3f)];
	 	}
	 	i+=3;
	 	o+=4;
	}
	tmp_out[p]='\0';
    
	mlen = strlen(tmp_out)+1;
	tmp_out_str=(char *)malloc(new_buf_len*sizeof(char)+1);

	memset(tmp_out_str,0x0,mlen);
	strcpy(tmp_out_str,tmp_out);
	free(*out_str);
	*out_str = tmp_out_str;
}

//read file to b6.
void base64_encoder_file(FILE *fin,FILE *fout)
{
	size_t remain =0;
	size_t o=0;
	size_t i=0;
	char input[4];
	remain = fread(input,1,3,fin);
	while(remain>0)
	{
		//if(o&&o%76==0)
		//	fprintf(fout,"\n");
		switch(remain)
		{
                
            case 1:
				putc(cb64[((input[i] >> 2) & 0x3f)],fout);
				putc(cb64[((input[i] << 4) & 0x30)],fout);
                fprintf(fout,"==");
				break;
            case 2:
			    putc(cb64[((input[i] >> 2) & 0x3f)],fout);
				putc(cb64[((input[i] << 4) & 0x30) + ((input[i + 1] >> 4) & 0x0f)],fout);
				putc(cb64[((input[i + 1] << 2) & 0x3c)],fout);
				putc('=',fout);
				break;
            default:
				putc(cb64[((input[i] >> 2) & 0x3f)],fout);
				putc(cb64[ ((input[i] << 4) & 0x30) + ((input[i + 1] >> 4) & 0x0f) ],fout);
				putc(cb64[((input[i + 1] << 2) & 0x3c) + ((input[i + 2] >> 6) & 0x03)],fout);
				putc(cb64[(input[i + 2] & 0x3f)],fout);
		}
		o+=4;
		remain=fread(input,1,3,fin);
	}
}


void base64_decoder(const char *input,int len,char** out_str)
{
	int i=0;
	int new_buf_len=len;
	int p = 0;
	int mlen=0;
	char tmp_out[new_buf_len];
	char * tmp_out_str = NULL;
	while(i<len)
	{
		while(i<len&&(input[i]=='\n'||input[i]=='\r'))
            i++;
		if(i<len)
		{
			char b1= (char)((rstr[(int)input[i]] << 2 & 0xfc) +
                            (rstr[(int)input[i + 1]] >> 4 & 0x03));
            tmp_out[p++]=b1;
            if(input[i+2]!='=')
            {
                char b2 = (char)((rstr[(int)input[i+1]]<<4&0xf0)+(rstr[(int)input[i+2]]>>2&0x0f));
                tmp_out[p++]=b2;
            }
            if(input[i+3]!='=')
            {
                char b3= (char)((rstr[(int)input[i+2]]<<6&0xc0)+rstr[(int)input[i+3]]);
                tmp_out[p++]=b3;
            }
			i+=4;	
		}
        
	}
	tmp_out[p]='\0';
    
	mlen = strlen(tmp_out)+1;
	//*out_str = (char*)malloc(new_buf_len*sizeof(char)+1);
	tmp_out_str = (char*)malloc(mlen*sizeof(char));
	memset(tmp_out_str,0x0,mlen);
	strcpy(tmp_out_str,tmp_out);
	free(*out_str);
	*out_str = tmp_out_str;
}



@end
