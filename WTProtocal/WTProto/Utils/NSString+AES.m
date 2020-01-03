//
//  NSString+AES.m
//  wChatDemo
//
//  Created by raven.wu on 2018/10/16.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import "NSString+AES.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

@implementation NSString (AES)

//static NSString *const PSW_AES_KEY = @"0123456789ABCDEF";
static NSString *const AES_IV_PARAMETER = @"DONGSHAN20181017";

- (NSString*)encryptWithAESPublicKey:(NSString *)publicKey {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *AESData = [self AES128operation:kCCEncrypt
                                       data:data
                                        key:publicKey
                                         iv:AES_IV_PARAMETER];
    
    
    NSString *baseStr_GTM = [self encodeBase64Data:AESData];
    return baseStr_GTM;
}

- (NSString*)decryptWithAESPublicKey:(NSString *)publicKey {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *baseData_GTM = [self decodeBase64Data:data];
    
    NSData *AESData_GTM = [self AES128operation:kCCDecrypt
                                           data:baseData_GTM
                                            key:publicKey
                                             iv:AES_IV_PARAMETER];

    
    NSString *decStr_GTM = [[NSString alloc] initWithData:AESData_GTM encoding:NSUTF8StringEncoding];
    return decStr_GTM;
}

/**
 *  AES加解密算法
 *
 *  @param operation kCCEncrypt（加密）kCCDecrypt（解密）
 *  @param data      待操作Data数据
 *  @param key       key
 *  @param iv        向量
 *
 *
 */
- (NSData *)AES128operation:(CCOperation)operation data:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    
    char keyPtr[kCCKeySizeAES128 + 1];  //kCCKeySizeAES128是加密位数 可以替换成256位的
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    // 设置加密参数
    /**
     这里设置的参数ios默认为CBC加密方式，如果需要其他加密方式如ECB，在kCCOptionPKCS7Padding这个参数后边加上kCCOptionECBMode，即kCCOptionPKCS7Padding | kCCOptionECBMode，但是记得修改上边的偏移量，因为只有CBC模式有偏移量之说
     
     */
    CCCryptorStatus cryptorStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                            keyPtr, kCCKeySizeAES128,
                                            ivPtr,
                                            [data bytes], [data length],
                                            buffer, bufferSize,
                                            &numBytesEncrypted);
    
    if(cryptorStatus == kCCSuccess) {
//         NSString *str =  [[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//         NSLog(@"Success..%@",str);
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        
    } else {
        NSLog(@"Error");
    }
    
    free(buffer);
    return nil;
}

// 这里附上GTMBase64编码的代码，可以手动写一个分类，也可以直接cocopods下载，pod 'GTMBase64'。
/**< GTMBase64编码 */
- (NSString*)encodeBase64Data:(NSData *)data {
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

/**< GTMBase64解码 */
- (NSData*)decodeBase64Data:(NSData *)data {
    data = [GTMBase64 decodeData:data];
    return data;
}

#pragma - 将saveBase64编码中的"-"，"_"字符串转换成"+"，"/"，字符串长度余4倍的位补"="
+(NSData*)safeUrlBase64Decode:(NSString*)safeUrlbase64Str
{
    // '-' -> '+'
    // '_' -> '/'
    // 不足4倍长度，补'='
    NSMutableString * base64Str = [[NSMutableString alloc]initWithString:safeUrlbase64Str];
    base64Str = (NSMutableString * )[base64Str stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64Str = (NSMutableString * )[base64Str stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSInteger mod4 = base64Str.length % 4;
    if(mod4 > 0)
        [base64Str appendString:[@"====" substringToIndex:(4-mod4)]];
    NSLog(@"Base64原文：%@", base64Str);
    return [GTMBase64 decodeData:[base64Str dataUsingEncoding:NSUTF8StringEncoding]];
    
}

#pragma - 因为Base64编码中包含有+,/,=这些不安全的URL字符串，所以要进行换字符
+(NSString*)safeUrlBase64Encode:(NSData*)data
{
    // '+' -> '-'
    // '/' -> '_'
    // '=' -> ''
    NSString * base64Str = [GTMBase64 stringByEncodingData:data];
    NSMutableString * safeBase64Str = [[NSMutableString alloc]initWithString:base64Str];
    safeBase64Str = (NSMutableString * )[safeBase64Str stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    safeBase64Str = (NSMutableString * )[safeBase64Str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //    safeBase64Str = (NSMutableString * )[safeBase64Str stringByReplacingOccurrencesOfString:@"=" withString:@""];
    NSLog(@"safeBase64编码：%@", safeBase64Str);
    return safeBase64Str;
}



@end
