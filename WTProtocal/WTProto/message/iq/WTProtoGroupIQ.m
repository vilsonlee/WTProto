//
//  WTProtoGroupIQ.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoGroupIQ.h"
#import "WTProtoIQ.h"
#import "WTProtoUser.h"
#import "NSString+pyFirstLetter.h"
#import <WTXMPPFramework/XMPPStream.h>

@implementation WTProtoGroupIQ


#pragma mark -- 群相关IQ请求
+ (WTProtoIQ *)IQ_GetRoomInfoWithRoomID:(WTProtoUser* )roomID
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCOwnerNamespace];//config
    
    WTProtoIQ *getRoomIQ = [WTProtoIQ iqWithType:@"get" to:roomID
                                       elementID:[XMPPStream generateUUID]
                                           child:query];
    
    return getRoomIQ;
}

+ (WTProtoIQ *)IQ_InviteUserSubscribesWithFromUser:(WTProtoUser*)fromUser
                                            RoomID:(WTProtoUser *)roomID
                                          roomName:(NSString *)roomName
                                          joinType:(NSString *)jointype
                                           Friends:(NSArray *)friends
                                   inviterNickName:(NSString *)inviterNickName
                                         inviterID:(NSString *)inviterID
                                            reason:(NSString *)reason
{
    
    WTProtoIQ * iq = [WTProtoIQ iq];
    
    [iq addAttributeWithName:@"id" stringValue:@"subscribesRoomByOwners"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",fromUser.full]];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",roomID.full]];
        
    NSXMLElement *invitelistSub = [NSXMLElement elementWithName:@"subscribelist" xmlns:@"urn:xmpp:mucsub:0"];

    //群名
    [invitelistSub addAttributeWithName:@"groupname" stringValue:roomName];
    //群jid
    [invitelistSub addAttributeWithName:@"groupjid" stringValue:roomID.full];
    //入群方式
    [invitelistSub addAttributeWithName:@"joinstyle" stringValue:jointype];
        
    if ([jointype isEqualToString:@"0"]) {
        //成员邀请加入
        for (NSDictionary *modelDict in friends) {
            NSXMLElement *inviteSub = [NSXMLElement elementWithName:@"subscribe"];
            [inviteSub addAttributeWithName:@"nick" stringValue:[modelDict objectForKey:@"nickname"]];
            [inviteSub addAttributeWithName:@"jid" stringValue:[modelDict objectForKey:@"jid"]];
            [inviteSub addAttributeWithName:@"save" stringValue:@""];
            [inviteSub addAttributeWithName:@"ispush" stringValue:@""];
            [inviteSub addAttributeWithName:@"time" stringValue:@""];
            [inviteSub addAttributeWithName:@"identity" stringValue:@""];
                
            NSXMLElement *iconElement = [NSXMLElement elementWithName:@"event"];
            [iconElement addAttributeWithName:@"node" stringValue:[modelDict objectForKey:@"iconurl"]];
            [inviteSub addChild:iconElement];
                
            [invitelistSub addChild:inviteSub];
        }
        
        [iq addChild:invitelistSub];
            
        //邀请者昵称
        [invitelistSub addAttributeWithName:@"ownernick" stringValue:inviterNickName];
        //邀请者Jid
        [invitelistSub addAttributeWithName:@"ownerjid"  stringValue:inviterID];
        //邀请者头像icon
        [invitelistSub addAttributeWithName:@"ownericon" stringValue:@""];
        //邀请理由
        [invitelistSub addAttributeWithName:@"reason" stringValue:reason];
        
    }
    else{
        //扫二维码加入
        //邀请者信息
        NSDictionary *modelDict = friends.firstObject;

        NSXMLElement *inviteSub = [NSXMLElement elementWithName:@"subscribe"];
        [inviteSub addAttributeWithName:@"nick" stringValue:@""];
        [inviteSub addAttributeWithName:@"jid" stringValue:@""];
        [inviteSub addAttributeWithName:@"iconurl" stringValue:@""];
        [inviteSub addAttributeWithName:@"save" stringValue:@""];
        [inviteSub addAttributeWithName:@"ispush" stringValue:@""];
        [inviteSub addAttributeWithName:@"time" stringValue:@""];
        [inviteSub addAttributeWithName:@"identity" stringValue:@""];
        [invitelistSub addChild:inviteSub];
        [iq addChild:invitelistSub];
        
        //邀请者昵称
        [invitelistSub addAttributeWithName:@"ownernick" stringValue:[modelDict objectForKey:@"nickname"]];
        //邀请者Jid
        [invitelistSub addAttributeWithName:@"ownerjid" stringValue:[modelDict objectForKey:@"jid"]];
        //邀请者头像icon
        [invitelistSub addAttributeWithName:@"ownericon" stringValue:[modelDict objectForKey:@"iconurl"]];
        
    }
    
    return iq;
}


