//
//  WTProtoUserConfigService.m
//  WTProtocalKit
//
//  Created by Mark on 2020/3/13.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoUserConfigService.h"

#import "WTProtoQueue.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoIQ.h"

#import "WTProtoUserConfigIQ.h"

#import "WTProtoTrackerManager.h"
#import "NSObject+PerformSelector.h"

#define WEAKSELF                            typeof(self) __weak weakSelf = self;

static WTProtoUserConfigService *userConfigService= nil;
static dispatch_once_t onceToken;

static WTProtoQueue *userConfigServiceQueue = nil;
static dispatch_once_t queueOnceToken;


@interface WTProtoUserConfigService()<
                                    WTProtoStreamDelegate,
                                    WTProtoTrackerManagerDelegate
                                   >
{
    WTProtoQueue*  proto_UserConfigService_Queue;
    GCDMulticastDelegate <WTProtoUserConfigServiceDelegate> *proto_UserConfigService_MulticasDelegate;
        
    WTProtoTrackerManager *trackerManager;
}

@property (nonatomic,copy)NSMutableDictionary * IQ_Result_distributie_Dic;

@end

@implementation WTProtoUserConfigService

- (NSMutableDictionary *)IQ_Result_distributie_Dic{
    
    if (!_IQ_Result_distributie_Dic) {
        _IQ_Result_distributie_Dic = [NSMutableDictionary dictionary];
    }
    return _IQ_Result_distributie_Dic;
}

+ (void)dellocSelf{
    userConfigService = nil;
    onceToken = 0l;
    
    userConfigServiceQueue = nil;
    queueOnceToken = 0l;
}

+ (WTProtoQueue *)userConfigServiceQueue
{
    dispatch_once(&queueOnceToken, ^
    {
        userConfigServiceQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:userConfig"];
    });
    return userConfigServiceQueue;
}


+ (WTProtoUserConfigService *)shareUserConfigServiceWithProtoStream:(WTProtoStream *)protoStream
                                                          interface:(NSString *)interface

{
    dispatch_once(&onceToken, ^{
        
        userConfigService = [[WTProtoUserConfigService alloc] initUserConfigServiceWithProtoStream:protoStream
                                                        interface:interface];
           
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
        
       });
    
    return userConfigService;
}


- (instancetype)initUserConfigServiceWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface
{
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"protoStream should not be nil");
    #endif
    
    if (self = [super init])
    {
        _userConfigStream = protoStream;
        
        [_userConfigStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        proto_UserConfigService_Queue = [WTProtoUserConfigService userConfigServiceQueue];
        
        proto_UserConfigService_MulticasDelegate = (GCDMulticastDelegate <WTProtoUserConfigServiceDelegate> *)[[GCDMulticastDelegate alloc] init];
    
        trackerManager = [[WTProtoTrackerManager alloc] initTrackerManager];
        [trackerManager addProtoTrackerDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
    }
    return self;
}

- (void)addProtoUserConfigServiceDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    
    [proto_UserConfigService_Queue dispatchOnQueue:^{
        
        [self->proto_UserConfigService_MulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}

- (void)removeProtoUserConfigServiceDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    [proto_UserConfigService_Queue dispatchOnQueue:^{
        
        [self->proto_UserConfigService_MulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}

- (void)removeProtoUserConfigServiceDelegate:(id)delegate{
    [proto_UserConfigService_Queue dispatchOnQueue:^{
        
        [self->proto_UserConfigService_MulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
}


-(void)IQ_Result_distributieWithSEL:(SEL)sel methodID:(NSString*)methodID fetchID:(NSString *)fetchID{
    NSString * handleSEL = NSStringFromSelector(sel);//结果处理的回调方法
    NSDictionary * infoDict = @{@"methodID":methodID, @"sel":handleSEL};
    [self.IQ_Result_distributie_Dic setObject:infoDict forKey:fetchID];
}

#pragma mark - Delegate

#pragma mark - protoTrackerManager 超时设置
-(void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager trackTimeOutIQ:(WTProtoIQ *)iq
{
    //iq请求发送超时 FIXIME:调整error
    NSError *error = [NSError errorWithDomain:@"发送超时" code:0 userInfo:nil];
    [self xmppStream:_userConfigStream didFailToSendIQ:iq error:error];
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

#pragma mark - Main Method

#pragma mark - 获取用户偏好设置
- (void)IQ_getUserPerferenceInfo:(WTProtoUser *)fromUser{
    
    WTProtoIQ * getUserPerference_IQ  = [WTProtoUserConfigIQ IQ_getUserPerferenceWithLocalUser:fromUser];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetUserPerference:)
                              methodID:@"GetUserPerference"
                               fetchID:getUserPerference_IQ.elementID];
    
    [_userConfigStream sendElement:(XMPPIQ*)getUserPerference_IQ];
    
    [trackerManager addTimeOutTrack:getUserPerference_IQ timeout:TrackerTimeOutInterval];
}

// 获取用户偏好设置 请求回调结果
-(void)handeleResult_IQ_GetUserPerference:(XMPPIQ *)iq{

    WEAKSELF
    [WTProtoUserConfigIQ parse_IQ_getUserPerference:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->proto_UserConfigService_MulticasDelegate WTProtoUserConfigService:weakSelf getUserPerferenceResult:succeed info:info];
    }];

}

#pragma mark - 获取用户聊天设置
- (void)IQ_getUserChatSettingInfo:(WTProtoUser *)fromUser{
    
    WTProtoIQ * getUserChatSetting_IQ  = [WTProtoUserConfigIQ IQ_getUserChatSettingWithLocalUser:fromUser];

    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetUserChatSetting:)
                              methodID:@"GetUserChatSetting"
                               fetchID:getUserChatSetting_IQ.elementID];
    
    [_userConfigStream sendElement:(XMPPIQ*)getUserChatSetting_IQ];
    
    [trackerManager addTimeOutTrack:getUserChatSetting_IQ timeout:TrackerTimeOutInterval];
}

// 获取用户聊天设置 请求回调结果
-(void)handeleResult_IQ_GetUserChatSetting:(XMPPIQ *)iq{

    WEAKSELF
    [WTProtoUserConfigIQ parse_IQ_getUserChatSetting:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->proto_UserConfigService_MulticasDelegate WTProtoUserConfigService:weakSelf getUserChatSettingResult:succeed info:info];
    }];

}

#pragma mark - 更新用户偏好设置
- (void)IQ_updateUserConfigWithDict:(NSDictionary *)data fromUser:(WTProtoUser *)fromUser{
    
    WTProtoIQ * updateUserConfig_IQ  = [WTProtoUserConfigIQ IQ_updateUserConfigWithDict:data localUser:fromUser];

    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_UpdateUserConfig:)
                              methodID:@"UpdateUserConfig"
                               fetchID:updateUserConfig_IQ.elementID];
    
    [_userConfigStream sendElement:(XMPPIQ*)updateUserConfig_IQ];
    
    [trackerManager addTimeOutTrack:updateUserConfig_IQ timeout:TrackerTimeOutInterval];
    
}

