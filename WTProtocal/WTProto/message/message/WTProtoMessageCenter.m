//
//  WTProtoMessageCenter.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/26.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMessageCenter.h"
#import "WTProtoStream.h"
#import "WTProtoQueue.h"
#import "WTProtoTimer.h"

@interface WTProtoMessageCenter () <WTProtoStreamDelegate>


{
    WTProtoQueue*  protoMessageCenterQueue_Concurrent;
    WTProtoQueue*  protoMessageCenterQueue_Serial;
    
    GCDMulticastDelegate <WTProtoMessageCenterDelegate> *protoMessageCenterMulticasDelegate;
}

@end


@implementation WTProtoMessageCenter


+ (WTProtoQueue *)messageCenterQueue_Serial{
    
    static WTProtoQueue *messageCenterQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        messageCenterQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:messageCenter_Serial"];
    });
    return messageCenterQueue;
    
}


+ (WTProtoQueue *)messageCenterQueue_Concurrent{
    
    static WTProtoQueue *messageCenterQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        messageCenterQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:messageCenter_Concurrent"
                                                     concurrent:YES];
    });
    return messageCenterQueue;
    
}



+ (WTProtoMessageCenter *)shareMessagerCenterWithProtoStream:(WTProtoStream *)protoStream
                                                   interface:(NSString *)interface
{
    static WTProtoMessageCenter *protoMessageCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        protoMessageCenter = [[WTProtoMessageCenter alloc]initMessageMessagerCenterWithProtoStream:protoStream
                                                                                         interface:interface];
        
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return protoMessageCenter;

    
}



- (instancetype)initMessageMessagerCenterWithProtoStream:(WTProtoStream *)protoStream
                                                   interface:(NSString *)interface
{
    
    #ifdef DEBUG
           NSAssert(protoStream != nil, @"address should not be nil");
       #endif

       if (self = [super init])
       {
           _messageCenterStream = protoStream;
           
           _messageCenterUser   = protoStream.streamUser;
                   
           protoMessageCenterQueue_Concurrent = [WTProtoMessageCenter messageCenterQueue_Concurrent];
           
           protoMessageCenterQueue_Serial = [WTProtoMessageCenter messageCenterQueue_Serial];
           
           protoMessageCenterMulticasDelegate = (GCDMulticastDelegate <WTProtoMessageCenterDelegate> *)[[GCDMulticastDelegate alloc] init];
           
           [_messageCenterStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
           
       }

       return self;
}

- (void)addProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    //异步+串行
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{

        [self->protoMessageCenterMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}


- (void)removeProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{

        [self->protoMessageCenterMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}


- (void)removeProtoMessageCenterDelegate:(id)delegate
{
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{

        [self->protoMessageCenterMulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
}



-(void)xmppStream:(XMPPStream *)sender didSendMessage:(nonnull XMPPMessage *)message{
    
}


-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(nonnull XMPPMessage *)message error:(nonnull NSError *)error{
    
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(nonnull XMPPMessage *)message{
    
    [protoMessageCenterQueue_Concurrent dispatchOnQueue:^{
        
        
        
        
        
        
        
    } synchronous:NO];
}




@end