+ (WTProtoIQ *)IQ_GetGroupListByFromUser:(WTProtoUser *)fromUser
{
    WTProtoIQ * iq = [WTProtoIQ iq];
    [iq addAttributeWithName:@"id" stringValue:@"chatGroupList"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",fromUser]];
    
    NSXMLElement *xNode = [NSXMLElement elementWithName:@"x"];
    [xNode addAttributeWithName:@"xmlns" stringValue:@"jabber:x:data"];
    [xNode addAttributeWithName:@"type" stringValue:@"form"];
    
    NSXMLElement *fieldsingleNode = [NSXMLElement elementWithName:@"field"];
    [fieldsingleNode addAttributeWithName:@"type" stringValue:@"list-single"];
    [fieldsingleNode addAttributeWithName:@"var" stringValue:@"bussiness"];
    [fieldsingleNode addChild:[NSXMLElement elementWithName:@"value" stringValue:@"myroomlist"]];
    
    NSXMLElement *fieldNode0 = [NSXMLElement elementWithName:@"field"];
    [fieldNode0 addAttributeWithName:@"type" stringValue:@"list-single"];
    [fieldNode0 addAttributeWithName:@"var" stringValue:@"from"];
    [fieldNode0 addChild:[NSXMLElement elementWithName:@"value" stringValue:fromUser.bare]];
    
    NSXMLElement *fieldNode1 = [NSXMLElement elementWithName:@"field"];
    [fieldNode1 addAttributeWithName:@"type" stringValue:@"list-single"];
    [fieldNode1 addAttributeWithName:@"var" stringValue:@"roomserver"];
    
    ///FIXME:VSXMPP_HOST
//    [fieldNode1 addChild:[NSXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"conference.%@",VSXMPP_HOST]]];
    [fieldNode1 addChild:[NSXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"conference.%@",@""]]];
    
    [xNode addChild:fieldsingleNode];
    [xNode addChild:fieldNode1];
    [xNode addChild:fieldNode0];
    [iq addChild:xNode];
    
    return iq;
}



+ (WTProtoIQ *)IQ_GetGroupMembersListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID
{
    
    ///FIXME:
    WTProtoIQ * iq = [WTProtoIQ iq];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",fromUser]];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",roomID.full]];
    [iq addAttributeWithName:@"xml:lang" stringValue:@"en"];//xml:lang='en'

    //urn:xmpp:mucsub:0
    NSXMLElement *subscribelistSub = [NSXMLElement elementWithName:@"subscribelist" xmlns:@"urn:xmpp:mucsub:0"];
        
    /*
     Joinstyle: 1\0 （1是拿备注，0不拿）
    **换设备时，群资料为空的时候，才拿备注，其余刷新群成员列表不拿备注
    */
//    [subscribelistSub addAttributeWithName:@"joinstyle" stringValue:bringMemoName ? @"1":@"0"];
    [iq addChild:subscribelistSub];
    
    return iq;
}





+ (WTProtoIQ *)IQ_ExitUserSubscribesWithFromUser:(WTProtoUser *)fromUser
                                          RoomID:(WTProtoUser *)roomID
                                        roomName:(NSString *)roomName
                                     roomOwnerID:(WTProtoUser *)roomOwnerID
                             memberGroupNickName:(NSString *)nickName
{
    
   return [[self class]IQ_RemoveMemberUnscribesChatRoomWithFromUser:fromUser
                                                             RoomID:roomID
                                                           roomName:roomName
                                                        roomOwnerID:roomOwnerID
                                                memberGroupNickName:nickName
                                                            Friends:@[]];
}


