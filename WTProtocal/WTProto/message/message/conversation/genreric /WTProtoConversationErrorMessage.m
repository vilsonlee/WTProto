//
//  WTProtoChatErrorMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoConversationErrorMessage.h"

@implementation WTProtoConversationErrorMessage

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     errorType:(WTProtoConversationErrorType)errorType
{
    if (self = [super initWithFromID:fromID
                            fromName:@""
                                toID:toID
                              toName:@""
                          createTime:@""
                               msgID:@""
                             msgType:WTProtoConversationMessage_Error
                     destructionTime:0
                              device:WTProtoMessageDeviceType_UNKNOW])
    {
        [self setProperty:errorType];
    }
    
    return self;
    
}


-(instancetype)initWithFromID:(NSString *)fromID
                     fromName:(NSString *)fromName
                         toID:(NSString *)toID
                       toName:(NSString *)toName
                   createTime:(NSString *)createTime
                        msgID:(NSString *)msgID
                   msgContent:(NSString *)msgContent
              destructionTime:(int64_t)destructionTime
                       device:(int64_t)device
                    errorType:(WTProtoConversationErrorType)errorType
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                             msgType:WTProtoConversationMessage_Error
                     destructionTime:destructionTime
                              device:device])
    {
        [self setProperty:errorType];
    }
    
    return self;
}

- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
                                 errorType:(WTProtoConversationErrorType)errorType
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        [self setProperty:errorType];
    }
    
    return self;
}



-(void)setProperty:(WTProtoConversationErrorType)errorType
{
    self.msgContent     = [self getErrorMsgContent:errorType];
    self.errorType      = errorType;
    [self reSetBody];
}

-(void)setErrorType:(WTProtoConversationErrorType)errorType
{
    _errorType = errorType;
    [self reSetBody];
}

- (NSString *)getErrorMsgContent:(WTProtoConversationErrorType)errorType{
    
    NSString* errorMsgContent;
    
    switch (errorType) {
        case WTProtoConversationError_UNKNOW:
            errorMsgContent = @"Message of unknown type, maybe an error message";
            break;
        case WTProtoConversationError_UPDATE:
            errorMsgContent = @"This type of message is not supported in the current version. Please update";
        break;
            
        default:
            break;
    }
    
    return errorMsgContent;
}



@end
