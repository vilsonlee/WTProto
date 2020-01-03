//
//  WTProtoTextMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoTextMessage.h"

@interface WTProtoTextMessage ()

@end

@implementation WTProtoTextMessage


-(instancetype)initWithFromID:(NSString *)fromID
                     fromName:(NSString *)fromName
                         toID:(NSString *)toID
                       toName:(NSString *)toName
                   createTime:(NSString *)createTime
                        msgID:(NSString *)msgID
                   msgContent:(nonnull NSString *)msgContent
                   remindJids:(nonnull NSString *)remindJids
              destructionTime:(int64_t)destructionTime
                       device:(int64_t)device
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                             msgType:WTProtoConversationMessage_TEXT
                     destructionTime:destructionTime
                              device:device])
    {
        self.msgContent     = msgContent;
        self.remindJids     = remindJids;
        
        [self reSetBody];
    }
    
    return self;
}

- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.msgContent     =  [PropertyDictionary valueForKey:@"msgContent"] ;
        self.remindJids     =  [PropertyDictionary valueForKey:@"remindJids"] ;
        
        [self reSetBody];
    }
    
    return self;
}


-(void)setMsgContent:(NSString *)msgContent
{
    _msgContent = msgContent;
    [self reSetBody];
}



-(void)setRemindJids:(NSString *)remindJids
{
    _remindJids = remindJids;
    [self reSetBody];
}

@end
