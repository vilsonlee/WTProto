//
//  WTProtoWebRTCInvitationMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCPrepareMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoWebRTCInvitationMessage : WTProtoWebRTCPrepareMessage

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
                      fromName:(NSString *)fromName;



@end

NS_ASSUME_NONNULL_END