+(WTProtoIQ *)IQ_RemoveMemberUnscribesChatRoomWithFromUser:(WTProtoUser *)fromUser
                                                    RoomID:(WTProtoUser *)roomID
                                                  roomName:(NSString *)roomName
                                               roomOwnerID:(WTProtoUser *)roomOwnerID
                                       memberGroupNickName:(NSString *)nickName
                                                   Friends:(NSArray *)friends
{
    WTProtoIQ * iq = [WTProtoIQ iq];
    [iq addAttributeWithName:@"id" stringValue:@"removeUserFromChatGroup"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",roomID.full]];
        
    NSXMLElement *unSubscribelistNode = [NSXMLElement elementWithName:@"unsubscribelist" xmlns:@"urn:xmpp:mucsub:0"];
    for (NSDictionary *modelDict in friends) {
        NSXMLElement *unsubscribeNode = [NSXMLElement elementWithName:@"unsubscribe"];
        [unsubscribeNode addAttributeWithName:@"nick" stringValue:[modelDict objectForKey:@"nickname"]];
        [unsubscribeNode addAttributeWithName:@"jid" stringValue:[modelDict objectForKey:@"jid"]];
        [unSubscribelistNode addChild:unsubscribeNode];
        
    }
    //群名
    [unSubscribelistNode addAttributeWithName:@"groupname" stringValue:roomName];
    //群jid
    [unSubscribelistNode addAttributeWithName:@"groupjid" stringValue:roomID.full];
    //群的拥有者
    //    [unSubscribelistNode addAttributeWithName:@"groupownerjid" stringValue:roomOwnerID.full];
    //操作者的昵称
    [unSubscribelistNode addAttributeWithName:@"ownernick" stringValue:nickName];
    //操作者的jid
    [unSubscribelistNode addAttributeWithName:@"ownerjid" stringValue:fromUser.full];

    [iq addChild:unSubscribelistNode];
    
    return iq;
}


+ (WTProtoIQ *)IQ_SaveGroupToContactListWithFromUser:(WTProtoUser *)fromUser
                                             RoomJid:(WTProtoUser *)roomID
                                               state:(BOOL)state
{
    WTProtoIQ * iq = [WTProtoIQ iq];
    [iq addAttributeWithName:@"id"   stringValue:@"saveToContactList"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",fromUser.full]];
    [iq addAttributeWithName:@"to"   stringValue:[NSString stringWithFormat:@"%@",roomID.full]];
    
    NSXMLElement *subscribeNode = [NSXMLElement elementWithName:@"subscribe"];
    [subscribeNode addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    if (state) {
        [subscribeNode addAttributeWithName:@"save" stringValue:@"1"];
    }
    else{
        [subscribeNode addAttributeWithName:@"save" stringValue:@"0"];
    }
    [subscribeNode addAttributeWithName:@"nick" stringValue:@""];
    [subscribeNode addAttributeWithName:@"ispush" stringValue:@""];
    
    [iq addChild:subscribeNode];
    
    return iq;
    
}





+ (WTProtoIQ *)IQ_UnDisturbWithFromUser:(WTProtoUser *)fromUser
                                 RoomID:(WTProtoUser *)roomID
                                  state:(BOOL)state
{
    
    
    WTProtoIQ * iq = [WTProtoIQ iq];
    [iq addAttributeWithName:@"id"   stringValue:@"doNotDisturb"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",fromUser.full]];
    [iq addAttributeWithName:@"to"   stringValue:[NSString stringWithFormat:@"%@",roomID.full]];
    
    NSXMLElement *subscribeNode = [NSXMLElement elementWithName:@"subscribe"];
    [subscribeNode addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    if (state) {
        [subscribeNode addAttributeWithName:@"ispush" stringValue:@"0"];
    }
    else{
        [subscribeNode addAttributeWithName:@"ispush" stringValue:@"1"];
    }
    [subscribeNode addAttributeWithName:@"nick" stringValue:@""];
    [subscribeNode addAttributeWithName:@"save" stringValue:@""];
    
    [iq addChild:subscribeNode];
    
    return iq;
}



+ (WTProtoIQ *)IQ_ModifyRoomNickNameWithFromUser:(WTProtoUser *)fromUser
                                          RoomID:(WTProtoUser *)roomID
                                        nickname:(NSString *)newNickname
                                      changeflag:(NSInteger)changeflag
{
    WTProtoIQ * iq = [WTProtoIQ iq];
    [iq addAttributeWithName:@"id"   stringValue:@"modifyMyRoomNickName"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",fromUser.full]];
    [iq addAttributeWithName:@"to"   stringValue:[NSString stringWithFormat:@"%@",roomID.full]];
        
    NSXMLElement *subscribeNode = [NSXMLElement elementWithName:@"subscribe"];
    [subscribeNode addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    [subscribeNode addAttributeWithName:@"nick" stringValue:newNickname];
    if (changeflag == 0) {
        [subscribeNode addAttributeWithName:@"changeflag" integerValue:changeflag];
    }
    [subscribeNode addAttributeWithName:@"save" stringValue:@""];
    [subscribeNode addAttributeWithName:@"ispush" stringValue:@""];
    
    [iq addChild:subscribeNode];
        
    return iq;
    
}


+ (WTProtoIQ *)IQ_ExChangeGroupOwnerAuthorityWithFromUser:(WTProtoUser *)fromUser
                                                   RoomID:(WTProtoUser *)roomID
                                              newOwernick:(NSString *)newOwernick
                                                newOwerID:(WTProtoUser *)newOwerID
{
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" to:roomID];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id"   stringValue:@"changeGroupOwner"];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#admin"];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"affiliation" stringValue:@"owner"];
    [item addAttributeWithName:@"jid"   stringValue:newOwerID.full];
    [item addAttributeWithName:@"nick"  stringValue:newOwernick];

    
    [query addChild:item];
    [iq addChild:query];

    return iq;
    
}


+ (WTProtoIQ *)IQ_SetGroupAdminWithFromUser:(WTProtoUser *)fromUser
                                   Memebers:(NSArray *)member
                                    roomJid:(NSString *)roomJid
                                      style:(NSString *)style
{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" to:[XMPPJID jidWithString:roomJid]];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
        
    NSXMLElement *itemlist = [NSXMLElement elementWithName:@"subscribelist"];
    [itemlist addAttributeWithName:@"reason" stringValue:@"admin"];
    [itemlist addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    if ([style isEqualToString:@"0"]) {
        [itemlist addAttributeWithName:@"joinstyle" stringValue:style];
    }else{
        [itemlist addAttributeWithName:@"joinstyle" stringValue:style];
    }
    
    for (NSDictionary * dict in member) {
        
        NSString * memberJid = [dict objectForKey:@"jid"];
        NSString * memberNick = [dict objectForKey:@"nick"];
        
        NSXMLElement *item = [NSXMLElement elementWithName:@"subscribe"];
//        [item addAttributeWithName:@"affiliation" stringValue:@"owner"];
        [item addAttributeWithName:@"jid" stringValue:memberJid];
        [item addAttributeWithName:@"nick" stringValue:memberNick];
        
        [itemlist addChild:item];
    }
  
    [iq addChild:itemlist];
    
    return iq;
    
}



+ (WTProtoIQ *)IQ_GetGroupQuiteMemberListWithFromUser:(WTProtoUser *)fromUser
                                               RoomID:(WTProtoUser *)roomID
{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:roomID];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *itemlist = [NSXMLElement elementWithName:@"subscribelist"];
    [itemlist addAttributeWithName:@"reason" stringValue:@"quitelist"];
    [itemlist addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];

    [iq addChild:itemlist];
    return iq;
    
}


+ (WTProtoIQ *)IQ_SetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser
                                                RoomID:(WTProtoUser *)roomID
                                              memebers:(NSArray *)member
                                              nickName:(NSString *)nickName
                                                 style:(NSString *)style
{
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" to:roomID];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *itemlist = [NSXMLElement elementWithName:@"subscribelist"];
    [itemlist addAttributeWithName:@"reason" stringValue:@"muc_block"];
    [itemlist addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    //操作者的昵称
    [itemlist addAttributeWithName:@"ownernick" stringValue:nickName];
    //操作者的jid
    [itemlist addAttributeWithName:@"ownerjid" stringValue:fromUser.full];
    if ([style isEqualToString:@"0"]) {
        [itemlist addAttributeWithName:@"joinstyle" stringValue:style];
    }else{
        [itemlist addAttributeWithName:@"joinstyle" stringValue:style];
    }
    
    for (NSDictionary * dict in member) {
        
        NSString * memberJid = [dict objectForKey:@"jid"];
        NSString * memberNick = [dict objectForKey:@"nick"];
        
        NSXMLElement *item = [NSXMLElement elementWithName:@"subscribe"];
        [item addAttributeWithName:@"jid" stringValue:memberJid];
        [item addAttributeWithName:@"nick" stringValue:memberNick];
        
        [itemlist addChild:item];
    }
    
    [iq addChild:itemlist];
    
    return iq;
    
}


+ (WTProtoIQ *)IQ_SetGroupBannedAllWithFromUser:(WTProtoUser *)fromUser
                                         RoomID:(WTProtoUser *)roomID
                                       nickName:(NSString *)nickName
                                          style:(NSString *)style
{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" to:roomID];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *itemlist = [NSXMLElement elementWithName:@"subscribelist"];
    [itemlist addAttributeWithName:@"reason" stringValue:@"muc_block_all"];
    [itemlist addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    //操作者的昵称
    [itemlist addAttributeWithName:@"ownernick" stringValue:nickName];
    //操作者的jid
    [itemlist addAttributeWithName:@"ownerjid" stringValue:fromUser.full];
    if ([style isEqualToString:@"0"]) {
        [itemlist addAttributeWithName:@"joinstyle" stringValue:style];
    }else{
        [itemlist addAttributeWithName:@"joinstyle" stringValue:style];
    }
    
    [iq addChild:itemlist];
    
    return iq;
}


+ (WTProtoIQ *)IQ_GetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID
{
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:roomID];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *itemlist = [NSXMLElement elementWithName:@"subscribelist"];
    [itemlist addAttributeWithName:@"reason" stringValue:@"muc_block"];
    [itemlist addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    
    [iq addChild:itemlist];

    return iq;
}


+ (WTProtoIQ *)IQ_GetGroupActivityMemberWithFromUser:(WTProtoUser *)fromUser
                                              RoomID:(WTProtoUser *)roomID
                                        activityTime:(NSString *)activityTime
{
    
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"get" to:roomID];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *itemlist = [NSXMLElement elementWithName:@"subscribelist"];
    [itemlist addAttributeWithName:@"reason" stringValue:@"acitvelist"];
    [itemlist addAttributeWithName:@"joinstyle" stringValue:activityTime];
    [itemlist addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    
    [iq addChild:itemlist];
    
    return iq;
}


+ (WTProtoIQ *)IQ_SetGroupMemberRemarkNameWithFromUser:(WTProtoUser *)fromUser
                                                RoomID:(WTProtoUser *)roomID
                                              memberID:(WTProtoUser *)memberID
                                              noteName:(NSString *)name
{
    WTProtoIQ *iq = [WTProtoIQ iqWithType:@"set" to:roomID];
    [iq addAttributeWithName:@"from" stringValue:fromUser.full];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *subscribelist = [NSXMLElement elementWithName:@"subscribelist"];
    [subscribelist addAttributeWithName:@"reason" stringValue:@"notename"];
    [subscribelist addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:mucsub:0"];
    
    NSXMLElement *subscribe = [NSXMLElement elementWithName:@"subscribe"];
    [subscribe addAttributeWithName:@"jid" stringValue:memberID.full];
    [subscribe addAttributeWithName:@"nick" stringValue:name];
    
    [subscribelist addChild:subscribe];
    [iq addChild:subscribelist];
    
    return iq;
    
}


#pragma mark -- 群相关IQ返回结果解析

+ (void)parse_IQ_GetRoomInfo:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);

        parseResult(NO, [errorElement stringValue]);
    }
    else{
        
        NSXMLElement * queryElement  = [iq elementForName:@"query"];
        NSXMLElement * xElement      = [queryElement elementForName:@"x"];
        
        NSArray * contactItemList       = [queryElement elementsForName:@"item"];//群主、群管理的信息装载的item
        NSMutableArray * groupAdminArr  = [[NSMutableArray alloc] init];
        
        for (NSXMLElement *element in contactItemList) {
            
            //ID nick昵称 affiliation身份
            NSString * jid          = [element attributeStringValueForName:@"jid"];//jid
            NSString * nick         = [element attributeStringValueForName:@"nick"];//昵称
            NSString * affiliation  = [element attributeStringValueForName:@"affiliation"];
            
            [groupAdminArr addObject:@{@"affiliation":affiliation, @"nick":nick, @"jid":jid}];
        }
        
        //群成员数量
        NSString * groupMemberCount  = [queryElement attributeStringValueForName:@"usernum"];
        //是否此群的成员，none不是此群的成员
        NSString * affiliationStr    = [queryElement attributeStringValueForName:@"affiliation"];
        
        NSMutableDictionary * roomInfoDictionary = [[NSMutableDictionary alloc] init];
        [roomInfoDictionary setObject:groupMemberCount forKey:@"memberCount"];
        [roomInfoDictionary setObject:affiliationStr ?: @"" forKey:@"affiliation"];
        [roomInfoDictionary setObject:groupAdminArr forKey:@"groupAdmins"];
        
        for (NSXMLElement *element in xElement.children) {
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_roomname"]) {
                NSLog(@"room name = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"name"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_roomdesc"]) {
                NSLog(@"room desc = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"desc"];
            }
           
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_qrcode"]) {
                NSLog(@"room qrcode = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"qrcode"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_regtime"]) {
                NSLog(@"room regtime = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"regtime"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_destory_flag"]) {
                NSLog(@"room destory_flag = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"destoryFlag"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_invite_confirm"]) {
                NSLog(@"room invite_confirm = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"inviteConfirmStatus"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_room_image"]) {
                NSLog(@"room image = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"imageURL"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_block_all"]) {
                NSLog(@"Room block_all = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"bannedBlockAllStatus"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_screenshotsnotify"]) {
                NSLog(@"Room screenshotsnotify = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"screenshotsNotifyStatus"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_no_private_chat"]) {
                NSLog(@"Room no_private_chat = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"privateChatStatus"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"muc#roomconfig_no_private_chat"]) {
                NSLog(@"Room no_private_chat = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"privateChatStatus"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"users_version"]) {
                NSLog(@"Room users_version = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"usersVersion"];
            }
            
            if ([[element attributeStringValueForName:@"var"] isEqualToString:@"config_version"]) {
                NSLog(@"Room config_version = %@", [element stringValue]);
                [roomInfoDictionary setObject:[element stringValue] forKey:@"configVersion"];
            }
        }
        
        parseResult(YES, roomInfoDictionary);
    }
}


+ (void)parse_IQ_InviteUserSubscribes:(XMPPIQ *)iq
                          parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
       if (errorElement != nil) {
           NSLog(@"elementForName = %@",[errorElement stringValue]);
           if (parseResult) {
               parseResult(NO,  [[errorElement attributeForName:@"code"] stringValue]);
           }
       }
       else{
           if (parseResult) {
               parseResult(YES, @"订阅成功");
           }
       }
}

+ (void)parse_IQ_GetGroupList:(XMPPIQ *)iq
                  parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO, @"获取我的群列表失败");
        }
    }
    else{
        
        NSXMLElement *itemlistElement = [iq elementForName:@"itemlist"];
        NSMutableArray * roomArr  = [[NSMutableArray alloc] init];
        for (NSXMLElement * itemElement in itemlistElement.children) {
            NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc] init];
            for (NSXMLElement * childElement in itemElement.children) {
                [itemDictionary setObject:[childElement stringValue] forKey:[childElement name]];
            }
            [roomArr addObject:itemDictionary];
        }
        if (parseResult) {
            parseResult(YES, roomArr);
        }
    }
}


+ (void)parse_IQ_GetGroupMembersList:(XMPPIQ * )iq parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO, [errorElement stringValue]);//@"获取成员列表失败"
        }
    }
    else
    {
        
        NSXMLElement *itemlistElement   = [iq elementForName:@"subscribelist"];
        NSString *ownerJid              = [[itemlistElement attributeForName:@"ownerjid"] stringValue];
        NSString *ownerNick             = [[itemlistElement attributeForName:@"ownernick"] stringValue];

        NSMutableArray * membersArr  = [[NSMutableArray alloc] init];
        for (NSXMLElement * subElement in itemlistElement.children) {
            NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc] init];
            NSArray * eventElements = [subElement elementsForName:@"event"];
            for (int i = 0; i<eventElements.count; i++) {
                NSXMLElement * eventElement = eventElements[i];
                if (i == 0) {
                    //头像
                    if (eventElement) {
                        [itemDictionary setObject:[eventElement attributeStringValueForName:@"node"] forKey:@"iconurl"];
                    }else{
                        [itemDictionary setObject:@"" forKey:@"iconurl"];
                    }
                }else if(i == 1){
                    //群成员的备注
                    if (eventElement) {
                        [itemDictionary setObject:[eventElement attributeStringValueForName:@"node"] forKey:@"memoName"];
                    }else{
                        [itemDictionary setObject:@"" forKey:@"memoName"];
                    }
                }else if(i == 2){
                    //wid
                    if (eventElement) {
                        [itemDictionary setObject:[eventElement attributeStringValueForName:@"node"] forKey:@"wid"];
                    }else{
                        [itemDictionary setObject:@"" forKey:@"wid"];
                    }
                }else if(i == 3){
                    //地区
                    if (eventElement) {
                        [itemDictionary setObject:[eventElement attributeStringValueForName:@"node"] forKey:@"area"];
                    }else{
                        [itemDictionary setObject:@"" forKey:@"area"];
                    }
                }
            }
            
            [itemDictionary setObject:[subElement attributeStringValueForName:@"jid"]       forKey:@"jid"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"identity"]  forKey:@"identity"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"ispush"]    forKey:@"ispush"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"save"]      forKey:@"save"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"time"]      forKey:@"time"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"nick"]      forKey:@"nickname"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"changeflag"] ?: @"0" forKey:@"changeflag"];
            [itemDictionary setObject:[NSString pyFirstLetter:[subElement attributeStringValueForName:@"nick"]] forKey:@"nameIndex"];
            
            [membersArr addObject:itemDictionary];
            
        }
        
        NSMutableDictionary * datadict = [NSMutableDictionary new];
        [datadict setObject:ownerJid   forKey:@"owner_jid"];
        [datadict setObject:ownerNick  forKey:@"owner_nick"];
        [datadict setObject:membersArr forKey:@"allMembers"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"upDateGroupQuiteMembers" object:membersArr];
        
        
        if (parseResult) {
            
            parseResult(YES, datadict);
        }
    }
}


