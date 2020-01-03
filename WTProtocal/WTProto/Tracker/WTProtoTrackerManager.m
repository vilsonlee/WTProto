//
//  WTProtoTrackerManager.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoTrackerManager.h"
#import "WTProtoQueue.h"
#import "WTProtoIDTracker.h"
#import "WTProtoIQ.h"
#import "WTProtoConversationMessage.h"
#import "WTProtoShakeMessage.h"
#import "WTProtoshakedResultMessage.h"

static WTProtoTrackerManager *trackerManager = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *trackerManagerQueue = nil;
static dispatch_once_t queueOnceToken;


@interface WTProtoTrackerManager()
{
    
    WTProtoQueue*  protoTrackerQueue;
    
    GCDMulticastDelegate <WTProtoTrackerManagerDelegate> *protoTrackerMulticasDelegate;
    
    WTProtoIDTracker *tracker;
    
    
}

@end

@implementation WTProtoTrackerManager


+ (void)dellocSelf
{
    trackerManager = nil;
    onceToken = 0l;
    
    trackerManagerQueue = nil;
    queueOnceToken = 0l;
}


+ (WTProtoQueue *)trackerManagerQueue
{
    dispatch_once(&queueOnceToken, ^
    {
        trackerManagerQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:tracker"];
    });
    return trackerManagerQueue;
}


+ (WTProtoTrackerManager *)shareTrackerManager
{
    dispatch_once(&onceToken, ^{
        
        trackerManager = [[WTProtoTrackerManager alloc]initTrackerManager];
    });
    
    return trackerManager;
}


- (instancetype)initTrackerManager
{
    if (self = [super init])
    {
        tracker = [[WTProtoIDTracker alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        
        protoTrackerQueue = [WTProtoTrackerManager trackerManagerQueue];
        
        protoTrackerMulticasDelegate = (GCDMulticastDelegate <WTProtoTrackerManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return self;
}


- (void)addProtoTrackerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoTrackerQueue dispatchOnQueue:^{

        [self->protoTrackerMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}

- (void)removeProtoTrackerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoTrackerQueue dispatchOnQueue:^{

        [self->protoTrackerMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:YES];
}

- (void)removeProtoTrackerDelegate:(id)delegate
{
    [protoTrackerQueue dispatchOnQueue:^{

        [self->protoTrackerMulticasDelegate removeDelegate:delegate];

    } synchronous:YES];
}



- (void)addTimeOutTrack:(XMPPElement *)element timeout:(NSTimeInterval)timeout
{
    [tracker addElement:element target:self selector:@selector(sendTimeout:withInfo:) timeout:timeout];
}


- (void)invokeForMessage:(WTProtoMessage *)message
{
    [tracker invokeForID:[message elementID] withObject:message];
}

- (void)invokeForIQ:(WTProtoIQ *)iq
{
    [tracker invokeForID:[iq elementID] withObject:iq];
}


- (void)sendTimeout:(DDXMLElement *)element withInfo:(XMPPBasicTrackingInfo*)trackerInfo
{
    if (!element) {
        NSLog(@"发送超时");
        //消息发送超时
        if ([trackerInfo.element isKindOfClass:[XMPPMessage class]] ||
            [trackerInfo.element isKindOfClass:[WTProtoMessage class]] ||
            [trackerInfo.element isKindOfClass:[WTProtoShakeMessage class]] ||
            [trackerInfo.element isKindOfClass:[WTProtoshakedResultMessage class]] ||
            [trackerInfo.element isKindOfClass:[WTProtoConversationMessage class]]) {
            
            if ([element elementForName:@"shake"]) {
                [protoTrackerMulticasDelegate protoTrackerManager:self
                                         trackTimeOutShakeMessage:(WTProtoShakeMessage *)trackerInfo.element];
                return;
            }
            
            if ([element elementForName:@"shakedResult"]) {
                [protoTrackerMulticasDelegate protoTrackerManager:self
                                   trackTimeOutShakeResultMessage:(WTProtoshakedResultMessage *)trackerInfo.element];
                return;
            }
            
            if ([element elementForName:@"conversation"]) {
                [protoTrackerMulticasDelegate protoTrackerManager:self
                                  trackTimeOutConversationMessage:(WTProtoConversationMessage *)trackerInfo.element];
                return;
            }
        }
        
        //iq请求发送超时
        else if ([trackerInfo.element isKindOfClass:[XMPPIQ class]]||
                 [trackerInfo.element isKindOfClass:[WTProtoIQ class]]){
            [protoTrackerMulticasDelegate protoTrackerManager:self trackTimeOutIQ:(WTProtoIQ *)trackerInfo.element];
        }
    }
}

@end
