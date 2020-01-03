//
//  WTProtoOnlinePresent.h
//  WTProtocalKit
//
//  Created by Mark on 2019/12/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, WTProtoPresentOnlineStatus) {
    WTProtoPresentOnlineStatusAway                = 0,      //away   -- 实体或资源临时离开.
    WTProtoPresentOnlineStatusChat,                         //chat   -- 实体或资源在聊天中是激活的.
    WTProtoPresentOnlineStatusDoNotDisturb,                 //dnd    -- 实体或资源是忙(dnd = "不要打扰").
    WTProtoPresentOnlineStatusExtendedAway                  //xa     -- 实体或资源是长时间的离开(xa = "长时间离开").
};


typedef NS_ENUM(NSUInteger, WTProtoPresentOnlinePriority) {
    WTProtoPresentOnlinePriorityLow                = 0,      //Low      -- 低
    WTProtoPresentOnlinePriorityMedium,                      //Medium   -- 中
    WTProtoPresentOnlinePriorityHigh,                        //igh      -- 高
};



@class WTProtoPresence;


NS_ASSUME_NONNULL_BEGIN

@interface WTProtoOnlinePresent : NSObject

+ (WTProtoPresence *)presenceOnlineState:(WTProtoPresentOnlineStatus)onlineStatus
                                  status:(NSString *)status
                                priority:(WTProtoPresentOnlinePriority)priority
                                  device:(NSString *)device;
;

@end

NS_ASSUME_NONNULL_END