// 更新用户偏好设置 请求回调结果
-(void)handeleResult_IQ_UpdateUserConfig:(XMPPIQ *)iq{

    WEAKSELF
    [WTProtoUserConfigIQ parse_IQ_updateUserConfig:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->proto_UserConfigService_MulticasDelegate WTProtoUserConfigService:weakSelf updateUserConfigResult:succeed info:info];
    }];

}

#pragma mark - 更新用户聊天配置
- (void)IQ_updateUserChatSettingWithDict:(NSDictionary *)data fromUser:(WTProtoUser *)fromUser{
    
    WTProtoIQ * updateUserChatSetting_IQ  = [WTProtoUserConfigIQ IQ_updateUserChatSettingWithDict:data localUser:fromUser];

    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_UpdateUserChatSetting:)
                              methodID:@"UpdateUserChatSetting"
                               fetchID:updateUserChatSetting_IQ.elementID];
    
    [_userConfigStream sendElement:(XMPPIQ*)updateUserChatSetting_IQ];
    
    [trackerManager addTimeOutTrack:updateUserChatSetting_IQ timeout:TrackerTimeOutInterval];
    
}

// 更新用户聊天配置 请求回调结果
-(void)handeleResult_IQ_UpdateUserChatSetting:(XMPPIQ *)iq{

    WEAKSELF
    [WTProtoUserConfigIQ parse_IQ_updateUserChatSetting:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->proto_UserConfigService_MulticasDelegate WTProtoUserConfigService:weakSelf updateUserChatSettingResult:succeed info:info];
    }];

}

#pragma mark - 移除用户聊天配置
- (void)IQ_removeUserChatSettingWithDict:(NSDictionary *)data fromUser:(WTProtoUser *)fromUser{
    
    WTProtoIQ * removeUserChatSetting_IQ  = [WTProtoUserConfigIQ IQ_removeUserChatSettingWithDict:data localUser:fromUser];

    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_RemoveUserChatSetting:)
                              methodID:@"RemoveUserChatSetting"
                               fetchID:removeUserChatSetting_IQ.elementID];
    
    [_userConfigStream sendElement:(XMPPIQ*)removeUserChatSetting_IQ];
    
    [trackerManager addTimeOutTrack:removeUserChatSetting_IQ timeout:TrackerTimeOutInterval];
    
}

// 移除用户聊天配置 请求回调结果
-(void)handeleResult_IQ_RemoveUserChatSetting:(XMPPIQ *)iq{

    WEAKSELF
    [WTProtoUserConfigIQ parse_IQ_removeUserChatSetting:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->proto_UserConfigService_MulticasDelegate WTProtoUserConfigService:weakSelf removeUserChatSettingResult:succeed info:info];
    }];

}




@end
