//
//  WTProtoConnection.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/1.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoConnection.h"
#import "WTProtoServerAddress.h"
#import "WTProtoStream.h"
#import "WTProtoQueue.h"
#import "WTProtoTimer.h"

static WTProtoConnection *protoConnection = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *tcpqueue = nil;
static dispatch_once_t queueOnceToken;

@interface WTProtoConnection () <WTProtoStreamDelegate>


{
    WTProtoQueue*  protoConnectionQueue;
    GCDMulticastDelegate <WTProtoConnectionDelegate> *protoConnectionMulticasDelegate;
}

@end

@implementation WTProtoConnection


+ (WTProtoQueue *)tcpQueue
{
    dispatch_once(&queueOnceToken, ^
    {
        tcpqueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:tcp"];
    });
    return tcpqueue;
}



+ (void)dellocSelf
{
    protoConnection = nil;
    onceToken = 0l;
    
    tcpqueue = nil;
    queueOnceToken  = 0l;
}


+ (WTProtoConnection *)shareConnecionWithProtoStream:(WTProtoStream *)protoStream
                                           interface:(NSString *)interface{

    dispatch_once(&onceToken, ^{
        
        protoConnection = [[WTProtoConnection alloc]initWithProtoStream:protoStream
                                                              interface:interface];
        
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return protoConnection;
    
}


- (instancetype)initWithProtoStream:(WTProtoStream *)protoStream
                         interface:(NSString *)interface
{
    
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"address should not be nil");
    #endif

    if (self = [super init])
    {
        _connectStream = protoStream;
        
        _connectUser   = protoStream.streamUser;
        
        _serverAddress = protoStream.serverAddress;
        
        protoConnectionQueue = [WTProtoConnection tcpQueue];
        
        protoConnectionMulticasDelegate = (GCDMulticastDelegate <WTProtoConnectionDelegate> *)[[GCDMulticastDelegate alloc] init];
        
        [protoStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
    }

    return self;
}


-(void)addProtoConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoConnectionQueue dispatchOnQueue:^{

        [self->protoConnectionMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];

}


- (void)removeProtoConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoConnectionQueue dispatchOnQueue:^{

          [self->protoConnectionMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

      } synchronous:YES];
}


- (void)removeProtoConnectionDelegate:(id)delegate
{

    [protoConnectionQueue dispatchOnQueue:^{

          [self->protoConnectionMulticasDelegate removeDelegate:delegate];

      } synchronous:YES];
}


-(BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError *__autoreleasing  _Nullable *)error{
    
    if (![_connectStream.serverAddress.host isEqualToString:_serverAddress.host]) {
        return NO;
    }
    
    BOOL result = NO;
        
    result = [_connectStream connectWithTimeout:timeout error:error];
    
    if (result && !error) {
        result = YES;
    }else{
        result = NO;
    }
    return result;
    
}


-(void)disconnect
{
    [self.connectStream disconnect];
}


-(void)resetConnectionStream:(WTProtoStream*)protoStream{
    
    _connectStream = protoStream;
    
    _connectUser   = protoStream.streamUser;
    
    _serverAddress = protoStream.serverAddress;
    
    protoConnectionMulticasDelegate = (GCDMulticastDelegate <WTProtoConnectionDelegate> *)[[GCDMulticastDelegate alloc] init];
    
    [protoStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
}


#pragma mark - xmppStream delegate - Connection

-(void)xmppStreamWillConnect:(XMPPStream *)sender{
    
    
    [protoConnectionMulticasDelegate WTProtoConnection:self
                                          connectState:WTProtoConnectStatusConnecting withError:nil];
    
    NSLog(@"<<< xmppStreamWillConnect >>>");
}


-(void)xmppStream:(XMPPStream *)sender socketDidConnect:(nonnull GCDAsyncSocket *)socket{
    
    NSLog(@"<<< socketDidConnect >>>");
}


-(void)xmppStreamDidStartNegotiation:(XMPPStream *)sender{
    
    NSLog(@"<<< xmppStreamDidStartNegotiation >>>");

}


-(void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary<NSString*,NSObject*>*)settings{
    
    NSLog(@"<<< willSecureWithSettings >>>");
    
    settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(nonnull SecTrustRef)trust completionHandler:(nonnull void (^)(BOOL))completionHandler{
    
    NSLog(@"<<< didReceiveTrust >>>");
    
    if (completionHandler)
        completionHandler(YES);
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender{
    
    NSLog(@"<<< xmppStreamDidSecure >>>");
}


-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    [protoConnectionMulticasDelegate WTProtoConnection:self
                                          connectState:WTProtoConnectStatusConnected
                                             withError:nil];

    NSLog(@"<<< xmppStreamDidConnect >>>");
}


-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    
    
    NSLog(@"<<< xmppStreamConnectDidTimeout >>>");
    [protoConnectionMulticasDelegate WTProtoConnection:self
                                          connectState:WTProtoConnectStatusConnectTimeout
                                             withError:nil];
}


-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    
    NSLog(@"<<< xmppStreamDidDisconnect >>>");
    [protoConnectionMulticasDelegate WTProtoConnection:self
                                          connectState:WTProtoConnectStatusDisconnected
                                             withError:error];
    
}


- (void)xmppStream:(XMPPStream *)sender didReceiveError:(nonnull DDXMLElement *)error{

    NSError* Error;
    
    if (error) {

        NSString *const ErrorDomain = @"GCDAsyncSocketErrorDomain";

        NSString* errorMessage = [[error elementForName:@"text" xmlns:@"urn:ietf:params:xml:ns:xmpp-streams"] stringValue];

        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];

        Error = [[NSError alloc]initWithDomain:ErrorDomain code:3 userInfo:userInfo];
    }

    [protoConnectionMulticasDelegate WTProtoConnection:self
                                          connectState:WTProtoConnectStatusDisconnected
                                             withError:Error];
    
}



@end
