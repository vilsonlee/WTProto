//
//  WTProtoOffLineMessage.m
//  WTProtocalKit
//
//  Created by Mark on 2019/12/19.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoOffLineMessageManager.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoQueue.h"
#import "WTProtoTimer.h"
#import "WTProtoIQ.h"
#import "WTProtoOfflineMessageIQ.h"
#import "WTProtoIDTracker.h"
#import "NSObject+PerformSelector.h"

#import "WTProtoTrackerManager.h"

#define WEAKSELF                            typeof(self) __weak weakSelf = self;

static WTProtoOffLineMessageManager *protoOffLineMessage = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *offLineMessageQueue = nil;
static dispatch_once_t queueOnceToken;


@interface WTProtoOffLineMessageManager () <WTProtoStreamDelegate,
                                            WTProtoTrackerManagerDelegate>
{
    
    WTProtoQueue                                           *protoOffLineMessageQueue;
    GCDMulticastDelegate <WTProtoOffLineMessageDelegate>   *protoReConnectionMulticasDelegate;
    
    WTProtoTrackerManager *trackerManager;
}

@property (nonatomic,copy)NSMutableDictionary * IQ_Result_distributie_Dic;

@end
 
@implementation WTProtoOffLineMessageManager

- (NSMutableDictionary *)IQ_Result_distributie_Dic{
    
    if (!_IQ_Result_distributie_Dic)
    {
        _IQ_Result_distributie_Dic = [NSMutableDictionary dictionary];
    }
    return _IQ_Result_distributie_Dic;
}


+ (void)dellocSelf
{
    protoOffLineMessage = nil;
    onceToken = 0l;
    
    offLineMessageQueue = nil;
    queueOnceToken = 0l;
}


+ (WTProtoQueue *)offLineMessageQueue
{
    dispatch_once(&queueOnceToken, ^
    {
        offLineMessageQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:offLineMessage"];
    });
    return offLineMessageQueue;
}


+ (WTProtoOffLineMessageManager *)shareOffLineMessageWithProtoStream:(WTProtoStream *)protoStream
                                                    interface:(NSString *)interface{
    dispatch_once(&onceToken, ^{
        
        protoOffLineMessage = [[WTProtoOffLineMessageManager alloc] initGroupWithProtoStream:protoStream
                                                                                   interface:interface];
           
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
        
       });
    
    return protoOffLineMessage;
}


- (instancetype)initGroupWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface
{
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"protoStream should not be nil");
    #endif
    
    if (self = [super init])
    {
        _offLineMessageStream = protoStream;
        
        [_offLineMessageStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        protoOffLineMessageQueue = [WTProtoOffLineMessageManager offLineMessageQueue];
        
        protoReConnectionMulticasDelegate = (GCDMulticastDelegate <WTProtoOffLineMessageDelegate> *)[[GCDMulticastDelegate alloc] init];
    
        _protoTracker = [[WTProtoIDTracker alloc] initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        trackerManager = [[WTProtoTrackerManager alloc]initTrackerManager];
        
        [trackerManager addProtoTrackerDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    }
    return self;
}


- (void)addProtoOffLineMessageDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    
    [protoOffLineMessageQueue dispatchOnQueue:^{
        
        [self->protoReConnectionMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}


- (void)removeProtoOffLineMessageDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    
    [protoOffLineMessageQueue dispatchOnQueue:^{
        
        [self->protoReConnectionMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];
        
    } synchronous:NO];
}


- (void)removeProtoOffLineMessageDelegate:(id)delegate{
    
    [protoOffLineMessageQueue dispatchOnQueue:^{
        
        [self->protoReConnectionMulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
}


-(void)IQ_Result_distributieWithSEL:(SEL)sel methodID:(NSString*)methodID fetchID:(NSString *)fetchID{
    NSString * handleSEL    = NSStringFromSelector(sel);//结果处理的回调方法
    NSDictionary * infoDict = @{@"methodID":methodID, @"sel":handleSEL};
    [self.IQ_Result_distributie_Dic setObject:infoDict forKey:fetchID];
}

#pragma mark - Main Method

#pragma mark - 获取单聊的离线消息(旧方式获取)
//发送请求
- (void)getSingleChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser timestamp:(NSString *)timestamp{
    
    WTProtoUser * toID = (WTProtoUser *)[_offLineMessageStream.myJID domainJID];
    WTProtoIQ* getSingleChatOffline_IQ = [WTProtoOfflineMessageIQ IQ_GetSingleChatOfflineMessageWithFromUser:fromUser toID:toID timestamp:timestamp];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SingleChatOfflineMessage:)
                              methodID:@"singleChatOffline_old"
                               fetchID:getSingleChatOffline_IQ.elementID];
    
    [_offLineMessageStream sendElement:(XMPPIQ*)getSingleChatOffline_IQ];
    
    [trackerManager addTimeOutTrack:getSingleChatOffline_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}

//结果回调
-(void)handeleResult_IQ_SingleChatOfflineMessage:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoOfflineMessageIQ parse_IQ_GetSingleChatOfflineMessage:iq parseResult:^(BOOL succeed, BOOL isEmpty, id  _Nonnull info) {

        [self->protoReConnectionMulticasDelegate WTProtoOffLineMessage:weakSelf getSingleChatOfflineMessage_ResultWithSucceed:succeed isEmpty:isEmpty info:info];
    }];
    
}

#pragma mark - 获取单聊的离线消息会话列表(新方式获取)
//发送请求
- (void)getSingleChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser{
    
    WTProtoUser * toID = (WTProtoUser *)[_offLineMessageStream.myJID domainJID];
    WTProtoIQ* getSingleChatOfflineList_IQ = [WTProtoOfflineMessageIQ IQ_GetSingleChatOfflineListDynamicsWithFromUser:fromUser toID:toID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SingleChatOfflineListDynamics:)
                              methodID:@"singleChatOffline_list"
                               fetchID:getSingleChatOfflineList_IQ.elementID];
    
    [_offLineMessageStream sendElement:(XMPPIQ*)getSingleChatOfflineList_IQ];
    
    [trackerManager addTimeOutTrack:getSingleChatOfflineList_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}

//结果回调
-(void)handeleResult_IQ_SingleChatOfflineListDynamics:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoOfflineMessageIQ parse_IQ_GetSingleChatOfflineListDynamics:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        
        [self->protoReConnectionMulticasDelegate WTProtoOffLineMessage:weakSelf getSingleChatOfflineListDynamics_ResultWithSucceed:succeed info:info];
    }];
    
}


