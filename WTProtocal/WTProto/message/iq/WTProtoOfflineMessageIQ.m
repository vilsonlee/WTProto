//
//  WTProtoOfflineMessageIQ.m
//  WTProtocalKit
//
//  Created by Mark on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoOfflineMessageIQ.h"
#import "WTProtoIQ.h"
#import "WTProtoUser.h"
#import <XMPPFramework/XMPPStream.h>

@implementation WTProtoOfflineMessageIQ

+ (WTProtoIQ *)IQ_GetSingleChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID timestamp:(NSString *)timestamp{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toID elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    
    NSXMLElement *offlineNode = [NSXMLElement elementWithName:@"offline" xmlns:@"http://jabber.org/protocol/offline"];
    //新版本app调用旧接口，区分新旧版本的设置，有此值的，调用旧接口不能返回带自增id的数据
    [offlineNode addAttributeWithName:@"offset" stringValue:@"1"];
    
    if (timestamp.length) {
        [offlineNode addAttributeWithName:@"index" stringValue:timestamp];
    }
    
    NSXMLElement *fetchNode = [NSXMLElement elementWithName:@"fetch" xmlns:@"http://jabber.org/protocol/offline"];
    [fetchNode setStringValue:@"true"];
    [offlineNode addChild:fetchNode];

    [iq addChild:offlineNode];
    
    return iq;
}

+ (WTProtoIQ *)IQ_GetSingleChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toID elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    
    NSXMLElement *offlineNode = [NSXMLElement elementWithName:@"offline" xmlns:@"http://jabber.org/protocol/offline"];
    
    NSXMLElement *itemNode = [NSXMLElement elementWithName:@"item" xmlns:@"http://jabber.org/protocol/offline"];
    [itemNode addAttributeWithName:@"action" stringValue:@"view"];
    [offlineNode addChild:itemNode];
    
    [iq addChild:offlineNode];
    
    return iq;
}


+ (WTProtoIQ *)IQ_GetGroupChatOfflineListWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toID elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
        
    NSXMLElement *queryNode = [NSXMLElement elementWithName:@"query" xmlns:@"urn:xmpp:mam:tmp"];
    [queryNode addAttributeWithName:@"queryid" stringValue:@"1"];
    [iq addChild:queryNode];
    
    return iq;
}

+ (WTProtoIQ *)IQ_GetGroupChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toID elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
       
    NSXMLElement *queryNode = [NSXMLElement elementWithName:@"query" xmlns:@"urn:xmpp:mam:0"];
    [iq addChild:queryNode];

    return iq;
}


+ (WTProtoIQ *)IQ_GetSingleChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID startIndex:(NSString *)start endIndex:(NSString *)end ascending:(BOOL)ascending chatJid:(NSString *)chatJid{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toID elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    
    NSXMLElement *offlineNode = [NSXMLElement elementWithName:@"offline" xmlns:@"http://jabber.org/protocol/offline"];
    
    NSXMLElement *fetchNode = [NSXMLElement elementWithName:@"fetch" xmlns:@"http://jabber.org/protocol/offline"];
    [fetchNode setStringValue:@"true"];
    [offlineNode addChild:fetchNode];

    NSXMLElement *itemNode = [NSXMLElement elementWithName:@"item" xmlns:@"http://jabber.org/protocol/offline"];
    [itemNode addAttributeWithName:@"action" stringValue:@"view"];
    [offlineNode addChild:itemNode];

    [offlineNode addAttributeWithName:@"jid" stringValue:chatJid];
    [offlineNode addAttributeWithName:@"start" stringValue:start];
    [offlineNode addAttributeWithName:@"end" stringValue:end];
    [offlineNode addAttributeWithName:@"offset" stringValue:ascending ? @"asc":@"desc"];

    [iq addChild:offlineNode];
    
    return iq;
}


