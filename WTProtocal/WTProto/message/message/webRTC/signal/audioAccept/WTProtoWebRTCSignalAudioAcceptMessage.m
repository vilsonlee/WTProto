//
//  WTProtoWebRTCSignalAudioAcceptMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalAudioAcceptMessage.h"

@implementation WTProtoWebRTCSignalAudioAcceptMessage
- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
{
    return [super initWithFromID:fromID
                            toID:toID
                       sectionID:sectionID
                      signalType:WTProtoWebRTCSignal_AUDIO_ACCEPT
                            data:@""];
}
@end