#pragma mark -获取单聊离线消息, 动态拉取单聊离线消息, 与新单聊列表对应使用
//发送请求
- (void)getSingleChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser startIndex:(NSString *)start endIndex:(NSString *)end ascending:(BOOL)ascending chatJid:(NSString *)chatJid{
    
    WTProtoUser * toID = (WTProtoUser *)[_offLineMessageStream.myJID domainJID];
    WTProtoIQ* getSingleChatOfflineMessage_IQ = [WTProtoOfflineMessageIQ IQ_GetSingleChatOfflineMessageDynamicsWithFromUser:fromUser toID:toID startIndex:start endIndex:end ascending:ascending chatJid:chatJid];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SingleChatOfflineMessageDynamics:)
                              methodID:@"singleChatOffline_new"
                               fetchID:getSingleChatOfflineMessage_IQ.elementID];
    
    [_offLineMessageStream sendElement:(XMPPIQ*)getSingleChatOfflineMessage_IQ];

    [trackerManager addTimeOutTrack:getSingleChatOfflineMessage_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}

//结果回调
-(void)handeleResult_IQ_SingleChatOfflineMessageDynamics:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoOfflineMessageIQ parse_IQ_GetSingleChatOfflineMessageDynamics:iq parseResult:^(BOOL succeed, id  _Nonnull info) {

        [self->protoReConnectionMulticasDelegate WTProtoOffLineMessage:weakSelf getSingleChatOfflineMessageDynamics_ResultWithSucceed:succeed info:info];
    }];
    
}


#pragma mark - 获取群聊离线会话列表（旧方式）
//发送请求
- (void)getGroupChatOfflineListWithFromUser:(WTProtoUser *)fromUser{
    
    WTProtoUser * toID = (WTProtoUser *)[_offLineMessageStream.myJID domainJID];
    WTProtoIQ* getGroupChatOfflineList_IQ = [WTProtoOfflineMessageIQ IQ_GetGroupChatOfflineListWithFromUser:fromUser toID:toID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GroupChatOfflineList:)
                              methodID:@"groupChatOfflineList_old"
                               fetchID:getGroupChatOfflineList_IQ.elementID];
    
    [_offLineMessageStream sendElement:(XMPPIQ*)getGroupChatOfflineList_IQ];
    
    [trackerManager addTimeOutTrack:getGroupChatOfflineList_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}

//结果回调
-(void)handeleResult_IQ_GroupChatOfflineList:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoOfflineMessageIQ parse_IQ_GetGroupChatOfflineList:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        
        [self->protoReConnectionMulticasDelegate WTProtoOffLineMessage:weakSelf getGroupChatOfflineList_ResultWithSucceed:succeed info:info];
    }];
    
}

#pragma mark -  获取群聊离线会话列表（新方式）
//发送请求
- (void)getGroupChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser{
    WTProtoUser * toID = (WTProtoUser *)[_offLineMessageStream.myJID domainJID];
    WTProtoIQ* getGroupChatOfflineListDynamics_IQ = [WTProtoOfflineMessageIQ IQ_GetGroupChatOfflineListDynamicsWithFromUser:fromUser toID:toID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GroupChatOfflineListDynamics:)
                              methodID:@"groupChatOfflineList_new"
                               fetchID:getGroupChatOfflineListDynamics_IQ.elementID];
    
    [_offLineMessageStream sendElement:(XMPPIQ*)getGroupChatOfflineListDynamics_IQ];
        
    [trackerManager addTimeOutTrack:getGroupChatOfflineListDynamics_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}

