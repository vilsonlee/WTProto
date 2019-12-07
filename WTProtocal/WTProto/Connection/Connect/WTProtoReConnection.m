//
//  WTProtoReConnection.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoReConnection.h"
#import "WTProtoServerAddress.h"
#import "WTProtoStream.h"
#import "WTProtoQueue.h"
#import "WTProtoReconnect.h"
#import "WTProtoTimer.h"

@interface WTProtoReConnection () <XMPPReconnectDelegate>
{
    
    WTProtoQueue       *protoReConnectionQueue;
    WTProtoReconnect   *protoReconnect;
    GCDMulticastDelegate <WTProtoReConnectionDelegate> *protoReConnectionMulticasDelegate;
}
@end

@implementation WTProtoReConnection

+ (WTProtoQueue *)reConnectQueue{
    
    static WTProtoQueue *reConnectqueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        reConnectqueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:reConnect"];
    });
    return reConnectqueue;
}


+ (WTProtoReConnection *)shareReConnecionWithProtoStream:(WTProtoStream *)protoStream
                                          ReconnectDelay:(NSTimeInterval )reconnectDelay
                                  ReconnectTimerInterval:(NSTimeInterval )reconnectTimerInterval
                                               interface:(NSString *)interface
{
    
    static WTProtoReConnection *protoReConnection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        protoReConnection = [[WTProtoReConnection alloc]initReConnecionWithProtoStream:protoStream
                                                                        ReconnectDelay:reconnectDelay
                                                                ReconnectTimerInterval:reconnectTimerInterval
                                                                             interface:interface];
        
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return protoReConnection;
    
}


- (instancetype)initReConnecionWithProtoStream:(WTProtoStream *)protoStream
                                ReconnectDelay:(NSTimeInterval )reconnectDelay
                        ReconnectTimerInterval:(NSTimeInterval )reconnectTimerInterval
                                     interface:(NSString *)interface
{
    
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"address should not be nil");
    #endif

    if (self = [super init])
    {
        _reConnectStream = protoStream;
    
        protoReconnect = [[WTProtoReconnect alloc]initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];

        protoReconnect.reconnectDelay           = reconnectDelay;
        protoReconnect.reconnectTimerInterval   = reconnectTimerInterval;
        
        [protoReconnect activate:_reConnectStream];
        
        [protoReconnect addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        protoReConnectionQueue = [WTProtoReConnection reConnectQueue];
             
        protoReConnectionMulticasDelegate = (GCDMulticastDelegate <WTProtoReConnectionDelegate> *)[[GCDMulticastDelegate alloc] init];
        
    }

    return self;
}

-(void)addProtoReConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoReConnectionQueue dispatchOnQueue:^{

        [self->protoReConnectionMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];

}


- (void)removeProtoReConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoReConnectionQueue dispatchOnQueue:^{

          [self->protoReConnectionMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

      } synchronous:YES];
}


- (void)removeProtoReConnectionDelegate:(id)delegate
{

    [protoReConnectionQueue dispatchOnQueue:^{

          [self->protoReConnectionMulticasDelegate removeDelegate:delegate];

      } synchronous:YES];
}



- (void)setAutoReconnect:(BOOL)autoReconnect
{
    protoReconnect.autoReconnect = _autoReconnect = autoReconnect;
}


-(void)setUsesOldSchoolSecureConnect:(BOOL)usesOldSchoolSecureConnect
{
    protoReconnect.usesOldSchoolSecureConnect = _usesOldSchoolSecureConnect = usesOldSchoolSecureConnect;
}

- (void)setReconnectDelay:(NSTimeInterval)reconnectDelay
{
    protoReconnect.reconnectDelay = _reconnectDelay = reconnectDelay;
}

- (void)setReconnectTimerInterval:(NSTimeInterval)reconnectTimerInterval
{
    protoReconnect.reconnectTimerInterval = _reconnectTimerInterval = reconnectTimerInterval;
}

- (void)Stop{
    
    [protoReconnect stop];
}


- (void)ManualStart{
    
    [protoReconnect manualStart];
}


- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{

    return YES;
}

@end