+ (WTProtoIQ *)IQ_GetGroupChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID timestamp:(NSString *)timestamp chatJid:(NSString *)chatJid{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toID elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    
    NSXMLElement *offlineNode = [NSXMLElement elementWithName:@"query" xmlns:@"urn:xmpp:mam:tmp"];
    [offlineNode addAttributeWithName:@"queryid" stringValue:@"1"];

    NSXMLElement *withNode = [NSXMLElement elementWithName:@"with" stringValue:chatJid];
    [withNode setXmlns:@"urn:xmpp:mam:tmp"];
    [offlineNode addChild:withNode];

    if (timestamp.length) {
        NSXMLElement *endNode = [NSXMLElement elementWithName:@"end" stringValue:timestamp];
        [endNode setXmlns:@"urn:xmpp:mam:tmp"];
        [offlineNode addChild:endNode];
    }
    [iq addChild:offlineNode];

    return iq;
}


+ (WTProtoIQ *)IQ_GetGroupChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID startIndex:(NSString *)start endIndex:(NSString *)end ascending:(BOOL)ascending chatJid:(NSString *)chatJid{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:toID elementID:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.bare];
    
    NSXMLElement *offlineNode = [NSXMLElement elementWithName:@"query" xmlns:@"urn:xmpp:mam:0"];

    NSXMLElement *withNode = [NSXMLElement elementWithName:@"with" stringValue:chatJid];
    [withNode setXmlns:@"urn:xmpp:mam:tmp"];
    [offlineNode addChild:withNode];

    NSXMLElement *startNode = [NSXMLElement elementWithName:@"start" numberValue:[NSNumber numberWithInteger:[start integerValue]]];
    [startNode setXmlns:@"urn:xmpp:mam:tmp"];
    [offlineNode addChild:startNode];

    if (end.length) {
        NSXMLElement *endNode = [NSXMLElement elementWithName:@"new_end" numberValue:[NSNumber numberWithInteger:[end integerValue]]];
        [endNode setXmlns:@"urn:xmpp:mam:tmp"];
        [offlineNode addChild:endNode];
    }


    NSXMLElement *withtextNode = [NSXMLElement elementWithName:@"withtext" stringValue:ascending ? @"asc":@"desc"];
    [withtextNode setXmlns:@"urn:xmpp:mam:tmp"];
    [offlineNode addChild:withtextNode];

    [iq addChild:offlineNode];
    
    return iq;
}





#pragma mark -  返回结果解释

+ (void)parse_IQ_GetSingleChatOfflineMessage:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, BOOL isEmpty, id info))parseResult{

    NSLog(@"单聊离线拉取 结果 iq = %@", [iq compactXMLString]);

    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, YES,[errorElement stringValue]);
        //拉取失败了，重试？
    }
    else{

        BOOL isEmpty = [[iq elementForName:@"offline_empty"] stringValueAsBool];
        NSArray * messageList = [iq elementsForName:@"message"];
        NSLog(@"(旧方式)单聊离线消息拉取 messageList.count = %ld, messageList = %@", messageList.count, messageList);
        parseResult(YES, isEmpty, messageList);
    }
}


+ (void)parse_IQ_GetSingleChatOfflineListDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    NSLog(@"单聊离线动态拉取 结果 iq = %@", [iq compactXMLString]);

    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO,[errorElement stringValue]);
        //拉取失败了，重试？
    }
    else{

        DDXMLElement * singleChatListElement = [iq elementForName:@"single_chat_list"];
        NSArray * chatList = [singleChatListElement elementsForName:@"single_chat"];
        NSLog(@"(新方式)单聊动态拉取 单聊离线列表 chatList.count = %ld, chatList = %@", chatList.count, chatList);
        parseResult(YES, chatList);
    }
    
}


+ (void)parse_IQ_GetSingleChatOfflineMessageDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    NSLog(@"单聊离线拉取 结果 iq = %@", [iq compactXMLString]);

    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO,[errorElement stringValue]);
        //拉取失败了，重试？
    }
    else{

        NSArray * messageList = [iq elementsForName:@"message"];
        NSLog(@"(新方式)单聊离线消息拉取 messageList.count = %ld, messageList = %@", messageList.count, messageList);
        parseResult(YES, messageList);
    }
    
}


