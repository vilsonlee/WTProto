//
//  WTProtoMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>
#import "WTProtoMessage.h"

typedef NS_ENUM(NSUInteger, WTProtoConversationMessageType)
{
    WTProtoConversationMessage_TEXT,
    WTProtoConversationMessage_AUDIO,
    WTProtoConversationMessage_IMAGE,
    WTProtoConversationMessage_VIDEO,
    WTProtoConversationMessage_GIF,
    WTProtoConversationMessage_FILE,
    WTProtoConversationMessage_VCARD,
    WTProtoConversationMessage_URL                       = 9,
        
    WTProtoConversationMessage_Error                     = 404
};


typedef NS_ENUM(NSUInteger, WTProtoMessageDeviceType)
{
    WTProtoMessageDeviceType_IPHONE      = 101,
    WTProtoMessageDeviceType_IPHONE_WEB,
    WTProtoMessageDeviceType_ANDRIOD     = 201,
    WTProtoMessageDeviceType_ANDRIOD_WEB ,
    WTProtoMessageDeviceType_PC,
    WTProtoMessageDeviceType_UNKNOW
};




@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoConversationMessage : WTProtoMessage

@property(nonatomic,copy)NSString* fromName;
@property(nonatomic,copy)NSString* toName;
@property(nonatomic,copy)NSString* createTime;
@property(nonatomic,copy)NSString* msgID;
@property(nonatomic,assign)WTProtoConversationMessageType msgType;
@property(nonatomic,assign)int64_t destructionTime;
@property(nonatomic,assign)int64_t device;


- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
                       msgType:(WTProtoConversationMessageType)msgType
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device;

- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary;

-(void)setFromName:(NSString *)fromName;
-(void)setToName:(NSString *)toName;
-(void)setCreateTime:(NSString *)createTime;
-(void)setMsgID:(NSString *)msgID;
-(void)setMsgType:(WTProtoConversationMessageType)msgTyp;
-(void)setDestructionTime:(int64_t)destructionTime;
-(void)setDevice:(int64_t)device;

@end

NS_ASSUME_NONNULL_END
