//
//  WTProtoAckManager.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoAckManager.h"
#import "XMPPFramework/XMPPFramework.h"
#import "WTProtoStream.h"
#import "WTProtoAckMessage.h"
#import "WTProtoReadAckMessage.h"

static WTProtoAckManager *ackManager = nil;
static dispatch_once_t onceToken;

@interface WTProtoAckManager()
{
    
    WTProtoStream* _ackManagerSteam;
}

@end

@implementation WTProtoAckManager



+ (WTProtoAckManager*)shareAckManagerWith:(WTProtoStream*)ackStream{
    
    dispatch_once(&onceToken, ^{
        
        ackManager = [[WTProtoAckManager alloc]initAckManagerWith:ackStream];
    });

    return ackManager;
}


+ (void)dellocSelf
{
    ackManager = nil;
    onceToken = 0l;
}



-(instancetype)initAckManagerWith:(WTProtoStream*)ackStream{
    
    if (self = [super init])
    {
        _ackManagerSteam = ackStream;
    }

    return self;
    
}


-(void)ack:(XMPPMessage *)message
{
    if ([message elementForName:@"delay" xmlns:@"urn:xmpp:delay"])
    {
        WTProtoAckMessage* ackMessage = [WTProtoAckMessage ackMessage:message
                                                            WTProtoStream:_ackManagerSteam];
        [_ackManagerSteam sendElement:ackMessage];
    }
}


-(void)readAckToID:(NSString *)toID incrementID:(NSInteger)incrementID
{
    WTProtoReadAckMessage *readAckMessage  = [WTProtoReadAckMessage readAckToID:toID
                                                                    incrementID:incrementID
                                                                  WTProtoStream:_ackManagerSteam];
    
    [_ackManagerSteam sendElement:readAckMessage];
    
}







@end
