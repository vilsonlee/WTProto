//
//  WTProtoWebRTCSignalMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCMessage.h"

typedef NS_ENUM(NSUInteger, WTProtoWebRTCSignalType)
{
    WTProtoWebRTCSignal_OFFER,
    WTProtoWebRTCSignal_RE_OFFER,
    WTProtoWebRTCSignal_ANSWER,
    WTProtoWebRTCSignal_RE_ANSWER,
    WTProtoWebRTCSignal_ICE_CANDIDATE,
    WTProtoWebRTCSignal_HANDUP,
    WTProtoWebRTCSignal_AUDIO_ACCEPT,
};



NS_ASSUME_NONNULL_BEGIN

@interface WTProtoWebRTCSignalMessage : WTProtoWebRTCMessage

@property(nonatomic,copy)NSString *data;

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
                    signalType:(WTProtoWebRTCSignalType)signalType
                          data:(NSString *)data;


-(void)setData:(NSString * _Nonnull)data;

@end

NS_ASSUME_NONNULL_END
