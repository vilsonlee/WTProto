//
//  WTProtoUserInfoService.m
//  WTProtocalKit
//
//  Created by Vilson on 2020/1/17.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoUserInfoService.h"
#import "WTProtoQueue.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoIQ.h"
#import "WTProtoIDTracker.h"
#import "WTProtoUserInfoIQ.h"
#import "NSObject+PerformSelector.h"


#define WEAKSELF                            typeof(self) __weak weakSelf = self;

static WTProtoUserInfoService *userInfoService= nil;
static dispatch_once_t onceToken;

static WTProtoQueue *userInfoServiceQueue = nil;
static dispatch_once_t queueOnceToken;


@interface WTProtoUserInfoService()<
                                    WTProtoStreamDelegate,
                                    XMPPMUCDelegate,
                                    XMPPRoomDelegate
                                   >
{
    WTProtoQueue*  proto_UserInfoService_Queue;
    GCDMulticastDelegate <WTProtoUserInfoServiceDelegate> *proto_UserInfoService_MulticasDelegate;
}

@property (nonatomic,copy)NSMutableDictionary * IQ_Result_distributie_Dic;

@end


@implementation WTProtoUserInfoService


#pragma mark -- 初始化
+ (WTProtoQueue *)userInfoServiceQueue{
    
    dispatch_once(&queueOnceToken, ^
    {
        userInfoServiceQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:userInfoService"];
    });
    return userInfoServiceQueue;
}


+ (void)dellocSelf
{
    userInfoService = nil;
    onceToken = 0l;
    
    userInfoServiceQueue = nil;
    queueOnceToken = 0l;
}


+ (WTProtoUserInfoService *)shareUserInfoServiceWithProtoStream:(WTProtoStream *)protoStream
                                            interface:(NSString *)interface
{
    dispatch_once(&onceToken, ^{
        
        userInfoService = [[WTProtoUserInfoService alloc]initUserInfoServiceWithProtoStream:protoStream
                                                                                  interface:interface];
           
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
        
       });
    
    return userInfoService;
}


- (instancetype)initUserInfoServiceWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface
{
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"protoStream should not be nil");
    #endif
    
    if (self = [super init])
    {
        _UserInfoServiceStream = protoStream;
        
        [_UserInfoServiceStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        proto_UserInfoService_Queue = [WTProtoUserInfoService userInfoServiceQueue];
        
        proto_UserInfoService_MulticasDelegate = (GCDMulticastDelegate <WTProtoUserInfoServiceDelegate> *)[[GCDMulticastDelegate alloc] init];
            
        _protoTracker = [[WTProtoIDTracker alloc] initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
    }
    return self;
}

- (NSMutableDictionary *)IQ_Result_distributie_Dic{
    
    if (!_IQ_Result_distributie_Dic) {
        _IQ_Result_distributie_Dic = [NSMutableDictionary dictionary];
    }
    return _IQ_Result_distributie_Dic;
}


-(void)addProtoUserInfoServiceDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    
    [proto_UserInfoService_Queue dispatchOnQueue:^{
        
        [self->proto_UserInfoService_MulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
    
}


-(void)removeProtoUserInfoServiceDelegate:(id)delegate delegateQueue:(nonnull dispatch_queue_t)delegateQueue{
    
    [proto_UserInfoService_Queue dispatchOnQueue:^{
        
        [self->proto_UserInfoService_MulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
    
    
}

-(void)removeProtoUserInfoServiceDelegate:(id)delegate
{
    [proto_UserInfoService_Queue dispatchOnQueue:^{
        
        [self->proto_UserInfoService_MulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
    
}


-(void)IQ_Result_distributieWithSEL:(SEL)sel methodID:(NSString*)methodID fetchID:(NSString *)fetchID{
    NSString * handleSEL = NSStringFromSelector(sel);//结果处理的回调方法
    NSDictionary * infoDict = @{@"methodID":methodID, @"sel":handleSEL};
    [self.IQ_Result_distributie_Dic setObject:infoDict forKey:fetchID];
}



-(void)request_IQ_SearchUserInfoWithLocalUser:(WTProtoUser *)localUser
                                      KeyWord:(NSString *)key
                                      keyType:(NSString *)type
                              searchFromGroup:(BOOL)fromGroup
{

     WTProtoIQ* searchUserInfo_IQ = [WTProtoUserInfoIQ IQ_SearchUserInfoWithLocalUser:localUser
                                                                           KeyWord:key
                                                                           keyType:type
                                                                   searchFromGroup:fromGroup];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SearchUserInfo:)
                              methodID:@"SearchUserInfo"
                               fetchID:searchUserInfo_IQ.elementID];
    
    [_UserInfoServiceStream sendElement:(XMPPIQ*)searchUserInfo_IQ];
    
    [self addtracker:searchUserInfo_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


-(void)handeleResult_IQ_SearchUserInfo:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoUserInfoIQ parse_IQ_SearchUserInfo:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->proto_UserInfoService_MulticasDelegate WTProtoUserInfoService:weakSelf SearchUserResult:succeed info:Info];
    }];
}


#pragma mark -  XMPPStream Presence delegate

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(nonnull XMPPIQ *)iq
{
    NSString *outgoingStr = [iq compactXMLString];
    
    NSLog(@"%s___%d",__FUNCTION__,__LINE__);
    NSLog(@"\n\n didReceiveIQ = %@ \n\n",outgoingStr);
    
    NSString * elementID = iq.elementID;
    
    if (elementID == nil) {
        return YES;
    }
    
    [_protoTracker invokeForID:elementID withObject:iq];
    
    if ([self.IQ_Result_distributie_Dic objectForKey:elementID]) {
        
        NSDictionary * dict = [self.IQ_Result_distributie_Dic objectForKey:elementID];
        
        if ([dict objectForKey:@"sel"])
        {
            SEL sel = NSSelectorFromString([dict objectForKey:@"sel"]);
            if ([self respondsToSelector:sel])
            {
                 [self performSelector:sel withObjects:@[iq]];
            }
        }
        else
        {
            
        }
    }
    
    return YES;
}



#pragma mark - 超时设置
- (void)addtracker:(WTProtoIQ *)iq timeout:(NSTimeInterval)timeout
{
    XMPPElement *element =(XMPPElement *)iq;
    
    [_protoTracker addElement:element target:self selector:@selector(IQsendTimeout:withInfo:) timeout:timeout];
}

- (void)IQsendTimeout:(DDXMLElement *)element withInfo:(XMPPBasicTrackingInfo*)trackerInfo
{
    if (!element) {
        NSLog(@"发送超时");
        //trackerInfo.element
        if ([trackerInfo.element isKindOfClass:[XMPPIQ class]] ||
            [trackerInfo.element isKindOfClass:[WTProtoIQ class]])
        {
            //iq请求发送超时 FIXIME:调整error
            NSError *error = [NSError errorWithDomain:@"发送超时" code:0 userInfo:nil];
            [self xmppStream:_UserInfoServiceStream didFailToSendIQ:(WTProtoIQ *)trackerInfo.element error:error];
        }
    }
}


@end
