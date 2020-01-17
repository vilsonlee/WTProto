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

//获取JID字符串中的user值
-(NSString*)JID_user{
    //JID格式： user@domain/resource
    NSString * jid_user = [self componentsSeparatedByString:@"@"].firstObject;
    return jid_user;
}
//获取JID字符串中的bare值
-(NSString*)JID_bare{
    //JID格式： user@domain/resource
    //bare格式： user@domain
    NSString * jid_user = [self componentsSeparatedByString:@"/"].firstObject;
    return jid_user;
}
//获取JID字符串中的domain值
-(NSString*)JID_domain{
    //JID格式： user@domain/resource
    NSString * jid_domain_resource = [[self JID_bare] componentsSeparatedByString:@"@"].lastObject;
    NSString * jid_domain = [jid_domain_resource componentsSeparatedByString:@"/"].firstObject;
    return jid_domain;
}



@end
