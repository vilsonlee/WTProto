//
//  WTProtoPing.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoPing.h"
#import "WTProtoQueue.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoAutoPing.h"
#import "WTProtoManualPing.h"、

static WTProtoPing *protoPing = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *pingQueue = nil;
static dispatch_once_t queueOnceToken;


@interface WTProtoPing()<XMPPAutoPingDelegate,XMPPPingDelegate>
{
    WTProtoQueue*  protoPingQueue;
    GCDMulticastDelegate <WTProtoPingDelegate> *protoPingMulticasDelegate;
}
@end


@implementation WTProtoPing

+ (WTProtoQueue *)pingQueue
{
    dispatch_once(&queueOnceToken, ^
    {
        pingQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:ping"];
    });
    return pingQueue;
}


+ (void)dellocSelf
{
    protoPing = nil;
    onceToken = 0l;
    
    pingQueue = nil;
    queueOnceToken = 0l;
}


+ (WTProtoPing *)sharePingWithProtoStream:(WTProtoStream *)protoStream
                                interface:(NSString *)interface
{
    dispatch_once(&onceToken, ^{
        
        protoPing = [[WTProtoPing alloc]initWithPingWithProtoStream:protoStream interface:interface];
        
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return protoPing;
}


- (instancetype)initWithPingWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface{
    
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"address should not be nil");
    #endif

    if (self = [super init])
    {
        _pingStream = protoStream;
        
        protoPingQueue  = [WTProtoPing pingQueue];
        
        _protoAutoPing  = [[WTProtoAutoPing alloc] initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        _protoAutoPing.pingInterval         = 25;
        _protoAutoPing.respondsToQueries    = YES;
        [_protoAutoPing activate:_pingStream];
        [_protoAutoPing addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        
        _protoManualPing  = [[WTProtoManualPing alloc] initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        [_protoManualPing activate:_pingStream];
        [_protoManualPing addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        protoPingMulticasDelegate = (GCDMulticastDelegate <WTProtoPingDelegate> *)[[GCDMulticastDelegate alloc] init];
    }

    return self;
}


- (void)addProtoPingDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoPingQueue dispatchOnQueue:^{

        [self->protoPingMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}

- (void)removeProtoPingDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoPingQueue dispatchOnQueue:^{

        [self->protoPingMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:YES];
    
}

- (void)removeProtoPingDelegate:(id)delegate
{
    [protoPingQueue dispatchOnQueue:^{

        [self->protoPingMulticasDelegate removeDelegate:delegate];

    } synchronous:YES];
    
}



- (void)setPingInterval:(NSTimeInterval)pingInterval
{
    _protoAutoPing.pingInterval = _pingInterval = pingInterval;
}


- (void)setPingTimeout:(NSTimeInterval)pingTimeout
{
    
    _protoAutoPing.pingTimeout = _pingTimeout = pingTimeout;
}

-(void)setTargetUser:(WTProtoUser *)targetUser
{
   _protoAutoPing.targetJID = _targetUser = targetUser;
}


-(void)setRespondsToQueries:(BOOL)respondsToQueries
{
    _protoAutoPing.respondsToQueries =
    _protoManualPing.respondsToQueries =
    _respondsToQueries = respondsToQueries;

}


- (NSString *)sendPingToServer
{
    return [_protoManualPing sendPingToServer];
}


- (NSString *)sendPingToServerWithTimeout:(NSTimeInterval)timeout
{
    return [_protoManualPing sendPingToServerWithTimeout:timeout];
}


- (NSString *)sendPingToJID:(WTProtoUser *)ProtoUser
{
    return [_protoManualPing sendPingToJID:ProtoUser];
}


- (NSString *)sendPingToJID:(WTProtoUser *)ProtoUser withTimeout:(NSTimeInterval)timeout
{
    return [_protoManualPing sendPingToJID:ProtoUser withTimeout:timeout];
}


- (void)xmppPing:(XMPPPing *)sender didReceivePong:(XMPPIQ *)pong withRTT:(NSTimeInterval)rtt
{
    
}
- (void)xmppPing:(XMPPPing *)sender didNotReceivePong:(NSString *)pingID dueToTimeout:(NSTimeInterval)timeout
{
    
}

- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender{
    
}
- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender{
    
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender{
    
}

@end
