//
//  WTProtoOnlinePresent.m
//  WTProtocalKit
//
//  Created by Mark on 2019/12/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoOnlinePresent.h"
#import "WTProtoPresence.h"

//away -- 实体或资源临时离开.
//
//chat -- 实体或资源在聊天中是激活的.
//
//dnd -- 实体或资源是忙(dnd = "不要打扰").
//
//xa -- 实体或资源是长时间的离开(xa = "长时间离开").

@implementation WTProtoOnlinePresent

+ (WTProtoPresence *)presenceOnlineState:(WTProtoPresentOnlineStatus)onlineStatus
                                  status:(NSString *)status
                                priority:(WTProtoPresentOnlinePriority)priority
                                  device:(NSString *)device
{
    
    WTProtoPresence *presence = [WTProtoPresence presence];
    
    //版本判断,是否通过IQ拉取离线消息
    [presence addChild:[DDXMLElement elementWithName:@"v2"]];
    
    NSString* OnlineState = @"away";
    
    switch (onlineStatus) {
        case WTProtoPresentOnlineStatusAway:
            OnlineState = @"away";
            break;
        case WTProtoPresentOnlineStatusChat:
            OnlineState = @"chat";
            break;
        case WTProtoPresentOnlineStatusDoNotDisturb:
            OnlineState = @"dnd";
            break;
        case WTProtoPresentOnlineStatusExtendedAway:
            OnlineState = @"xa";
            break;
        default:
            break;
    }
    
    NSString* OnlinePriority = @"0";
    switch (priority) {
       case WTProtoPresentOnlinePriorityLow:
           OnlinePriority = @"0";
           break;
       case WTProtoPresentOnlinePriorityMedium:
           OnlinePriority = @"1";
           break;
       case WTProtoPresentOnlinePriorityHigh:
           OnlinePriority = @"2";
           break;
           break;
       default:
           break;
       }
    
    
    [presence addChild:[DDXMLElement elementWithName:@"show"     stringValue:OnlineState]];
    [presence addChild:[DDXMLElement elementWithName:@"status"   stringValue:status]];
    [presence addChild:[DDXMLElement elementWithName:@"priority" stringValue:OnlinePriority]];
    [presence addChild:[DDXMLElement elementWithName:@"device"   stringValue:device]];
    
    return presence;
    
}

@end
