//
//  WTProtoChatErrorMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoConversationMessage.h"

@class WTProtoConversationErrorMessage;

typedef NS_ENUM(NSUInteger, WTProtoConversationErrorType)
{
//    WTProtoMessageErrorUNKNOW,
//    WTProtoMessageErrorUPDATE
    
    WTProtoConversationError_UNKNOW,
    WTProtoConversationError_UPDATE
};

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoConversationErrorMessage : WTProtoConversationMessage

@property(nonatomic,assign)WTProtoConversationErrorType errorType;

@property(nonatomic,copy)NSString *msgContent;


- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     errorType:(WTProtoConversationErrorType)errorType;


- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
                    msgContent:(NSString *)msgContent
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     errorType:(WTProtoConversationErrorType)errorType
;


- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
                                 errorType:(WTProtoConversationErrorType)errorType;

-(void)setErrorType:(WTProtoConversationErrorType)errorType;

@end

NS_ASSUME_NONNULL_END
