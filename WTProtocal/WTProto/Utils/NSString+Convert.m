//
//  NSString+Convert.m
//  wChatDemo
//
//  Created by raven.wu on 2018/11/21.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import "NSString+Convert.h"

@implementation NSString (Convert)

+ (NSString *)convertHexStringWithString:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    
    NSString *hexStr = @"";
    for(NSInteger i = 0;i <[myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
        if([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}


+ (NSString *)filterSpecialCharactorWithString:(NSString *)string {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    return [string stringByTrimmingCharactersInSet:set];
}


//将 &lt 等类似的字符转化为HTML中的“<”等
+ (NSString *)convertHTMLCharactorWithString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    return string;
}


@end
