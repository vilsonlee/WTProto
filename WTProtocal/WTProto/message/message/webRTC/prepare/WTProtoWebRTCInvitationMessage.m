//
//  WTProtoWebRTCInvitationMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCInvitationMessage.h"

@implementation WTProtoWebRTCInvitationMessage

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
                      fromName:(NSString *)fromName
{
    return [super initWithFromID:fromID
                            toID:toID
                       sectionID:sectionID
                     prepareType:WTProtoWebRTCPrepare_INVITATION
                        fromName:fromName];
}


@end
