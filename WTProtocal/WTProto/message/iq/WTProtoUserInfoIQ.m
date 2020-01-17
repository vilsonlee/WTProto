//
//  WTProtoUserInfoIQ.m
//  WTProtocalKit
//
//  Created by Vilson on 2020/1/16.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoUserInfoIQ.h"
#import "WTProtoIQ.h"
#import "WTProtoUser.h"
#import "NSString+pyFirstLetter.h"
#import "NSString+Convert.h"
#import <WTXMPPFramework/XMPPStream.h>


@implementation WTProtoUserInfoIQ


+ (WTProtoIQ *)IQ_SearchUserInfoWithLocalUser:(WTProtoUser*)localUser
                                      KeyWord:(NSString *)key
                                      keyType:(NSString *)type
                              searchFromGroup:(BOOL)fromGroup
{
    NSString *fetchID = [XMPPStream generateUUID];

    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" elementID:fetchID];
    [iq addAttributeWithName:@"from" stringValue:localUser.bareJID.bare];
    [iq addAttributeWithName:@"to" stringValue:[localUser.bareJID domain]];
    
    NSXMLElement *xNode = [NSXMLElement elementWithName:@"x"];
    [xNode addAttributeWithName:@"xmlns" stringValue:@"jabber:x:data"];
    [xNode addAttributeWithName:@"type" stringValue:@"submit"];
        
    NSXMLElement *fieldsingleNode = [NSXMLElement elementWithName:@"field"];
    [fieldsingleNode addAttributeWithName:@"type" stringValue:@"text-single"];
    [fieldsingleNode addAttributeWithName:@"var" stringValue:@"bussiness"];
    [fieldsingleNode addChild:[NSXMLElement elementWithName:@"value" stringValue:@"userinfo"]];
        
    NSXMLElement *fieldNode1 = [NSXMLElement elementWithName:@"field"];
    [fieldNode1 addAttributeWithName:@"type" stringValue:@"text-single"];
    [fieldNode1 addAttributeWithName:@"var" stringValue:@"optype"];
    [fieldNode1 addChild:[NSXMLElement elementWithName:@"value" stringValue:type]];
        
    if (key.length)
    {
        NSXMLElement *fieldNode2 = [NSXMLElement elementWithName:@"field"];
        [fieldNode2 addAttributeWithName:@"type" stringValue:@"text-single"];
        [fieldNode2 addAttributeWithName:@"var" stringValue:type];
        [fieldNode2 addChild:[NSXMLElement elementWithName:@"value" stringValue:key]];
        [xNode addChild:fieldNode2];
        
        NSXMLElement *fieldNode3 = [NSXMLElement elementWithName:@"field"];
        [fieldNode3 addAttributeWithName:@"type" stringValue:@"text-single"];
        [fieldNode3 addAttributeWithName:@"var" stringValue:@"searchtype"];
        [fieldNode3 addChild:[NSXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"%d",fromGroup]]];
        [xNode addChild:fieldNode3];
    }
        
    if ([type isEqualToString:@"self"]) {
        
        //当前版本号
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString * currentVersion = [NSString stringWithFormat:@"%@",version];//@"1.0.1";
        
        NSXMLElement *fieldNode2 = [NSXMLElement elementWithName:@"field"];
        [fieldNode2 addAttributeWithName:@"type" stringValue:@"text-single"];
        [fieldNode2 addAttributeWithName:@"var" stringValue:@"version"];
        [fieldNode2 addChild:[NSXMLElement elementWithName:@"value" stringValue:currentVersion]];
        [xNode addChild:fieldNode2];
        
        NSXMLElement *fieldNode3 = [NSXMLElement elementWithName:@"field"];
        [fieldNode3 addAttributeWithName:@"type" stringValue:@"text-single"];
        [fieldNode3 addAttributeWithName:@"var" stringValue:@"p"];
        [fieldNode3 addChild:[NSXMLElement elementWithName:@"value" stringValue:@"i"]];
        [xNode addChild:fieldNode3];
        
        NSXMLElement *sourceNode = [NSXMLElement elementWithName:@"field"];
        [sourceNode addAttributeWithName:@"type" stringValue:@"text-single"];
        [sourceNode addAttributeWithName:@"var" stringValue:@"resource"];
        NSString *source = [[[NSString stringWithFormat:@"Water.IM"] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        source = [[source stringByReplacingOccurrencesOfString:@"." withString:@""] lowercaseString];
        [sourceNode addChild:[NSXMLElement elementWithName:@"value" stringValue:source]];
        [xNode addChild:sourceNode];
        
        //当前ip地址
        NSXMLElement *IP_fieldNode = [NSXMLElement elementWithName:@"field"];
        [IP_fieldNode addAttributeWithName:@"type" stringValue:@"text-single"];
        [IP_fieldNode addAttributeWithName:@"var" stringValue:@"IP"];
//            [IP_fieldNode addChild:[NSXMLElement elementWithName:@"value" stringValue:[EMTIPAddress getDeviceWANIPAdress]]];
        [xNode addChild:IP_fieldNode];
        
    }
        if ([type isEqualToString:@"jid"])
        {
            NSString * searchUserJID_user   = [key JID_user];
            NSString * searchUserJID_domain = [key JID_domain];
            
            NSXMLElement *fieldNode2 = [NSXMLElement elementWithName:@"field"];
            [fieldNode2 addAttributeWithName:@"type" stringValue:@"text-single"];
            [fieldNode2 addAttributeWithName:@"var" stringValue:@"user"];
            [fieldNode2 addChild:[NSXMLElement elementWithName:@"value" stringValue:searchUserJID_user]];
            [xNode addChild:fieldNode2];
            
            NSXMLElement *fieldNode3 = [NSXMLElement elementWithName:@"field"];
            [fieldNode3 addAttributeWithName:@"type" stringValue:@"text-single"];
            [fieldNode3 addAttributeWithName:@"var" stringValue:@"server"];
            [fieldNode3 addChild:[NSXMLElement elementWithName:@"value" stringValue:searchUserJID_domain]];
            [xNode addChild:fieldNode3];
    }
    
    [xNode addChild:fieldsingleNode];
    [xNode addChild:fieldNode1];
    [iq addChild:xNode];
    
    return iq;
}


+ (void)parse_IQ_SearchUserInfo:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //搜索失败
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if ([[errorElement stringValue] isEqualToString:@"inexists"]) {
            //用户不存在
            if (parseResult) {
                parseResult(NO, @{@"error":[errorElement stringValue]});
            }
        }
        else{
            //搜索出错
            if (parseResult) {
                parseResult(NO, @{@"error":[errorElement stringValue]});
            }
        }
    }
    else{
        //搜索成功
        NSXMLElement *itemlistElement = [iq elementForName:@"itemlist"];
        NSMutableDictionary * xmlitemDict  = [[NSMutableDictionary alloc] init];
        
        NSArray *itemAttributes = [itemlistElement attributes];
        for (DDXMLNode *node in itemAttributes) {
            [xmlitemDict setObject:node.stringValue forKey:node.name];
        }
        
        NSXMLElement *itemElement = [itemlistElement elementForName:@"item"];
        for (NSXMLElement * subElement in itemElement.children) {
            [xmlitemDict setObject:[subElement stringValue] forKey:[subElement name]];
        }
        
        NSXMLElement *hostlistElement = [itemlistElement elementForName:@"hostlist"];
        if (hostlistElement) {
            NSMutableArray * hostlist = [NSMutableArray arrayWithCapacity:hostlistElement.childCount];
            for (NSXMLElement * subElement in hostlistElement.children) {
                [hostlist addObject:[subElement stringValue]];
            }
            [xmlitemDict setObject:hostlist forKey:[hostlistElement name]];
        }
        
        if (parseResult) {
            parseResult(YES, xmlitemDict);
        }
    }
}




@end
