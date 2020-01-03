//
//  WTProtoWebRTCSignalICEMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalICEMessage.h"

@implementation WTProtoWebRTCSignalICEMessage

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                       sectionID:(NSString *)sectionID                          data:(NSString *)data
{
    return [super initWithFromID:fromID
                            toID:toID
                       sectionID:sectionID
                      signalType:WTProtoWebRTCSignal_ICE_CANDIDATE
                            data:data];
}

@end
