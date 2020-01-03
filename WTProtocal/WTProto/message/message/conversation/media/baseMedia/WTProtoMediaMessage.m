//
//  WTProtoMediaMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaMessage.h"

@interface WTProtoMediaMessage()

@end

@implementation WTProtoMediaMessage


- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
                       msgType:(WTProtoConversationMessageType)msgType
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     mediaPath:(NSString *)mediaPath
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                             msgType:msgType
                     destructionTime:destructionTime
                              device:device])
    {
        self.mediaPath     = mediaPath;
        [self reSetBody];
    }
    
    return self;
}



- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.mediaPath     =  [PropertyDictionary valueForKey:@"mediaPath"];
        
        [self reSetBody];
    }
    
    return self;
}


-(void)setMediaPath:(NSString *)mediaPath
{
    _mediaPath = mediaPath;
    [self reSetBody];
    
}

@end
