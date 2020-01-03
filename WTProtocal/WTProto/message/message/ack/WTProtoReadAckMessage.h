//
//  WTProtoReadAckMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2020/1/2.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoMessage.h"

@class XMPPMessage;
@class WTProtoStream;


NS_ASSUME_NONNULL_BEGIN

@interface WTProtoReadAckMessage : WTProtoMessage


+ (WTProtoReadAckMessage *)readAckToID:(NSString *)toID
                           incrementID:(NSInteger )incrementID
                         WTProtoStream:(WTProtoStream *)stream;



@end

NS_ASSUME_NONNULL_END
