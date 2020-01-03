//
//  WTProtoMediaGIFMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaGIFMessage.h"

@interface WTProtoMediaGIFMessage()

@end

@implementation WTProtoMediaGIFMessage


- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     mediaPath:(NSString *)mediaPath
                         width:(float)width
                        height:(float)height
                   orientation:(int64_t)orientation
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                     destructionTime:destructionTime
                              device:device
                           mediaPath:mediaPath
                               width:width
                              height:height
                         orientation:orientation])
    {
        self.msgType = WTProtoConversationMessage_GIF;
        [self reSetBody];
    }
    
    return self;
}


- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.msgType = WTProtoConversationMessage_GIF;
        
        [self reSetBody];
    }
    
    return self;
}


@end
