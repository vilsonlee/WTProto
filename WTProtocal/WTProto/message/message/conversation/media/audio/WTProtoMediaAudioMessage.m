//
//  WTProtoMediaAudioMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaAudioMessage.h"

@interface WTProtoMediaAudioMessage()

@end

@implementation WTProtoMediaAudioMessage

- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     mediaPath:(NSString *)mediaPath
                      duration:(NSString *)duration
                meteringLevels:(NSArray *)meteringLevels
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                             msgType:WTProtoConversationMessage_AUDIO
                     destructionTime:destructionTime
                              device:device
                           mediaPath:mediaPath])
    {
        self.duration           = duration;
        self.meteringLevels     = meteringLevels;
        
        [self reSetBody];
    }
    
    return self;
}

- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        
        self.msgType = WTProtoConversationMessage_AUDIO;
        self.duration           =  [PropertyDictionary valueForKey:@"duration"];
        self.meteringLevels     =  [PropertyDictionary valueForKey:@"meteringLevels"];
        
        [self reSetBody];
    }
    
    return self;
}



-(void)setDuration:(NSString *)duration
{
    _duration = duration;
    [self reSetBody];
}
-(void)setMeteringLevels:(NSArray * _Nonnull)meteringLevels
{
    _meteringLevels = meteringLevels;
    [self reSetBody];
}




@end
