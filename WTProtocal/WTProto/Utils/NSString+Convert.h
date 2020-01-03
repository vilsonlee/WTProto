//
//  NSString+Convert.h
//  wChatDemo
//
//  Created by raven.wu on 2018/11/21.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Convert)

// 字符串转十六进制
+ (NSString *)convertHexStringWithString:(NSString *)string;

// 过滤特殊字符
+ (NSString *)filterSpecialCharactorWithString:(NSString *)string;

// 转化HTML特殊符号
+ (NSString *)convertHTMLCharactorWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
