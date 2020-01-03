//
//  WTProtoAckMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <KissXML/KissXML.h>

@class XMPPMessage;
@class WTProtoStream;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoAckMessage : DDXMLElement



+ (WTProtoAckMessage *)ackMessage:(XMPPMessage*)message WTProtoStream:(WTProtoStream *)stream;





@end

NS_ASSUME_NONNULL_END