+ (void)parse_IQ_ExitUserSubscribes:(XMPPIQ *)iq
                        parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO, @"退出群失败");
        }
    }
    else{
        if (parseResult) {
            parseResult(YES, @"退出群成功");
        }
    }
}


+ (void)parse_IQ_RemoveMemberUnscribesChatRoom:(XMPPIQ *)iq
                                   parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[[errorElement elementForName:@"text"] stringValue]);
        if (parseResult) {
            parseResult(NO, [NSString stringWithFormat:@"移除成员失败, 原因:%@",[[errorElement elementForName:@"text"] stringValue]]);
        }
    }
    else{
        if (parseResult) {
            parseResult(YES, @"移除成员成功");
        }
    }
}


+ (void)parse_IQ_SaveGroupToContactList:(XMPPIQ *)iq
                            parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO,  [NSString stringWithFormat:@"群保存到通讯录设置失败：%@",[errorElement stringValue]]);
        }
    }
    else{
        if (parseResult) {
            parseResult(YES, @"群保存到通讯录设置成功");
        }
    }
}


+ (void)parse_IQ_UnDisturb:(XMPPIQ *)iq
               parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
       if (errorElement != nil) {
           NSLog(@"elementForName = %@",[errorElement stringValue]);
           if (parseResult) {
               parseResult(NO,  [NSString stringWithFormat:@"群消息免打扰设置失败：%@",[errorElement stringValue]]);
           }
       }
       else{
           if (parseResult) {
               parseResult(YES, @"群消息免打扰设置成功");
           }
       }
}