//结果回调
-(void)handeleResult_IQ_GroupChatOfflineListDynamics:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoOfflineMessageIQ parse_IQ_GetGroupChatOfflineListDynamics:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        
        [self->protoReConnectionMulticasDelegate WTProtoOffLineMessage:weakSelf getGroupChatOfflineListDynamics_ResultWithSucceed:succeed info:info];
    }];
    
}



#pragma mark -  获取群聊的离线消息(旧方式)
//发送请求
- (void)getGroupChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser timestamp:(NSString *)timestamp chatJid:(NSString *)chatJid{
    
    WTProtoUser * toID = (WTProtoUser *)[_offLineMessageStream.myJID domainJID];
    
    WTProtoIQ* getGroupChatOfflineMessage_IQ = [WTProtoOfflineMessageIQ
                                                IQ_GetGroupChatOfflineMessageWithFromUser:fromUser
                                                                                     toID:toID
                                                                                timestamp:timestamp
                                                                                  chatJid:chatJid];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GroupChatOfflineMessage:)
                              methodID:@"groupChatOffline_old"
                               fetchID:getGroupChatOfflineMessage_IQ.elementID];
    
    [_offLineMessageStream sendElement:(XMPPIQ*)getGroupChatOfflineMessage_IQ];
        
    [trackerManager addTimeOutTrack:getGroupChatOfflineMessage_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}

//结果回调
-(void)handeleResult_IQ_GroupChatOfflineMessage:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoOfflineMessageIQ parse_IQ_GetGroupChatOfflineMessage:iq parseResult:^(BOOL succeed, BOOL isEmpty, id  _Nonnull info) {
        
        [self->protoReConnectionMulticasDelegate WTProtoOffLineMessage:weakSelf getGroupChatOfflineMessage_ResultWithSucceed:succeed isEmpty:isEmpty info:info];
    }];
    
}


#pragma mark -   获取群聊的离线消息(新方式)
//发送请求
- (void)getGroupChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser
                                            startIndex:(NSString *)start
                                              endIndex:(NSString *)end
                                             ascending:(BOOL)ascending
                                               chatJid:(NSString *)chatJid
{
    WTProtoUser *toID = (WTProtoUser *)[_offLineMessageStream.myJID domainJID];
    
    WTProtoIQ   *getGroupChatOfflineMessageDynamics_IQ = [WTProtoOfflineMessageIQ
                                                          IQ_GetGroupChatOfflineMessageDynamicsWithFromUser:fromUser
                                                                toID:toID
                                                          startIndex:start
                                                            endIndex:end
                                                           ascending:ascending
                                                             chatJid:chatJid];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GroupChatOfflineMessageDynamics:)
                              methodID:@"groupChatOffline_new"
                               fetchID:getGroupChatOfflineMessageDynamics_IQ.elementID];
    
    [_offLineMessageStream sendElement:(XMPPIQ*)getGroupChatOfflineMessageDynamics_IQ];
    
    [trackerManager addTimeOutTrack:getGroupChatOfflineMessageDynamics_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}

//结果回调
-(void)handeleResult_IQ_GroupChatOfflineMessageDynamics:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoOfflineMessageIQ parse_IQ_GetGroupChatOfflineMessageDynamics:iq parseResult:^(BOOL succeed, id  _Nonnull info) {

        [self->protoReConnectionMulticasDelegate WTProtoOffLineMessage:weakSelf getGroupChatOfflineMessageDynamics_ResultWithSucceed:succeed info:info];
    }];
    
}







#pragma mark - didReceiveIQ
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(nonnull XMPPIQ *)iq
{
    
    NSString *outgoingStr = [iq compactXMLString];
    
    NSLog(@"%s___%d",__FUNCTION__,__LINE__);
    NSLog(@"\n\n didReceiveIQ = %@ \n\n",outgoingStr);
    
    NSString * elementID = iq.elementID;
    
    if (elementID == nil) {
        return YES;
    }
        
    [trackerManager invokeForIQ:[WTProtoIQ iqWithiq:iq]];
    
    if ([self.IQ_Result_distributie_Dic objectForKey:elementID]) {
        
        NSDictionary * dict = [self.IQ_Result_distributie_Dic objectForKey:elementID];
        
        if ([dict objectForKey:@"sel"])
        {
            SEL sel = NSSelectorFromString([dict objectForKey:@"sel"]);
            if ([self respondsToSelector:sel])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                    [self performSelector:sel withObject:completionHandle];
                [self performSelector:sel withObjects:@[iq]];
#pragma clang diagnostic pop
            }
        }
        else
        {
            
        }
    }
    
    return YES;
}


- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSLog(@"\n\n didFailToSendIQ %s___%d error = %@\n\n",__FUNCTION__,__LINE__,error);
    
    [iq addChild:[XMPPElement elementWithName:@"error" stringValue:error.description]];
    [iq addAttributeWithName:@"type" stringValue:@"error"];
    
    [self xmppStream:sender didReceiveIQ:iq];
}

#pragma mark - protoTrackerManager 超时设置
-(void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager trackTimeOutIQ:(WTProtoIQ *)iq
{
    //iq请求发送超时 FIXIME:调整error
    NSError* error = [[NSError alloc]init];
    [self xmppStream:_offLineMessageStream didFailToSendIQ:iq error:error];
}

@end
