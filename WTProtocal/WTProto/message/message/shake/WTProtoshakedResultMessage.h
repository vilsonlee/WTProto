//
//  WTProtoshakedResultMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/27.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMessage.h"

typedef NS_ENUM(NSUInteger, WTProtoshakedResultMessageType)
{
    WTProtoConversationMessage_REFUESD,
    WTProtoshakedResultMessage_ACCEPT
};


NS_ASSUME_NONNULL_BEGIN

@interface WTProtoshakedResultMessage : WTProtoMessage

@property(nonatomic,copy)NSString* sendShakeUserID;
@property(nonatomic,copy)NSString* sendShakeUserName;
@property(nonatomic,copy)NSString* msgContent;
@property(nonatomic,copy)NSString* msgID;
@property(nonatomic,copy)NSString* groupName;
@property(nonatomic,copy)NSString* createTime;

@property(nonatomic,copy)NSString* sendFromShakeUserID;
@property(nonatomic,copy)NSString* sendFromShakeUserName;

@property(nonatomic,assign)WTProtoshakedResultMessageType resultType;

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                    createTime:(NSString *)createTime
               sendShakeUserID:(NSString *)sendShakeUserID
             sendShakeUserName:(NSString *)sendShakeUserName
           sendFromShakeUserID:(NSString *)sendFromShakeUserID
         sendFromShakeUserName:(NSString *)sendFromShakeUserName
                         msgID:(NSString *)msgID
                    resultType:(WTProtoshakedResultMessageType)resultType
                     groupName:(NSString *)groupName;

@end

NS_ASSUME_NONNULL_END
