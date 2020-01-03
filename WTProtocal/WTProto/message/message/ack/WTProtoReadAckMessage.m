//
//  WTProtoReadAckMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2020/1/2.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoReadAckMessage.h"
#import "XMPPFramework/XMPPFramework.h"
#import "WTProtoStream.h"

@implementation WTProtoReadAckMessage

+ (WTProtoReadAckMessage *)readAckToID:(NSString *)toID
                           incrementID:(NSInteger )incrementID
                         WTProtoStream:(WTProtoStream *)stream
{
    WTProtoReadAckMessage * readAck_Message = [[WTProtoReadAckMessage alloc]
                                               initWithFromID:stream.myJID.full
                                                         toID:toID];
    NSString *msgID = [stream generateUUID];
    
    [readAck_Message addAttributeWithName:@"id" stringValue:msgID];
    
    NSString *readAck_MessageID         = [NSString stringWithFormat:@"%zd",incrementID];
    
    NSXMLElement *readReceACk_Element   = [NSXMLElement elementWithName:@"read_rece_ack"
                                                            stringValue:readAck_MessageID];
    [readAck_Message addChild:readReceACk_Element];
    
    return readAck_Message;
}

@end
