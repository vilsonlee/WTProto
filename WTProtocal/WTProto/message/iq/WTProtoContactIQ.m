//
//  WTProtoContactIQ.m
//  WTProtocalKit
//
//  Created by Mark on 2020/1/2.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoContactIQ.h"
#import "WTProtoIQ.h"
#import "WTProtoUser.h"
#import <XMPPFramework/XMPPStream.h>


@implementation WTProtoContactIQ

#pragma mark - Base

+(NSXMLElement *)xNode{
    NSXMLElement *xNode = [NSXMLElement elementWithName:@"x"];
    [xNode addAttributeWithName:@"xmlns" stringValue:@"jabber:x:data"];
    [xNode addAttributeWithName:@"type" stringValue:@"submit"];
    return xNode;
}


+(NSXMLElement *)fieldNodeWithType:(NSString *)typeValue varName:(NSString *)varName childValue:(id)childValue{
    
    NSXMLElement *fieldNode = [NSXMLElement elementWithName:@"field"];
    [fieldNode addAttributeWithName:@"type" stringValue:typeValue];
    [fieldNode addAttributeWithName:@"var" stringValue:varName];
    
    if ([childValue isKindOfClass:[NSString class]]) {
        [fieldNode addChild:[NSXMLElement elementWithName:@"value" stringValue:childValue]];
    }else if ([childValue isKindOfClass:[NSArray class]]){
        for (NSString * childStr in childValue) {
            [fieldNode addChild:[NSXMLElement elementWithName:@"value" stringValue:childStr]];
        }
    }
    
    return fieldNode;
}

#pragma mark - createIQ
+ (WTProtoIQ *)IQ_GetContactsByFromUser:(WTProtoUser *)fromUser matchableContacts:(NSArray *)matchableContacts phoneCode:(NSString *)phoneCode type:(NSString *)emptyType nickName:(NSString *)nickName userPhone:(NSString *)userPhone{
    
    //匹配好友列表并获取好友列表，type 需要用 set
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
        
    NSXMLElement *xNode = [self xNode];
    
    //执行的业务名
    NSXMLElement *bussinessNode = [self fieldNodeWithType:@"list-single" varName:@"bussiness" childValue:@"contacts"];
    [xNode addChild:bussinessNode];

    //是否已有缓存联系人
    if ([emptyType isEqualToString:@"isEmpty"]) {
        NSXMLElement *fieldNode3 = [self fieldNodeWithType:@"list-single" varName:@"isempty" childValue:@"true"];
        [xNode addChild:fieldNode3];
    }
    
    //手机地区码
    NSXMLElement *fieldNode4 = [self fieldNodeWithType:@"list-single" varName:@"phonecode" childValue:phoneCode];
    [xNode addChild:fieldNode4];
    
    //用户昵称
    NSXMLElement *fieldNode5 = [self fieldNodeWithType:@"list-single" varName:@"nickname" childValue:nickName];
    [xNode addChild:fieldNode5];
    
    //用户手机号
    NSXMLElement *fieldNode6 = [self fieldNodeWithType:@"list-single" varName:@"phone" childValue:userPhone];
    [xNode addChild:fieldNode6];
    
    //需要匹配的手机联系人号码
    NSXMLElement *fieldNode = [self fieldNodeWithType:@"list-multi" varName:@"phonelist" childValue:matchableContacts];
    [xNode addChild:fieldNode];
    
    [iq addChild:xNode];
    
    
    NSString *outgoingStr = [iq compactXMLString];
    NSLog(@"contact ==== %@", outgoingStr);
    
    return iq;
}



