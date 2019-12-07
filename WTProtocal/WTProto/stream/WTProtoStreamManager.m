//
//  WTProtoStreamManager.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoStreamManager.h"
#import "WTProtoQueue.h"
#import "WTProtoStream.h"
#import "WTProtoStreamManagement.h"
#import "WTProtoStreamManagementMemoryStorage.h"


@interface WTProtoStreamManager()
{
    WTProtoQueue*  protoStreamManagerQueue;
    GCDMulticastDelegate <WTProtoStreamManagerDelegate> *protoStreamManagerMulticasDelegate;
}
@end

@implementation WTProtoStreamManager


+ (WTProtoQueue *)streamManagerQueue{
    
    static WTProtoQueue *streamManagerQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        streamManagerQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:streamQueue"];
    });
    return streamManagerQueue;
    
}

+ (WTProtoStreamManager *)shareStreamManagerWithProtoStream:(WTProtoStream *)protoStream
                                                  interface:(NSString *)interface
{
    static WTProtoStreamManager *protoStreamManager = nil;
       static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           
           protoStreamManager = [[WTProtoStreamManager alloc]initStreamManagerWithProtoStream:protoStream
                                                                                    interface:interface];
           
           [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
       });
    
    return protoStreamManager;
}


- (instancetype)initStreamManagerWithProtoStream:(WTProtoStream *)protoStream
                                       interface:(NSString *)interface
{
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"address should not be nil");
    #endif

    if (self = [super init])
    {
        _ManagerStream = protoStream;
        
        protoStreamManagerQueue = [WTProtoStreamManager streamManagerQueue];
        
        protoStreamManagerMulticasDelegate = (GCDMulticastDelegate <WTProtoStreamManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    
        _ProtoStreamManagementMemoryStorage = [[WTProtoStreamManagementMemoryStorage alloc]init];
        
        _ProtoStreamManagement = [[WTProtoStreamManagement alloc]
                                                    initWithStorage:_ProtoStreamManagementMemoryStorage];
        
        _ProtoStreamManagement.autoResume = YES;
        
        [_ProtoStreamManagement activate:_ManagerStream];
        
        [_ProtoStreamManagement addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
    }

    return self;
}



-(void)addProtoStreamManagerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoStreamManagerQueue dispatchOnQueue:^{

        [self->protoStreamManagerMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];

}


- (void)removeProtoStreamManagerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoStreamManagerQueue dispatchOnQueue:^{

          [self->protoStreamManagerMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

      } synchronous:YES];
}


- (void)removeProtoStreamManagerDelegate:(id)delegate
{

    [protoStreamManagerQueue dispatchOnQueue:^{

          [self->protoStreamManagerMulticasDelegate removeDelegate:delegate];

      } synchronous:YES];
}



@end
