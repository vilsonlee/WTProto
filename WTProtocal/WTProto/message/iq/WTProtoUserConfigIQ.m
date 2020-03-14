//
//  WTProtoUserConfigIQ.m
//  WTProtocalKit
//
//  Created by Mark on 2020/3/13.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoUserConfigIQ.h"
#import "WTProtoIQ.h"
#import "WTProtoUser.h"
#import <WTXMPPFramework/XMPPStream.h>

@implementation WTProtoUserConfigIQ

#pragma mark - 用户偏好设置
+ (WTProtoIQ *)IQ_getUserPerferenceWithLocalUser:(WTProtoUser *)fromUser{
    
        
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    [iq addAttributeWithName:@"to" stringValue:fromUser.domain];

    NSXMLElement *fieldsingleNode = [NSXMLElement elementWithName:@"userconfig" xmlns:@"wchat:user:config"];
    [iq addChild:fieldsingleNode];
    
    return iq;
    
}

+ (void)parse_IQ_getUserPerference:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
 
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, [errorElement stringValue]);
    }
    else{
        NSXMLElement *itemElement = [iq elementForName:@"item"];
            NSMutableDictionary * xmlItemDict  = [[NSMutableDictionary alloc] init];
            for (NSXMLElement * subElement in itemElement.children) {
            [xmlItemDict setObject:[subElement stringValue] forKey:[subElement name]];
        }
        NSLog(@"UserPerference===%@",xmlItemDict);
        parseResult(YES, xmlItemDict);
    }
    
}

#pragma mark - 用户聊天设置
+ (WTProtoIQ *)IQ_getUserChatSettingWithLocalUser:(WTProtoUser *)fromUser{
    
        
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    [iq addAttributeWithName:@"to" stringValue:fromUser.domain];

    NSXMLElement *fieldsingleNode = [NSXMLElement elementWithName:@"userprivate" xmlns:@"wchat:user:private"];
    [iq addChild:fieldsingleNode];
    
    return iq;
}

+ (void)parse_IQ_getUserChatSetting:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
 
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, [errorElement stringValue]);
    }
    else{
        NSXMLElement *itemElement = [iq elementForName:@"item"];
        NSMutableDictionary * xmlItemDict  = [[NSMutableDictionary alloc] init];
        for (NSXMLElement * subElement in itemElement.children) {
            if ([[subElement name] isEqualToString:@"singleNoPushList"] ||
                [[subElement name] isEqualToString:@"conversationTopList"] ||
                [[subElement name] isEqualToString:@"blockCircleOfFriendList"] ||
                [[subElement name] isEqualToString:@"blockContactCircleList"] ) {
                NSMutableArray *childArr = [[NSMutableArray alloc] init];
                for (NSXMLElement *childElement in subElement.children) {
                    [childArr addObject:[childElement stringValue]];
                }
                [xmlItemDict setObject:childArr forKey:[subElement name]];
            }else if ([[subElement name] isEqualToString:@"timedDestructionList"]){
                NSMutableArray *childArr = [[NSMutableArray alloc] init];
                for (NSXMLElement *childElement in subElement.children) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:[childElement attributeStringValueForName:@"jid"] forKey:@"jid"];
                    [dict setObject:[childElement stringValue] forKey:@"time"];
                    [childArr addObject:dict];
                }
                [xmlItemDict setObject:childArr forKey:[subElement name]];
            }else {
                [xmlItemDict setObject:[subElement stringValue] forKey:[subElement name]];
            }
        }
        NSLog(@"UserChatSetting===%@",xmlItemDict);
        parseResult(YES, xmlItemDict);
    }
    
}


#pragma mark - 更新用户偏好设置
+ (WTProtoIQ *)IQ_updateUserConfigWithDict:(NSDictionary *)updateDict localUser:(WTProtoUser *)fromUser{
    
    //updateUserConfig
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    [iq addAttributeWithName:@"to" stringValue:fromUser.domain];
    
    NSXMLElement *listNode = [NSXMLElement elementWithName:@"userconfiglist" xmlns:@"wchat:user:config"];

        NSXMLElement *elementNode = [NSXMLElement elementWithName:@"userconfig" xmlns:@"wchat:user:config"];
        NSString *key = [[updateDict allKeys] firstObject];
        [elementNode addAttributeWithName:@"key" stringValue:key];
        [elementNode addAttributeWithName:@"value" stringValue:[updateDict objectForKey:key]];
    
    [listNode addChild:elementNode];
    [iq addChild:listNode];
    
    return iq;
}

+ (void)parse_IQ_updateUserConfig:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, [errorElement stringValue]);
    }
    else{
        parseResult(YES, @"更新 updateUserConfig 成功");
    }
    
}



#pragma mark - 更新用户聊天配置
+ (WTProtoIQ *)IQ_updateUserChatSettingWithDict:(NSDictionary *)updateDict localUser:(WTProtoUser *)fromUser{
    
    //updateUserChatSetting
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    [iq addAttributeWithName:@"to" stringValue:fromUser.domain];
    
    NSXMLElement *elementNode = [NSXMLElement elementWithName:@"userprivate" xmlns:@"wchat:user:private"];
    [elementNode addAttributeWithName:@"type" stringValue:@"update"];
    NSString *key = [[updateDict allKeys] firstObject];
    [elementNode addAttributeWithName:@"key" stringValue:key];
    [elementNode addAttributeWithName:@"value" stringValue:[updateDict objectForKey:key]];
    
    [iq addChild:elementNode];
    
    return iq;
    
}

+ (void)parse_IQ_updateUserChatSetting:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, [errorElement stringValue]);
    }
    else{
        parseResult(YES, @"更新 UserChatSetting 成功");
    }
    
}

#pragma mark - 移除用户聊天配置
+ (WTProtoIQ *)IQ_removeUserChatSettingWithDict:(NSDictionary *)updateDict localUser:(WTProtoUser *)fromUser{
    
    //removeUserChatSetting
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    [iq addAttributeWithName:@"to" stringValue:fromUser.domain];
    
    NSXMLElement *elementNode = [NSXMLElement elementWithName:@"userprivate" xmlns:@"wchat:user:private"];
    [elementNode addAttributeWithName:@"type" stringValue:@"remove"];
    NSString *key = [[updateDict allKeys] firstObject];
    [elementNode addAttributeWithName:@"key" stringValue:key];
    [elementNode addAttributeWithName:@"value" stringValue:[updateDict objectForKey:key]];
    
    [iq addChild:elementNode];
    
    return iq;
}

+ (void)parse_IQ_removeUserChatSetting:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, [errorElement stringValue]);
    }
    else{
        parseResult(YES, @"删除 removeUserChatSetting 成功");
    }
    
}

















































@end