+ (void)parse_IQ_ModifyRoomNickName:(XMPPIQ *)iq
                        parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            if ([[errorElement stringValue] isEqualToString:@"That nickname is already in use by another occupant"]) {
                parseResult(NO, @"与其Ta成员昵称冲突");
            }
            else{
                parseResult(NO, [NSString stringWithFormat:@"%@",[errorElement stringValue]]);
            }
            
        }
    }
    else{
        if (parseResult) {
            parseResult(YES, @"修改我在群的昵称成功");
        }
    }
}


+ (void)parse_IQ_ExChangeGroupOwnerAuthority:(XMPPIQ *)iq
                                 parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
       if (errorElement != nil) {
           NSLog(@"elementForName = %@",[errorElement stringValue]);
           if (parseResult) {
               parseResult(NO,  [NSString stringWithFormat:@"转让失败：%@",[errorElement stringValue]]);
           }
       }
       else{
           if (parseResult) {
               parseResult(YES, @"转让成功");
           }
       }
}


+ (void)parse_IQ_SetGroupAdmin:(XMPPIQ *)iq
                   parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
      if (errorElement != nil) {
          NSLog(@"elementForName = %@",[errorElement stringValue]);
          if (parseResult) {
              parseResult(NO,  [NSString stringWithFormat:@"管理员设置失败：%@",[errorElement stringValue]]);
          }
      }
      else{
          if (parseResult) {
              parseResult(YES, @"管理员设置成功");
          }
      }
}


