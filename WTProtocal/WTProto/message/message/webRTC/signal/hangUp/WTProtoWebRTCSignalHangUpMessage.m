//
//  WTProtoWebRTCSignalHangUpMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalHangUpMessage.h"

@implementation WTProtoWebRTCSignalHangUpMessage

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
{

    
    return [super initWithFromID:fromID
                            toID:toID
                       sectionID:sectionID
                      signalType:WTProtoWebRTCSignal_HANDUP
                            data:@""];
}

@end
