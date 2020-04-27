//
//  WTProtoContactPresent.m
//  WTProtocalKit
//
//  Created by Mark on 2020/1/3.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoContactPresent.h"
#import "WTProtoPresence.h"
#import "WTProtoUser.h"

@implementation WTProtoContactPresent


//添加联系人
+ (WTProtoPresence *)addFriendWithJid:(NSString *)jidStr source:(NSString *)source verify:(NSString *)verify time:(NSString *)time statusInfo:(NSDictionary *)statusInfo fromUser:(WTProtoUser *)fromUser{
    
    //向服务器发送添加请求
    XMPPJID * jid = [XMPPJID jidWithString:jidStr];
    
    WTProtoPresence *presence = [WTProtoPresence presenceWithType:@"subscribe" to:jid];
    [presence addAttributeWithName:@"from" stringValue:fromUser.full];
    [presence setXmlns:@"jabber:client"];

    //***************************************************************************************************************************************
    //添加联系人附带的信息
    //NSJSONWritingPrettyPrinted
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:statusInfo options:kNilOptions error:&parseError];
    NSString * statusJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [presence addChild:[DDXMLElement elementWithName:@"status" stringValue:statusJsonStr]];
    //***************************************************************************************************************************************
        
    
    //    <ext xmlns="jabber:iq:roster" src="" agree="" verify=""></ext>
    NSXMLElement *subNode = [NSXMLElement elementWithName:@"ext" xmlns:@"jabber:iq:roster"];
    [subNode addAttributeWithName:@"src" stringValue:source];
    [subNode addAttributeWithName:@"agree" stringValue:@""];
    //有理由 -> 需要等待同意接受
    [subNode addAttributeWithName:@"verify" stringValue:verify];
    [subNode addAttributeWithName:@"time" stringValue:time];
        
    
    [presence addChild:subNode];
    
    return presence;
}

+ (WTProtoPresence *)agreeAddFriendRequestWithContactJid:(NSString *)jidStr source:(NSString *)source fromUserJid:(NSString *)fromUserJid{
    //同意好友请求,带上来源
//              [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];//xmpp的同意好友请求方法
    
    XMPPJID * contactJid = [XMPPJID jidWithString:jidStr];

    WTProtoPresence *agreePresence = [WTProtoPresence presenceWithType:@"subscribed" to:contactJid];
    [agreePresence addAttributeWithName:@"from" stringValue:fromUserJid];
    
    NSXMLElement *subNode2 = [NSXMLElement elementWithName:@"ext" xmlns:@"jabber:iq:roster"];
    if (source && source.length) {
        [subNode2 addAttributeWithName:@"src" stringValue:source];
    }
    [subNode2 addAttributeWithName:@"agree" stringValue:@"1"];
    [agreePresence addChild:subNode2];
    
    return agreePresence;
}


+ (WTProtoPresence *)replyAddFriendRequestReceivedWithContactJid:(NSString *)jidStr{
 
    XMPPJID * contactJid = [XMPPJID jidWithString:jidStr];
    
    //回复已接收到申请，下次登录不用再推过来， 回复服务器，已接收： agree = 2
    WTProtoPresence *replyPresence = [WTProtoPresence presenceWithType:@"subscribed" to:contactJid];
    //    <ext xmlns="jabber:iq:roster" src="" agree="" verify=""></ext>
    NSXMLElement *subNode2 = [NSXMLElement elementWithName:@"ext" xmlns:@"jabber:iq:roster"];
    [subNode2 addAttributeWithName:@"agree" stringValue:@"2"];
    [replyPresence addChild:subNode2];
    
    return replyPresence; 
}




//个人信息修改通知其他联系人好友
+ (WTProtoPresence *)userInfoChangedWithUpdateType:(NSString *)type value:(NSString *)value fromUser:(WTProtoUser *)fromUser{
    
    WTProtoPresence *presence = [WTProtoPresence presence];
    [presence addAttributeWithName:@"from" stringValue:fromUser.full];
    [presence addChild:[DDXMLElement elementWithName:@"status" stringValue:value]];

    NSXMLElement *updateNode = [NSXMLElement elementWithName:@"update"];
    [updateNode addAttributeWithName:@"type" stringValue:type];
    [presence addChild:updateNode];
    
    return presence;
}




@end