+ (void)parse_IQ_GetGroupQuiteMemberList:(XMPPIQ *)iq
                             parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
        if (errorElement != nil) {
            NSLog(@"elementForName = %@",[errorElement stringValue]);
            if (parseResult) {
                parseResult(NO,  [NSString stringWithFormat:@"获取退群成员列表失败：%@",[errorElement stringValue]]);
            }
        }
        else{
            NSMutableArray * membersArr  = [[NSMutableArray alloc] init];
            
            NSXMLElement *itemlistElement = [iq elementForName:@"subscribelist"];
            for (NSXMLElement * subElement in itemlistElement.children) {
                NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc] init];
                NSXMLElement * eventElement = [subElement elementForName:@"event"];
                if (eventElement) {
                    [itemDictionary setObject:[eventElement attributeStringValueForName:@"node"] forKey:@"iconurl"];
                }else{
                    [itemDictionary setObject:@"" forKey:@"iconurl"];
                }
                [itemDictionary setObject:[subElement attributeStringValueForName:@"jid"] forKey:@"jid"];
                [itemDictionary setObject:[subElement attributeStringValueForName:@"time"] forKey:@"time"];
                [itemDictionary setObject:[subElement attributeStringValueForName:@"nick"] forKey:@"nickname"];
                [membersArr addObject:itemDictionary];
            }
            if (parseResult) {
                parseResult(YES, membersArr);
            }
        }
}


