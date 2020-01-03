//
//  NSString+AES.h
//  wChatDemo
//
//  Created by raven.wu on 2018/10/16.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AES)

- (NSString *)encryptWithAESPublicKey:(NSString *)publicKey;

- (NSString *)decryptWithAESPublicKey:(NSString *)publicKey;

+ (NSString*)safeUrlBase64Encode:(NSData*)data;

+ (NSData*)safeUrlBase64Decode:(NSString*)safeUrlbase64Str;


@end

NS_ASSUME_NONNULL_END
