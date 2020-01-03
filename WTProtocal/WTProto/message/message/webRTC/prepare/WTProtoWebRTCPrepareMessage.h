//
//  WTProtoWebRTCPrepareMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCMessage.h"

typedef NS_ENUM(NSUInteger, WTProtoWebRTCPrepareType)
{
    WTProtoWebRTCPrepare_INVITATION,
    WTProtoWebRTCPrepare_ACCEPTANCE,
    WTProtoWebRTCPrepare_BUSY
};

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoWebRTCPrepareMessage : WTProtoWebRTCMessage


@property(nonatomic,copy)NSString *fromName;

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
                   prepareType:(WTProtoWebRTCPrepareType)prepareType
                      fromName:(NSString *)fromName;


-(void)setFromName:(NSString * _Nonnull)fromName;


@end

NS_ASSUME_NONNULL_END