+ (void)parse_IQ_SetGroupBannedMemberList:(XMPPIQ *)iq
                              parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO,  [NSString stringWithFormat:@"设置群禁言失败：%@",[errorElement stringValue]]);
        }
    }
    else{
        if (parseResult) {
            parseResult(YES, @"设置群禁言成功");
        }
    }
}


+ (void)parse_IQ_SetGroupBannedAll:(XMPPIQ *)iq
                       parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO,  [NSString stringWithFormat:@"设置群全员禁言失败：%@",[errorElement stringValue]]);
        }
    }
    else{
        if (parseResult) {
            parseResult(YES, @"设置群全员禁言成功");
        }
    }
}


+ (void)parse_IQ_GetGroupBannedMemberList:(XMPPIQ *)iq
                              parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
        if (errorElement != nil) {
            NSLog(@"elementForName = %@",[errorElement stringValue]);
            if (parseResult) {
                parseResult(NO,  [NSString stringWithFormat:@"获取群禁言名单失败：%@",[errorElement stringValue]]);
            }
        }
        else{
            NSMutableArray * membersArr  = [[NSMutableArray alloc] init];
            
            NSXMLElement *itemlistElement = [iq elementForName:@"subscribelist"];
            for (NSXMLElement * subElement in itemlistElement.children) {
                NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc] init];
                NSXMLElement * eventElement = [subElement elementForName:@"event"];
                if (eventElement) {
                    [itemDictionary setObject:[eventElement attributeStringValueForName:@"node"] forKey:@"iconurl"];
                }else{
                    [itemDictionary setObject:@"" forKey:@"iconurl"];
                }
                
                [itemDictionary setObject:[subElement attributeStringValueForName:@"jid"] forKey:@"jid"];
                [membersArr addObject:itemDictionary];
            }
            if (parseResult) {
                parseResult(YES, membersArr);
            }
        }
}