// 获取联系人详情, 通过手机号/wchatid/jid 搜索查询用户
+ (WTProtoIQ *)IQ_GetUserDetailsWithKeyWord:(NSString *)keyWord keyType:(WTProtoGetContactDetailsKeyType)keyType searchFromGroup:(BOOL)fromGroup source:(NSString *)source IPAddress:(NSString *)IPAddress fromUser:(WTProtoUser *)fromUser toUser:(WTProtoUser *)toUser{
    
    NSString * keyTypeStr = @"jid";
    switch (keyType) {
        case WTProtoGetContactDetailsKeyType_JID:
            keyTypeStr = @"jid";
            break;
        case WTProtoGetContactDetailsKeyType_ID:
            keyTypeStr = @"wchatid";
                break;
        case WTProtoGetContactDetailsKeyType_SELF:
            keyTypeStr = @"self";
                break;
        case WTProtoGetContactDetailsKeyType_Phone:
            keyTypeStr = @"phone";
                break;
        case WTProtoGetContactDetailsKeyType_QRcode:
            keyTypeStr = @"qrcode";
                break;
            
    }
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toUser elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];

    NSXMLElement *xNode = [self xNode];
    
    //执行的业务名
    NSXMLElement *fieldsingleNode = [self fieldNodeWithType:@"text-single" varName:@"bussiness" childValue:@"userinfo"];
    [xNode addChild:fieldsingleNode];

    //执行获取方式的类型
    NSXMLElement *fieldNode1 = [self fieldNodeWithType:@"text-single" varName:@"optype" childValue:keyTypeStr];
    [xNode addChild:fieldNode1];
    
    if (keyWord.length) {
        NSXMLElement *fieldNode2 = [self fieldNodeWithType:@"text-single" varName:keyTypeStr childValue:keyWord];
        [xNode addChild:fieldNode2];
        
        NSXMLElement *fieldNode3 = [self fieldNodeWithType:@"text-single" varName:@"searchtype" childValue:[NSString stringWithFormat:@"%d",fromGroup]];
        [xNode addChild:fieldNode3];
    }
    
    if ([keyTypeStr isEqualToString:@"self"]) {
        
        //当前版本号
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString * currentVersion = [NSString stringWithFormat:@"%@",version];//@"1.0.1";
        
        NSXMLElement *fieldNode2 = [self fieldNodeWithType:@"text-single" varName:@"version" childValue:currentVersion];
        [xNode addChild:fieldNode2];
        
        NSXMLElement *fieldNode3 = [self fieldNodeWithType:@"text-single" varName:@"p" childValue:@"i"];
        [xNode addChild:fieldNode3];
        
        //    NSString *source = [[kProductName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];//使用productName，去除空格，小写, 去掉Water.IM的"."。
        NSString *edit_source = [[source stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        edit_source = [[edit_source stringByReplacingOccurrencesOfString:@"." withString:@""] lowercaseString];
        
        NSXMLElement *sourceNode = [self fieldNodeWithType:@"text-single" varName:@"resource" childValue:edit_source];
        [xNode addChild:sourceNode];
        
        //当前ip地址
        NSXMLElement *IP_fieldNode = [self fieldNodeWithType:@"text-single" varName:@"IP" childValue:IPAddress];
        [xNode addChild:IP_fieldNode];
        
    }
        
    if ([keyTypeStr isEqualToString:@"jid"]) {
        
//        XMPPJID * searchUserJID = [XMPPJID jidWithString:key];
        NSString * jid_user = [keyWord componentsSeparatedByString:@"@"].firstObject;
        NSString * searchUserJID_user = jid_user;
        NSString * jid_bare = [keyWord componentsSeparatedByString:@"/"].firstObject;
        NSString * jid_domain_resource = [jid_bare componentsSeparatedByString:@"@"].lastObject;
        NSString * jid_domain = [jid_domain_resource componentsSeparatedByString:@"/"].firstObject;
        NSString * searchUserJID_domain = jid_domain;
        
        NSXMLElement *fieldNode2 = [self fieldNodeWithType:@"text-single" varName:@"user" childValue:searchUserJID_user];
        [xNode addChild:fieldNode2];
        
        NSXMLElement *fieldNode3 = [self fieldNodeWithType:@"text-single" varName:@"server" childValue:searchUserJID_domain];
        [xNode addChild:fieldNode3];
    }

    [iq addChild:xNode];
        
    return iq;
}

//设置好友备注名
+ (WTProtoIQ *)IQ_SetFriend_MemoName:(NSString *)memoName
                                jid:(NSString *)jidstr
                           fromUser:(WTProtoUser *)fromUser
                             toUser:(WTProtoUser *)toUser{
    
    
    NSString * type = @"friendnote";
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    [iq addAttributeWithName:@"to" stringValue:jidstr];

    
    NSXMLElement *xNode = [self xNode];
    
    NSXMLElement *fieldsingleNode = [self fieldNodeWithType:@"text-single" varName:@"bussiness" childValue:@"starnote"];
    [xNode addChild:fieldsingleNode];
    
    NSXMLElement *fieldNode1 = [self fieldNodeWithType:@"text-single" varName:@"optype" childValue:type];
    [xNode addChild:fieldNode1];
    
    NSXMLElement *fieldNode2 = [self fieldNodeWithType:@"text-single" varName:type childValue:memoName];
    [xNode addChild:fieldNode2];
    
    [iq addChild:xNode];
    
    return iq;
    
}


+ (WTProtoIQ *)IQ_SetFriend_StarMarkWithJid:(NSString *)jidstr
                                  straState:(BOOL)state
                                   fromUser:(WTProtoUser *)fromUser
                                     toUser:(WTProtoUser *)toUser{
   
    NSString * type = @"starfriend";
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    [iq addAttributeWithName:@"to" stringValue:jidstr];

    NSXMLElement *xNode = [self xNode];
    
    NSXMLElement *fieldsingleNode = [self fieldNodeWithType:@"text-single" varName:@"bussiness" childValue:@"starnote"];
    [xNode addChild:fieldsingleNode];
    
    NSXMLElement *fieldNode1 = [self fieldNodeWithType:@"text-single" varName:@"optype" childValue:type];
    [xNode addChild:fieldNode1];

    NSXMLElement *fieldNode2 = [self fieldNodeWithType:@"text-single" varName:type childValue:state?@"1":@"0"];
    [xNode addChild:fieldNode2];
    
    [iq addChild:xNode];
    
    return iq;
}





#pragma mark -  返回结果解释

//匹配好友并获取好友列表 返回结果处理方法
+ (void)parse_IQ_GetContactsAndMatchFriends:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, NSInteger matchcount, id info))parseResult{
    
        NSXMLElement *errorElement = [iq elementForName:@"error"];
        if (errorElement != nil) {
            //FIXME: 空也是返回error?..
            NSLog(@"匹配联系人获取出错");
            parseResult(NO, 0,[errorElement stringValue]);
        }
        else
        {
            //本地保存匹配的通讯录，归档化？？？缓存？？
            NSXMLElement * itemlistElement = [iq elementForName:@"itemlist"];
            NSArray * contactItemList = [itemlistElement elementsForName:@"item"];
            NSLog(@"\n\n contactItemList = %@ \n\n",contactItemList);
            
            //匹配的好友数量
            NSInteger matchcount = 0;
            if ([itemlistElement attributeStringValueForName:@"matchcount"]) {
                matchcount = [[itemlistElement attributeStringValueForName:@"matchcount"] integerValue];
            }
                        
            NSMutableArray * contactDataArr = [NSMutableArray array];
            if (contactItemList) {
                //转换数据
                for (NSXMLElement * subElem in contactItemList) {
                    NSMutableDictionary * itemDict = [[NSMutableDictionary alloc] init];
                    for (NSXMLElement * attelement in subElem.attributes) {
                        [itemDict setObject:[attelement stringValue] forKey:[attelement name]];
                    }
                    for (NSXMLElement * element in subElem.children) {
                        [itemDict setObject:[element stringValue] forKey:[element name]];
                    }
                    [contactDataArr addObject:itemDict];
                }
            }
            
            parseResult(YES, matchcount, contactDataArr);
        }
    
}


