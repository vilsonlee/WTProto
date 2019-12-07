//
//  WTProtoRoom.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoRoom.h"

@implementation WTProtoRoom


- (void)joinRoomUsingNickname:(NSString *)desiredNickname history:(NSXMLElement *)history inviteUsers:(NSArray *)inviteUsers roomName:(NSString *)roomName{
    
    [self joinRoomUsingNickname:desiredNickname history:history password:nil inviteUsers:inviteUsers roomName:roomName];
}


- (void)joinRoomUsingNickname:(NSString *)desiredNickname history:(NSXMLElement *)history
                                                         password:(nullable NSString *)passwd
                                                      inviteUsers:(NSArray *)inviteUsers
                                                         roomName:(NSString *)roomName
{
    dispatch_block_t block = ^{ @autoreleasepool {
            
        NSLog(@"%@[%@] - %@", THIS_FILE, self->roomJID, THIS_METHOD);
        
        // Check state and update variables
        
        if (![self WTpreJoinWithNickname:desiredNickname])
        {
            return;
        }
                
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:XMPPMUCNamespace];
        
        if (history)
        {
            [x addChild:history];
        }
        if (passwd)
        {
            [x addChild:[NSXMLElement elementWithName:@"password" stringValue:passwd]];
        }
                    
        XMPPPresence *presence = [XMPPPresence presenceWithType:nil to:self->myRoomJID];
            
            [presence addChild:x];
            
            NSXMLElement *invitelistSub = [NSXMLElement elementWithName:@"subscribelist" xmlns:@"urn:xmpp:mucsub:0"];
            for (NSDictionary *modelDict in inviteUsers) {
                
                NSXMLElement *inviteSub = [NSXMLElement elementWithName:@"subscribe"];
                [inviteSub addAttributeWithName:@"nick"     stringValue:[modelDict objectForKey:@"nickname"]];
                [inviteSub addAttributeWithName:@"jid"      stringValue:[modelDict objectForKey:@"jid"]];
                [inviteSub addAttributeWithName:@"save"     stringValue:@""];
                [inviteSub addAttributeWithName:@"ispush"   stringValue:@""];
                [inviteSub addAttributeWithName:@"time"     stringValue:@""];
                [inviteSub addAttributeWithName:@"identity" stringValue:@""];
                [invitelistSub addChild:inviteSub];
            }

            //群名
            [invitelistSub addAttributeWithName:@"groupname" stringValue:roomName];
            //邀请者昵称
            [invitelistSub addAttributeWithName:@"ownernick" stringValue:desiredNickname];
            
            [presence addChild:invitelistSub];

            [self->xmppStream sendElement:presence];
            
            self->state |= 1 << 3;
            
        }};
        
        if (dispatch_get_specific(moduleQueueTag))
            block();
        else
            dispatch_async(moduleQueue, block);
    
}



- (BOOL)WTpreJoinWithNickname:(NSString *)nickname
{
    if ((state != 0) && (state != 1 << 5))
    {
        NSLog(@"%@[%@] - Cannot create/join room when already creating/joining/joined", THIS_FILE, roomJID);
        return NO;
    }
    
    myNickname = [nickname copy];
    myRoomJID = [XMPPJID jidWithUser:[roomJID user] domain:[roomJID domain] resource:myNickname];
    
    return YES;
}


/* 房间配置 */
- (void)configNewRoom
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_moderatedroom"];
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];//房间是否是持久
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];//仅对成员开放
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"200"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enablelogging"];//允许登录房间对话
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    

    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_getmemberlist"];// 允许获取成员列表
    [p addAttributeWithName:@"type" stringValue:@"list-multi"];
    [p addAttributeWithName:@"label" stringValue:@"Roles and Affiliations that May Retrieve Member List"];


    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"moderator"]];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"participant"]];
    [p addChild:[NSXMLElement elementWithName:@"value" xmlns:@"visitor"]];
    [x addChild:p];
    
    
    [self configureRoomUsingOptions:x];
}

///群邀请确认 flag: @"0",关闭 @"1" 开启
- (void)setGroupConfigInviteConfirmWithFlag:(NSString *)flag{
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_invite_confirm"];//开启邀请确认
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:flag]];
    [x addChild:p];
    
    [self configureRoomUsingOptions:x];
    
}


///群定时销毁开启状态 time>0 开启
- (void)setGroupConfigdestoryWithTime:(NSInteger)time
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
       
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_destory_flag"];//定时销毁时间
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:[NSString stringWithFormat:@"%ld",(long)time]]];
    [x addChild:p];
   
    [self configureRoomUsingOptions:x];
}


//群截屏通知 muc#roomconfig_screenshotsnotify flag: @"0"：关闭， @"1"：开启
- (void)setGroupConfigScreenshotsnotify:(NSString *)flag
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_screenshotsnotify"];//截屏通知
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:flag]];
    [x addChild:p];
    
    [self configureRoomUsingOptions:x];
}


//禁止私聊 muc#roomconfig_no_private_chat flag: @"0"：关闭， @"1"：开启
- (void)setGroupConfigPrivateChatFlag:(NSString *)flag
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
       
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_no_private_chat"];//禁止私聊
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:flag]];
    [x addChild:p];
   
    [self configureRoomUsingOptions:x];
}

///群名称修改
- (void)setGroupConfigGroupName:(NSString *)title
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_roomname"];//群名称
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:title]];
    [x addChild:p];
    
    [self configureRoomUsingOptions:x];
}


///群头像更新, updateTime: 更新的时间戳
- (void)setGroupConfigGroupIcon:(NSString *)updateTime
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_room_image"];//群名称
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:updateTime]];
    [x addChild:p];

    [self configureRoomUsingOptions:x];
}

///群公告修改
- (void)setGroupConfigGroupDescription:(NSString *)desc
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_roomdesc"];//群详细信息（公告）
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:desc]];
    [x addChild:p];
    
    [self configureRoomUsingOptions:x];
    
    
}

+ (WTProtoRoom *)initWithXMPPRoom:(XMPPRoom *)XMPPRoom
{
    
    WTProtoRoom* WTRoom = [[WTProtoRoom alloc]initWithRoomStorage:XMPPRoom.xmppRoomStorage jid:XMPPRoom.roomJID dispatchQueue:XMPPRoom.moduleQueue];
    
    return WTRoom;
}

@end