+ (void)parse_IQ_GetGroupActivityMember:(XMPPIQ *)iq
                            parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO,  [NSString stringWithFormat:@"获取活跃度群成员失败：%@",[errorElement stringValue]]);
        }
    }
    else{
        NSMutableArray * membersArr  = [[NSMutableArray alloc] init];
        
        NSXMLElement *itemlistElement = [iq elementForName:@"subscribelist"];
        for (NSXMLElement * subElement in itemlistElement.children) {
            NSMutableDictionary * itemDictionary = [[NSMutableDictionary alloc] init];
            NSXMLElement * eventElement = [subElement elementForName:@"event"];
            if (eventElement) {
                [itemDictionary setObject:[eventElement attributeStringValueForName:@"node"] forKey:@"iconurl"];
            }else{
                [itemDictionary setObject:@"" forKey:@"iconurl"];
            }
            [itemDictionary setObject:[subElement attributeStringValueForName:@"jid"] forKey:@"jid"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"identity"] forKey:@"identity"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"ispush"] forKey:@"ispush"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"save"] forKey:@"save"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"time"] forKey:@"time"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"nick"] forKey:@"nickname"];
            [itemDictionary setObject:[subElement attributeStringValueForName:@"changeflag"] ?: @"0" forKey:@"changeflag"];
            [itemDictionary setObject:[NSString pyFirstLetter:[subElement attributeStringValueForName:@"nick"]] forKey:@"nameIndex"];
            
            [membersArr addObject:itemDictionary];
        }
        
        if (parseResult) {
            parseResult(YES, membersArr);
        }
    }
}


+ (void)parse_IQ_SetGroupMemberRemarkName:(XMPPIQ *)iq
                              parseResult:(void (^)(BOOL succeed, id Info))parseResult
{
    NSXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement != nil) {
        NSLog(@"elementForName = %@",[errorElement stringValue]);
        if (parseResult) {
            parseResult(NO,  [NSString stringWithFormat:@"设置陌生人备注失败：%@",[errorElement stringValue]]);
        }
    }
    else{
        if (parseResult) {
            parseResult(YES, @"设置陌生人备注成功");
        }
    }
}


@end