//获取联系人详情, 通过手机号/wchatid/jid 搜索查询用户 返回结果处理方法
+ (void)parse_IQ_GetUserDetails:(XMPPIQ *)iq parseResult:(void (^)(BOOL, id _Nonnull))parseResult{
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //搜索失败
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if ([[errorElement stringValue] isEqualToString:@"inexists"]) {
            //用户不存在
        }
        else{
            //搜索出错等其他错误
        }
        parseResult(NO, [errorElement stringValue]);
    }
    else{
        //搜索成功
//        NSString *outgoingStr = [iq compactXMLString];
//        NSDictionary * xmlDict = [NSDictionary dictionaryWithXMLString:outgoingStr];
//        NSLog(@"\n\nxmlDict === %@\n\n",xmlDict);
        
        NSXMLElement *itemlistElement = [iq elementForName:@"itemlist"];
        NSMutableDictionary * contactInfoDict  = [[NSMutableDictionary alloc] init];
        
        NSArray *itemAttributes = [itemlistElement attributes];
        for (DDXMLNode *node in itemAttributes) {
            [contactInfoDict setObject:node.stringValue forKey:node.name];
        }
        
        NSXMLElement *itemElement = [itemlistElement elementForName:@"item"];
        for (NSXMLElement * subElement in itemElement.children) {
            [contactInfoDict setObject:[subElement stringValue] forKey:[subElement name]];
        }
        
        
        //相询自己的个人信息时会返回 hostlist
        NSXMLElement *hostlistElement = [itemlistElement elementForName:@"hostlist"];
        if (hostlistElement) {
            NSMutableArray * hostlist = [NSMutableArray arrayWithCapacity:hostlistElement.childCount];
            for (NSXMLElement * subElement in hostlistElement.children) {
                [hostlist addObject:[subElement stringValue]];
            }
            [contactInfoDict setObject:hostlist forKey:[hostlistElement name]];
        }
        
        parseResult(YES, contactInfoDict);
    }
    
}


//设置好友备注名  返回结果处理方法
+ (void)parse_IQ_SetFriend_MemoName:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, @"操作失败，请重试");
    }
    else{
        NSXMLElement *itemElement = [iq elementForName:@"item"];
        parseResult(YES, [itemElement stringValue]);
    }
    
}


//联系人 - 星标好友标记设置  返回结果处理方法
+ (void)parse_IQ_SetFriend_StarMark:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
 
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, @"操作失败，请重试");
    }
    else{
        NSXMLElement *itemElement = [iq elementForName:@"item"];
        parseResult(YES, [itemElement stringValue]);
    }
    
}

@end
