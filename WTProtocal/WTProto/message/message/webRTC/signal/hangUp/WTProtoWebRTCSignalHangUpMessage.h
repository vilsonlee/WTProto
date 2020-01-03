//
//  WTProtoWebRTCSignalHangUpMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoWebRTCSignalHangUpMessage : WTProtoWebRTCSignalMessage


- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID;




@end

NS_ASSUME_NONNULL_END