+ (void)parse_IQ_GetGroupChatOfflineList:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    NSLog(@"群聊动态拉取 有离线消息的群聊列表IQ 旧 结果 = %@", [iq compactXMLString]);
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO, [errorElement stringValue]);
        //拉取失败了，重试？
    }
    else{
                
//        NSXMLElement *queryElement = [iq elementForName:@"query"];
        NSArray * queryList = [iq elementsForName:@"query"];
        NSLog(@"count = %zd groupElemsList = %@", queryList.count,queryList);
        
        parseResult(YES, queryList);
    }
    
}


+ (void)parse_IQ_GetGroupChatOfflineListDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    
    /*
     Resp:
     返回有消息的群列表
     //2019.10.15 改
     <iq type="result" id=ID>
         <set jid = "群jid">
             <count>未读消息数(int)</count>
             <index>最新的一条消息的递增ID(int)</index>
             <message></message>
         </set>
     </iq>
     */

    NSLog(@"群聊动态拉取 有离线消息的群聊列表IQ 新 结果 = %@", [iq compactXMLString]);

    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //        NSLog(@"elementForName = %@",[errorElement stringValue]);
        //最近有离线消息的群聊列表，失败
        parseResult(NO, [errorElement stringValue]);
        //拉取失败了，重试？
    }
    else{
        
    //        NSXMLElement *queryElement = [iq elementForName:@"query"];
        NSArray * queryList = [iq elementsForName:@"set"];
        NSLog(@"groupElemsList = %@", queryList);
        
        parseResult(YES, queryList);
    }
    
}


+ (void)parse_IQ_GetGroupChatOfflineMessage:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, BOOL isEmpty, id info))parseResult{
    /*
     Resp:
     <iq type="result" id=ID>
     <query xmlns="urn:xmpp:mam:tmp"></query>
     <group_offline_empty>ISEMPTY</group_offline_empty>
     <message></message>
     <message></message>
     <message></message>
     </iq>
     ISEMPTY：是否拉完离线群消息 1拉完了/0没拉完
     */
    
    NSLog(@"群聊离线消息 旧 结果 iq = %@", [iq compactXMLString]);
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
//        NSLog(@"群聊离线消息 旧 errorElement = %@",[errorElement stringValue]);
        parseResult(NO, YES,[errorElement stringValue]);
        //拉取失败了，重试？
    }
    else{
        //        completionHandler(YES, @"成功");
        
        BOOL isEmpty = [[iq elementForName:@"group_offline_empty"] stringValueAsBool];
        NSArray * messageList = [iq elementsForName:@"message"];
        NSLog(@"群聊离线消息 旧 messageList.count = %lu , empty = %@,messageList.firstObject = %@, messageList.lastObject = %@", (unsigned long)messageList.count,isEmpty?@"YES":@"NO",messageList.firstObject,messageList.lastObject);
        parseResult(YES, isEmpty, messageList);
    }
}

+ (void)parse_IQ_GetGroupChatOfflineMessageDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult{
    /*
     Resp:
     拉该群聊的消息
     <iq type="result" id=ID>
         <message>
             <increment_id/>
         </message>
         <message></message>
         <message></message>
     </iq>
     **递增的id在message标签内的increment_id, 跟delay同级
     */
        
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        //        NSLog(@"elementForName = %@",[errorElement stringValue]);
        parseResult(NO,[errorElement stringValue]);
        //拉取失败了，重试？
        NSLog(@"群聊离线消息 新 报错 = %@", [iq compactXMLString]);
    }
    else{
        //        completionHandler(YES, @"成功");
//        NSLog(@"iq = %@", [iq compactXMLString]);
        
        BOOL isEmpty = [[iq elementForName:@"group_offline_empty"] stringValueAsBool];
        NSArray * messageList = [iq elementsForName:@"message"];
        NSLog(@"群聊离线消息 新 = %@, isEmpty = %@", [iq compactXMLString], isEmpty?@"yes":@"no");
        NSLog(@"群聊离线消息 新 messageList.count = %ld ,messageList = %@", messageList.count,messageList);
        parseResult(YES, messageList);
    }
}


@end
