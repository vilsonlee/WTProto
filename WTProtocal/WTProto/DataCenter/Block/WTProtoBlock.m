//
//  WTProtoBlock.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoBlock.h"
#import "WTProtoBlocking.h"
#import "WTProtoStream.h"
#import "WTProtoQueue.h"


@interface WTProtoBlock()<XMPPBlockingDelegate>
{
    WTProtoQueue*  protoBlockQueue;
    GCDMulticastDelegate <WTProtoBlockDelegate> *protoBlockMulticasDelegate;
}
@end

@implementation WTProtoBlock

+ (WTProtoQueue *)blockQueue
{
    static WTProtoQueue *blockQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        blockQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:block"];
    });
    return blockQueue;
}

+ (WTProtoBlock *)shareBlockWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface
{
    static WTProtoBlock *protoBlock = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        protoBlock = [[WTProtoBlock alloc]initWithBlockWithProtoStream:protoStream interface:interface];
        
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return protoBlock;
    
}


-(instancetype)initWithBlockWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface{
    
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"address should not be nil");
    #endif

    if (self = [super init])
    {
        _blockStream = protoStream;
        
        protoBlockQueue = [WTProtoBlock blockQueue];
        
        _protoBlocking = [[WTProtoBlocking alloc] initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        [_protoBlocking activate:_blockStream];
        
        [_protoBlocking addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        protoBlockMulticasDelegate = (GCDMulticastDelegate <WTProtoBlockDelegate> *)[[GCDMulticastDelegate alloc] init];
    }

    return self;
}

-(void)addProtoBlockDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoBlockQueue dispatchOnQueue:^{

        [self->protoBlockMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];

}


- (void)removeProtoBlockDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoBlockQueue dispatchOnQueue:^{

          [self->protoBlockMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

      } synchronous:YES];
}


- (void)removeProtoBlockDelegate:(id)delegate
{

    [protoBlockQueue dispatchOnQueue:^{

          [self->protoBlockMulticasDelegate removeDelegate:delegate];

      } synchronous:YES];
}




-(void)setAutoClearBlockingListInfo:(BOOL)autoClearBlockingListInfo
{
    _protoBlocking.autoClearBlockingListInfo = _autoClearBlockingListInfo = autoClearBlockingListInfo;
}

-(void)setAutoRetrieveBlockingListItems:(BOOL)autoRetrieveBlockingListItems
{
    _protoBlocking.autoRetrieveBlockingListItems = _autoRetrieveBlockingListItems = autoRetrieveBlockingListItems;
}


- (void)xmppBlocking:(XMPPBlocking *)sender didReceivedBlockingList:(NSArray*)blockingList
{
    
}


- (void)xmppBlocking:(XMPPBlocking *)sender didNotReceivedBlockingListDueToError:(id)error
{
    
}


- (void)xmppBlocking:(XMPPBlocking *)sender didReceivePushWithBlockingList:(NSString *)name
{
    
}


- (void)xmppBlocking:(XMPPBlocking *)sender didBlockJID:(XMPPJID*)xmppJID
{
    
}


- (void)xmppBlocking:(XMPPBlocking *)sender didNotBlockJID:(XMPPJID*)xmppJID error:(id)error
{
    
}


- (void)xmppBlocking:(XMPPBlocking *)sender didUnblockJID:(XMPPJID*)xmppJID
{
    
}

- (void)xmppBlocking:(XMPPBlocking *)sender didNotUnblockJID:(XMPPJID*)xmppJID error:(id)error
{
    
}


- (void)xmppBlocking:(XMPPBlocking *)sender didUnblockAllWithError:(id)error
{
    
}


- (void)xmppBlocking:(XMPPBlocking *)sender didNotUnblockAllDueToError:(id)error
{
    
}




@end
