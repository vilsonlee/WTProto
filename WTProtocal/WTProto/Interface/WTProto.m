//
//  WTProto.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/10/31.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTProto.h"
#import "WTProtoLogging.h"
#import "WTProtoQueue.h"
#import "WTProtoUser.h"
#import "WTProtoStream.h"
#import "WTProtoStreamManager.h"
#import "WTProtoServerAddress.h"
#import "WTProtoConnection.h"
#import "WTProtoRegister.h"
#import "WTProtoAuth.h"
#import "WTProtoReConnection.h"
#import "WTProtoBlock.h"
#import "WTProtoPing.h"
#import "WTProtoRosters.h"
#import "WTProtoGroup.h"
#import "WTProtoMessageCenter.h"
#import "WTProtoOnlinePresent.h"
#import "WTProtoContact.h"

static WTProto *proto = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *protoQueue = nil;
static dispatch_once_t queueOnceToken;

@interface WTProto () <
                       WTProtoStreamManagerDelegate,
                       WTProtoConnectionDelegate,
                       WTProtoRegisterDelegate,
                       WTProtoAuthDelegate,
                       WTProtoReConnectionDelegate,
                       WTProtoBlockDelegate,
                       WTProtoPingDelegate,
                       WTProtoRostersDelegate,
                       WTProtoGroupDelegate,
                       WTProtoMessageCenterDelegate,
                       WTProtoContactDelegate
                      >


{
    WTProtoQueue *_protoQueue;
    GCDMulticastDelegate <WTProtoDelegate> *protoMulticasDelegate;
    
    WTProtoUser             *_protoUser;
    WTProtoServerAddress    *_serverAddress;
    WTProtoStream           *_protoStream;
    WTProtoStreamManager    *_proStreamManager;
    WTProtoConnection       *_protoConnection;
    WTProtoRegister         *_protoRegister;
    WTProtoAuth             *_protoAuth;
    WTProtoReConnection     *_protoReConnection;
    WTProtoBlock            *_protoBlock;
    WTProtoPing             *_protoPing;
    WTProtoRosters          *_protoRosters;
    WTProtoGroup            *_protoGroup;
    WTProtoMessageCenter    *_protoMessageCenter;
    WTProtoContact          *_protoContact;
}

@end


@implementation WTProto

+ (void)dellocSelf{
        
    queueOnceToken = 0l;
    protoQueue = nil;
    
    onceToken = 0l;
    proto = nil;
}



+ (WTProtoQueue *)ProtoQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&queueOnceToken, ^
    {
        protoQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue"];
    });
    return protoQueue;
}

+ (WTProto *)shareWTProtoDomain:(NSString *)domain Resource:(NSString *)resource
{
    return [WTProto defaultShareWTProtoUserID:@""
                                       Domain:domain
                                     Resource:resource
                                     Password:@""
                                     UserType:WTProtoUserTypePhoneNumber];
}


+ (WTProto *)shareWTProtoPhoneNumber:(NSString *)phoneNumber
                              Domain:(NSString *)domain
                            Resource:(NSString *)resource
{
    return [WTProto defaultShareWTProtoUserID:phoneNumber
                                       Domain:domain
                                     Resource:resource
                                     Password:@""
                                     UserType:WTProtoUserTypePhoneNumber];
}


+ (WTProto *)shareWTProtoUserID:(NSString *)UserID
                         Domain:(NSString *)domain
                       Resource:(NSString *)resource
                       Password:(NSString *)password
{
    
    return [WTProto defaultShareWTProtoUserID:UserID
                                       Domain:domain
                                     Resource:resource
                                     Password:password
                                     UserType:WTProtoUserTypeUserID];
}


+ (WTProto *)defaultShareWTProtoUserID:(NSString *)UserID
                                Domain:(NSString *)domain
                              Resource:(NSString *)resource
                              Password:(NSString *)password
                              UserType:(WTProtoUserType)userType
{
        dispatch_once(&onceToken, ^{
          
          proto = [[WTProto alloc]initMTProtoWithUserID:UserID
                                                 Domain:domain
                                               Resource:resource
                                               Password:password
                                               UserType:userType];
          
          [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
      });
      return proto;
}


-(instancetype)initMTProtoWithUserID:(NSString *)UserID
                              Domain:(NSString *)domain
                            Resource:(NSString *)resource
                            Password:(NSString *)password
                            UserType:(WTProtoUserType)userType
{
    
    #ifdef DEBUG
        NSAssert(UserID   != nil, @"UserID should not be nil");
        NSAssert(domain   != nil, @"domain should not be nil");
        NSAssert(resource != nil, @"Resource should not be nil");
    #endif

    if (self = [super init])
    {
        #pragma mark - init a new Proto User.
        
        ///FIXME:phoneNumber 初始值有待修改
        NSString* phoneNumber = @"";
        
        if (userType == WTProtoUserTypePhoneNumber) {
            phoneNumber = UserID;
        }
        
        
        UIDevice *protoDecive = [UIDevice currentDevice];
        
        NSString *deviceID           = protoDecive.identifierForVendor.UUIDString;
        
        NSString *currentDeviceName  = protoDecive.name;
        NSString *currentAPPVersion  = [NSString stringWithFormat:@"%@",
                                       [[[NSBundle mainBundle] infoDictionary]
                                          objectForKey:@"CFBundleShortVersionString"]];
        
        NSString *currentDeviceOS    = [NSString stringWithFormat:@"%@_%@",
                                       [UIDevice currentDevice].systemName,
                                       [UIDevice currentDevice].systemVersion];

        _protoUser = [[WTProtoUser alloc]initProtoUserWithUserID:UserID
                                                          domain:domain
                                                        resource:resource
                                                        userType:userType
                                                     phoneNumber:phoneNumber
                                                       phoneCode:@"+86"
                                                        password:password
                                                        deviceID:deviceID
                                                     deviceToken:@""
                                                      verifiCode:@""
                                               verifiMsgLanguage:@"en"
                                                     loginSource:resource
                                                   loginAuthType:WTProtoUserLoginAuthTypeCheckUser
                                               currentDeviceName:currentDeviceName
                                               currentAPPVersion:currentAPPVersion
                                                 currentDeviceOS:currentDeviceOS];
        
        #pragma mark - init a new Proto Server Address.
        _serverAddress = [[WTProtoServerAddress alloc]initWithHost:@"im.77877.site" port:35000];
        
        #pragma mark - init a new proto Stream.
        _protoStream = [[WTProtoStream alloc]initWithProtoUser:_protoUser
                                                ServerAddress:_serverAddress
                                               StartTLSPolicy:WTProtoStreamStartTLSPolicyRequired
                                        StreamCompressionMode:WTProtoStreamCompressionBestCompression];
        
        _protoQueue = [WTProto ProtoQueue];
        
        [self ProtoFuctionModuleInitializationWithProtoStream:_protoStream];
    
        [self ProtoFuctionModuleSetDelegate];
    }
    
    return self;
}


-(void)ProtoFuctionModuleInitializationWithProtoStream:(WTProtoStream*)protoStream
{
    #pragma mark - init WTProtoStreamManager to manager stream.
        _proStreamManager = [WTProtoStreamManager shareStreamManagerWithProtoStream:protoStream
                                                                          interface:@"StreamManager"];
        
        #pragma mark - init WTProtoConnection to connection.
        _protoConnection = [WTProtoConnection shareConnecionWithProtoStream:protoStream
                                                                  interface:@"Connection"];
    
        #pragma mark - init WTProtoAuth to auth.
        _protoAuth = [WTProtoAuth shareAuthWithProtoStream:protoStream
                                                 interface:@"Auth"];
    
        
        #pragma mark - init WTProtoRegister to register.
        _protoRegister = [WTProtoRegister shareRegisterWithProtoStream:protoStream
                                                             interface:@"Register"];
        
        #pragma mark - init WTProtoReConnection to reconnection.
        _protoReConnection = [WTProtoReConnection shareReConnecionWithProtoStream:protoStream
                                                                   ReconnectDelay:0.f
                                                           ReconnectTimerInterval:2.0f
                                                                        interface:@"ReConnection"];
        
        #pragma mark - init WTProtoBlock to block user.
        _protoBlock = [WTProtoBlock shareBlockWithProtoStream:protoStream
                                                    interface:@"Block"];
                
        #pragma mark - init WTProtoPing to ping user or server auto/manual.
        _protoPing  = [WTProtoPing sharePingWithProtoStream:protoStream
                                                  interface:@"ping"];
    
        #pragma mark - init WTProtoRosters to manager the proto's roster control.
        _protoRosters = [WTProtoRosters shareRostersWithProtoStream:protoStream
                                                          interface:@"roster"];
        
        #pragma mark - init WTProtoGroup to manager the Group
        _protoGroup   = [WTProtoGroup shareGroupWithProtoStream:protoStream
                                                      interface:@"group"];
        
        #pragma mark - init WTProtoMessageCenter to manager the Message Send & Receive & handle
        _protoMessageCenter = [WTProtoMessageCenter shareMessagerCenterWithProtoStream:protoStream
                                                                             interface:@"messageCenter"];
    
        #pragma mark - init WTProtoContact to manager the Contact
        _protoContact = [WTProtoContact shareContactWithProtoStream:protoStream interface:@"contact"];
}


-(void)ProtoFuctionModuleSetDelegate{
    
    [_proStreamManager   addProtoStreamManagerDelegate:self  delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoConnection    addProtoConnectionDelegate:self     delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoRegister      addProtoRegisterDelegate:self       delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoAuth          addProtoAuthDelegate:self           delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoReConnection  addProtoReConnectionDelegate:self   delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoBlock         addProtoBlockDelegate:self          delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoPing          addProtoPingDelegate:self           delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoRosters       addProtoRostersDelegate:self        delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoGroup         addProtoGroupDelegate:self          delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoMessageCenter addProtoMessageCenterDelegate:self  delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoContact       addProtoContactDelegate:self        delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
    protoMulticasDelegate = (GCDMulticastDelegate <WTProtoDelegate> *)[[GCDMulticastDelegate alloc] init];
    
}


-(void)ProtoResetProtoUserWithUserID:(NSString *)userID
                            password:(NSString *)password
                            UserType:(NSInteger)userType
                       loginAuthType:(NSInteger)loginAuthType
{
    
    NSString* phoneNumber = @"";
    if (userType == WTProtoUserTypePhoneNumber) {
        phoneNumber = userID;
    }
    
    WTProtoUser *newProtoUser = [[WTProtoUser alloc]initProtoUserWithUserID:userID
                                                                     domain:_protoUser.domain
                                                                   resource:_protoUser.resource
                                                                   userType:userType
                                                                phoneNumber:_protoUser.phoneNumber
                                                                  phoneCode:_protoUser.phoneNumber
                                                                   password:password
                                                                   deviceID:_protoUser.deviceID
                                                                deviceToken:_protoUser.deviceToken
                                                                 verifiCode:_protoUser.verifiCode
                                                          verifiMsgLanguage:_protoUser.verifiMsgLanguage
                                                                loginSource:_protoUser.loginSource
                                                              loginAuthType:loginAuthType
                                                          currentDeviceName:_protoUser.currentDeviceName
                                                          currentAPPVersion:_protoUser.currentAPPVersion
                                                            currentDeviceOS:_protoUser.currentDeviceOS];
    _protoUser = newProtoUser;
    
    _protoStream = [[WTProtoStream alloc]initWithProtoUser:_protoUser
                                             ServerAddress:_serverAddress
                                            StartTLSPolicy:WTProtoStreamStartTLSPolicyRequired
                                     StreamCompressionMode:WTProtoStreamCompressionBestCompression];
    
    
//    [self ProtoDellocFuctionModule];
//
//    [self ProtoFuctionModuleInitializationWithProtoStream:_protoStream];
//
//    [self ProtoFuctionModuleSetDelegate];
}

-(void)ProtoDellocFuctionModule{
    
    _proStreamManager    = nil;
    _protoConnection     = nil;
    _protoRegister       = nil;
    _protoAuth           = nil;
    _protoReConnection   = nil;
    _protoBlock          = nil;
    _protoPing           = nil;
    _protoRosters        = nil;
    _protoGroup          = nil;
    _protoMessageCenter  = nil;
    _protoContact        = nil;
    
    [WTProtoStreamManager       dellocSelf];
    [WTProtoConnection          dellocSelf];
    [WTProtoRegister            dellocSelf];
    [WTProtoAuth                dellocSelf];
    [WTProtoReConnection        dellocSelf];
    [WTProtoBlock               dellocSelf];
    [WTProtoPing                dellocSelf];
    [WTProtoRosters             dellocSelf];
    [WTProtoGroup               dellocSelf];
    [WTProtoMessageCenter       dellocSelf];
    [WTProtoContact             dellocSelf];
}


#pragma mark - WTProto MulticasDelegate Add & Remove
- (void)addWTProtoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [_protoQueue dispatchOnQueue:^{

        [self->protoMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}

- (void)removeWTProtoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [_protoQueue dispatchOnQueue:^{

        [self->protoMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}

- (void)removeWTProtoDelegate:(id)delegate
{
    [_protoQueue dispatchOnQueue:^{

        [self->protoMulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
    
}


#pragma mark - Using the protoConnection to Start the TCP/SSL Connection.
-(void)Start
{
    
    [_protoConnection connectWithTimeout:30 error:nil];
}


-(void)Stop
{

    [_protoConnection disconnect];
}

#pragma mark - OnlineState
- (void)ProtoOnlineState:(WTProtoOnlineStatus)onlineStatus
                  status:(NSString *)status
                priority:(WTProtoOnlinePriority)priority
                  device:(NSString *)device
{
    NSUInteger presenceOnlineState      = onlineStatus;
    NSUInteger presenceOnlinepriority   = priority;
    
    WTProtoPresence * presentOnline = [WTProtoOnlinePresent presenceOnlineState:presenceOnlineState
                                                                         status:status
                                                                       priority:presenceOnlinepriority
                                                                         device:device];
    
    [_protoStream sendElement:(XMPPPresence *)presentOnline];
}

#pragma mark - WTProto User Check

- (void)ProtoCheckUser
{

    //Determine which authentication is performed after the TCP connection is successful according to the loginAuthType.
    //若是LoginAuthTypeCheckUser状态类型下userID为JID则直接认SASL证登,否则先验证注册。
    
    NSUInteger LoginAuthTyp = [_protoUser getEnumLoginAuthTyp];
    NSUInteger UserType     = [_protoUser getEnumUserType];
           
    if (LoginAuthTyp == WTProtoUserLoginAuthTypeCheckUser)
    {
        if (UserType == WTProtoUserTypeUserID)
        {
            [_protoAuth authenticateWithError:nil];
        }
        if (UserType == WTProtoUserTypePhoneNumber)
        {
            [_protoRegister checkRegister];
        }
       
    }
    else if (LoginAuthTyp == WTProtoUserLoginAuthTypeGetVerifiCode)
    {
        [_protoAuth authenticateWithError:nil];
    }
    else
    {
        [_protoAuth authenticateWithError:nil];
    }
    
}

#pragma mark - WTProto User Register

- (void)ProtoRegisterUserWithNickName:(NSString *)nickName CountrieName:(NSString *)countrieName{
    
    [_protoUser setNickName:nickName];
    [_protoUser setCountrieName:countrieName];
    [_protoRegister registerWithError:nil];
}



#pragma mark - WTProto User Register & Auth

- (void)ProtoReconnectByResettingStreamUserWithUserID:(NSString *)userID
                                               domain:(NSString *)domain
                                             resource:(NSString *)resource
                                             userType:(WTProtoUserType)userType
                                          phoneNumber:(NSString *)phoneNumber
                                            phoneCode:(NSString *)phoneCode
                                             password:(NSString *)password
                                             deviceID:(NSString *)deviceID
                                          deviceToken:(NSString *)deviceToken
                                           verifiCode:(NSString *)verifiCode
                                    verifiMsgLanguage:(NSString *)verifiMsgLanguage
                                          loginSource:(NSString *)loginSource
                                        loginAuthType:(WTProtoUserLoginAuthType)loginAuthTyp
                                    currentDeviceName:(NSString *)currentDeviceName
                                    currentAPPVersion:(NSString *)currentAPPVersion
                                      currentDeviceOS:(NSString *)currentDeviceOS
{
    [_protoConnection disconnect];
    
    WTProtoUser *newProtoUser = [[WTProtoUser alloc]initProtoUserWithUserID:userID
                                                                     domain:domain
                                                                   resource:resource
                                                                   userType:userType
                                                                phoneNumber:phoneNumber
                                                                  phoneCode:phoneCode
                                                                   password:password
                                                                   deviceID:deviceID
                                                                deviceToken:deviceToken
                                                                 verifiCode:verifiCode
                                                          verifiMsgLanguage:verifiMsgLanguage
                                                                loginSource:loginSource
                                                              loginAuthType:loginAuthTyp
                                                          currentDeviceName:currentDeviceName
                                                          currentAPPVersion:currentAPPVersion
                                                            currentDeviceOS:currentDeviceOS];
    _protoUser = newProtoUser;
    
    [_protoStream resetStreamUser:_protoUser];
               
    [_protoConnection connectWithTimeout:30 error:nil];
    
}




- (void)ProtoGetVerifiCodeWithRegister:(WTProtoRegister *)protoRegister
{
    [self ProtoReconnectByResettingStreamUserWithUserID:[protoRegister.registerUser fullPhoneNumber]
                                                 domain:[protoRegister.registerUser domain]
                                               resource:[protoRegister.registerUser resource]
                                               userType:WTProtoUserTypePhoneNumber
                                            phoneNumber:protoRegister.registerUser.phoneNumber
                                              phoneCode:protoRegister.registerUser.phoneCode
                                               password:protoRegister.registerUser.password
                                               deviceID:protoRegister.registerUser.deviceID
                                            deviceToken:protoRegister.registerUser.deviceToken
                                             verifiCode:protoRegister.registerUser.deviceID
                                      verifiMsgLanguage:protoRegister.registerUser.verifiMsgLanguage
                                            loginSource:protoRegister.registerUser.loginSource
                                          loginAuthType:WTProtoUserLoginAuthTypeGetVerifiCode
                                      currentDeviceName:protoRegister.registerUser.currentDeviceName
                                      currentAPPVersion:protoRegister.registerUser.currentAPPVersion
                                        currentDeviceOS:protoRegister.registerUser.currentDeviceOS
     ];
    
}


- (void)ProtoGotoAuthWithSuccessRegister:(WTProtoRegister *)protoRegister
{
    [self ProtoReconnectByResettingStreamUserWithUserID:protoRegister.registerUser.userID
                                                 domain:[protoRegister.registerUser domain]
                                               resource:[protoRegister.registerUser resource]
                                               userType:WTProtoUserTypeUserID
                                            phoneNumber:protoRegister.registerUser.phoneNumber
                                              phoneCode:protoRegister.registerUser.phoneCode
                                               password:protoRegister.registerUser.password
                                               deviceID:protoRegister.registerUser.deviceID
                                            deviceToken:protoRegister.registerUser.deviceToken
                                             verifiCode:protoRegister.registerUser.verifiCode
                                      verifiMsgLanguage:protoRegister.registerUser.verifiMsgLanguage
                                            loginSource:protoRegister.registerUser.loginSource
                                          loginAuthType:WTProtoUserLoginAuthTypeCheckUser
                                      currentDeviceName:protoRegister.registerUser.currentDeviceName
                                      currentAPPVersion:protoRegister.registerUser.currentAPPVersion
                                        currentDeviceOS:protoRegister.registerUser.currentDeviceOS
     
     ];
}

-(void)ProtoGotoCheckVerifiCodeWithAuth:(WTProtoAuth *)protoAuth VerifiCode:(NSString*)verifiCode
{
    [self ProtoReconnectByResettingStreamUserWithUserID:[protoAuth.authUser fullPhoneNumber]
                                                 domain:[protoAuth.authUser domain]
                                               resource:[protoAuth.authUser resource]
                                               userType:WTProtoUserTypePhoneNumber
                                            phoneNumber:protoAuth.authUser.phoneNumber
                                              phoneCode:protoAuth.authUser.phoneCode
                                               password:protoAuth.authUser.password
                                               deviceID:protoAuth.authUser.deviceID
                                            deviceToken:protoAuth.authUser.deviceToken
                                             verifiCode:verifiCode
                                      verifiMsgLanguage:protoAuth.authUser.verifiMsgLanguage
                                            loginSource:protoAuth.authUser.loginSource
                                          loginAuthType:WTProtoUserLoginAuthTypeCheckVerifiCode
                                      currentDeviceName:protoAuth.authUser.currentDeviceName
                                      currentAPPVersion:protoAuth.authUser.currentAPPVersion
                                        currentDeviceOS:protoAuth.authUser.currentDeviceOS
     ];
}


-(void)ProtoGotoAuthWithSuccessCheckVerifiCod:(WTProtoAuth *)protoAuth UserInfoMessage:(NSString*)userInfoMessage{
    
    
    NSString * jidStr   = [[userInfoMessage  componentsSeparatedByString:@" == "] firstObject];
    NSString * userID   = [[jidStr        componentsSeparatedByString:@"@"]    firstObject];
    NSString * password = [[userInfoMessage  componentsSeparatedByString:@" == "] lastObject];
    
    [self ProtoReconnectByResettingStreamUserWithUserID:userID
                                                 domain:[protoAuth.authUser domain]
                                               resource:[protoAuth.authUser resource]
                                               userType:WTProtoUserTypeUserID
                                            phoneNumber:protoAuth.authUser.phoneNumber
                                              phoneCode:protoAuth.authUser.phoneCode
                                               password:password
                                               deviceID:protoAuth.authUser.deviceID
                                            deviceToken:protoAuth.authUser.deviceToken
                                             verifiCode:protoAuth.authUser.verifiCode
                                      verifiMsgLanguage:protoAuth.authUser.verifiMsgLanguage
                                            loginSource:protoAuth.authUser.loginSource
                                          loginAuthType:WTProtoUserLoginAuthTypeCheckUser
                                      currentDeviceName:protoAuth.authUser.currentDeviceName
                                      currentAPPVersion:protoAuth.authUser.currentAPPVersion
                                        currentDeviceOS:protoAuth.authUser.currentDeviceOS
     ];
    
}


#pragma mark WTProto Send Kinds of Message
-(void)sendWTProtoConversationMessage:(WTProtoConversationMessage *)message
                       encryptionType:(WTProtoMessageEncryptionType)encryptionType
                           sendResult:(nonnull void (^)(BOOL, WTProtoConversationMessage * _Nonnull))sendResult
{
    
    NSUInteger messageEncryptionType = encryptionType;
    
    [_protoMessageCenter sendConversationMessage:message
                                  encryptionType:messageEncryptionType
                                      sendResult:^(BOOL succeed, WTProtoConversationMessage * _Nonnull sendmessage)
    {
        sendResult(succeed,sendmessage);
    }];
}

-(void)sendWTProtoWebRTCMessage:(WTProtoWebRTCMessage *)message
                 encryptionType:(WTProtoMessageEncryptionType)encryptionType
                     sendResult:(void (^)(BOOL succeed, WTProtoWebRTCMessage * _Nonnull))sendResult
{
    
    NSUInteger messageEncryptionType = encryptionType;
       
    [_protoMessageCenter sendWebRTCMessage:message
                            encryptionType:messageEncryptionType
                                sendResult:^(BOOL succeed, WTProtoWebRTCMessage * _Nonnull sendmessage)
    {
        sendResult(succeed,sendmessage);
    }];
}


-(void)sendWTProtoShakeMessage:(WTProtoShakeMessage *)message
                 encryptionType:(WTProtoMessageEncryptionType)encryptionType
                     sendResult:(void (^)(BOOL succeed, WTProtoShakeMessage * _Nonnull))sendResult
{
    
    NSUInteger messageEncryptionType = encryptionType;
           
    [_protoMessageCenter sendShakeMessage:message
                           encryptionType:messageEncryptionType
                               sendResult:^(BOOL succeed, WTProtoShakeMessage * _Nonnull sendmessage)
    {
        sendResult(succeed,sendmessage);
    }];
    
}


-(void)sendWTProtoShakeResultMessage:(WTProtoshakedResultMessage *)message
                      encryptionType:(WTProtoMessageEncryptionType)encryptionType
                          sendResult:(void (^)(BOOL succeed, WTProtoshakedResultMessage * _Nonnull))sendResult
{
    
    NSUInteger messageEncryptionType = encryptionType;
           
    [_protoMessageCenter sendShakeResultMessage:message
                                 encryptionType:messageEncryptionType
                                     sendResult:^(BOOL succeed, WTProtoshakedResultMessage * _Nonnull sendmessage)
    {
        sendResult(succeed,sendmessage);
    }];
    
}



#pragma mark - WTProtoContact Method
- (void)getContactsWithMatchableContacts:(NSArray *)matchableContacts phoneCode:(NSString *)phoneCode type:(NSString *)emptyType nickName:(NSString *)nickName userPhone:(NSString *)userPhone{
    
    [_protoContact IQ_GetContactsByFromUser:_protoUser matchableContacts:matchableContacts phoneCode:phoneCode type:emptyType nickName:nickName userPhone:userPhone];
}

- (void)getUserDetailWithKeyWord:(NSString *)key keyType:(WTGetContactDetailsKeyType)type searchFromGroup:(BOOL)fromGroup source:(NSString *)source IPAddress:(NSString *)IPAddress{
    [_protoContact IQ_GetUserDetailWithKeyWord:key keyType:(NSInteger)type searchFromGroup:fromGroup source:source IPAddress:IPAddress fromUser:_protoUser];
}

- (void)setFriend_MemoName:(NSString *)memoName jid:(NSString *)jidstr{
    [_protoContact IQ_SetFriend_MemoName:memoName jid:jidstr fromUser:_protoUser];
}

- (void)setFriend_StarMarkWithJid:(NSString *)jidstr straState:(BOOL)state{
    [_protoContact IQ_SetFriend_StarMarkWithJid:jidstr straState:YES fromUser:_protoUser];
}

-(void)deleteFriendWithJid:(NSString *)jidStr{
    [_protoContact deleteFriendWithJid:jidStr];
}

-(void)addFriendWithJid:(NSString *)jidStr source:(NSString *)source verify:(NSString *)verify time:(NSString *)time statusInfo:(NSDictionary *)statusInfo{
    [_protoContact addFriendWithJid:jidStr source:source verify:verify time:time statusInfo:statusInfo fromUser:_protoUser];
}

#pragma mark Proto Ack/ReadAck Message
- (void)Ack:(XMPPMessage*)message
{
    [_protoMessageCenter ack:message];
}

- (void)ReadAckToID:(NSString *)toID IncrementID:(NSInteger)incrementID
{
    [_protoMessageCenter readAckToID:toID incrementID:incrementID];
}


#pragma mark - WTProtoConnection delegate - Connection State

-(void)WTProtoConnection:(WTProtoConnection *)protoConnection connectState:(WTProtoConnectStatus)connectState                                                                       withError:(NSError *)error
{
        
    switch (connectState) {
        
        case WTProtoConnectStatusConnecting:
            
            NSLog(@"****** waterIM tcp connecting ******");
            [protoMulticasDelegate WTProtoConnecting:self];
            
            break;
            
        case WTProtoConnectStatusConnected:
            
            NSLog(@"****** waterIM tcp connected ******");
            [protoMulticasDelegate WTProtoConnected:self];
            
            break;
            
        case WTProtoConnectStatusDisconnected:
            
            NSLog(@"****** waterIM tcp disconnected ******");
            [protoMulticasDelegate WTProtoDisconnected:self Error:error];
            
            break;
            
        case WTProtoConnectStatusConnectTimeout:
            
            NSLog(@"****** waterIM tcp connect time out ******");
            [protoMulticasDelegate WTProtoConnectTimeout:self];
            
            break;
            
        case WTProtoConnectStatusConnectFailed:
            
            [protoMulticasDelegate WTProtoConnectFailed:self Error:error];
            NSLog(@"****** waterIM tcp connect failed ******");
            
            break;
            
        default:
            break;
    }
    
}


#pragma mark - WTProtoRegister delegate - Register Status

-(void)WTProtoRegister:(WTProtoRegister *)protoRegister RegisterStatus:(WTProtoUserRegisterStatus)registerStatus                                                                 withError:(NSError *)error
{
    switch (registerStatus) {
            
        case WTProtoUserRegisterCheck:
            
            NSLog(@"****** waterIM user register check ******");
            [protoMulticasDelegate WTProtoUserRegisterCheck:self];
            
            break;
            
        case WTProtoUserRegisterStart:
            
            NSLog(@"****** waterIM user register start ******");
            [protoMulticasDelegate WTProtoUserRegisterStart:self];

            
            break;
            
        case WTProtoUserRegisterAlready:
            
            NSLog(@"****** waterIM user register already ******");
            
            //如果该手机用户已经注册，则通过手机号码获取验证码进行验证。
            [self ProtoGetVerifiCodeWithRegister:protoRegister];
            
            [protoMulticasDelegate WTProtoUserRegisterAlready:self];
            
            break;
        case WTProtoUserRegisterNone:
            
            //如果该手机用户没有注册，则进行注册。
            NSLog(@"****** waterIM user register none ******");
            
//           [self ProtoRegisterUserWithNickName:@"VilsonTestMTPT" CountrieName:@"China"];
            [protoMulticasDelegate WTProtoUserRegisterNone:self];
            
            break;
            
        case WTProtoUserRegisterSuccess:
            
            NSLog(@"****** waterIM User register success ******");
            
            //如果该手机号码注册成功，则直接登录。
            [self ProtoGotoAuthWithSuccessRegister:protoRegister];
            [protoMulticasDelegate WTProtoUserRegisterSuccess:self];
            
            break;
            
        case WTProtoUserRegisterFail:
            
            NSLog(@"****** waterIM user register fairl ******");
            [protoMulticasDelegate WTProtoUserRegisterFail:self Error:error];
            
            break;
        default:
            break;
    }
}


#pragma mark - WTProtoAuth delegate - Authenticate State

-(void)WTProtoAuth:(WTProtoAuth *)protoAuth AuthenticateState:(WTProtoUserAuthStatus)authenticateState
                                                    withError:(NSError *)error
{
    switch (authenticateState) {
            
        case WTProtoUserAuthenticatStart:
    
            NSLog(@"****** waterIM user authenticat start ******");
            [protoMulticasDelegate WTProtoUserAuthenticatStart:self];
            
            break;
            
        case WTProtoUserAuthenticated:
            
            NSLog(@"****** waterIM user authenticated ******");
            [protoMulticasDelegate WTProtoUserAuthenticated:self];
            
            break;
            
        case WTProtoUserAuthenticateFail:
            
            NSLog(@"****** waterIM user authenticate fail ******");
            [protoMulticasDelegate WTProtoUserAuthenticateFail:self Error:error];
            
            break;
            
        case WTProtoUserAuthenticatGetVerifiCodeSuccess:
            
            NSLog(@"****** waterIM user authenticat get verifiCode success ******");
            [protoMulticasDelegate WTProto:self UserAuthenticatGetVerifiCodeSuccess:protoAuth];
            
//            [self WTProtoGotoCheckVerifiCodeWithAuth:protoAuth VerifiCode:@"888888"];
            
            break;
            
        case WTProtoUserAuthenticatGetVerifiCodeFail:
            
            NSLog(@"****** waterIM user authenticat get VerifiCode fail ******");
            [protoMulticasDelegate WTProto:self UserAuthenticatGetVerifiCodeFail:protoAuth Error:error];
            
            break;
            
        case WTProtoUserAuthenticatGetVerifiCodeSeclimit:
            
            NSLog(@"****** waterIM user authenticat get VerifiCode seclimit ******");
            [protoMulticasDelegate WTProto:self UserAuthenticatGetVerifiCodeSeclimit:protoAuth];
            
            break;
            
        case WTProtoUserAuthenticatGetVerifiCodeDaylimit:
            
            NSLog(@"****** waterIM user authenticat get verifiCode daylimit ******");
            [protoMulticasDelegate WTProto:self UserAuthenticatGetVerifiCodeDaylimit:protoAuth];
            
            break;
            
        case WTProtoUserAuthenticatGetVerifiCodeNoTFound:
            
            NSLog(@"****** waterIM user authenticat get verifiCode not found ******");
            [protoMulticasDelegate WTProto:self UserAuthenticatGetVerifiCodeNoTFound:protoAuth];
            
            break;
            
        case WTProtoUserAuthenticatGetVerifiCodeError:
            
            NSLog(@"****** waterIM user authenticat get verifiCode error ******");
            [protoMulticasDelegate WTProto:self UserAuthenticatGetVerifiCodeError:protoAuth];
            
            break;
            
        case WTProtoUserAuthenticatCheckVerifiCodeSuccess:
    
            NSLog(@"****** waterIM user authenticat check verifiCode success ******");
            
            //验证验证码成功后拿取返回的最终UserID及password 登录
            
            [self ProtoGotoAuthWithSuccessCheckVerifiCod:protoAuth
                                        UserInfoMessage:[[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
            
            [protoMulticasDelegate WTProtoUserAuthenticatCheckVerifiCodeSuccess:self];
            
            break;
            
        case WTProtoUserAuthenticatCheckVerifiCodeExpire:
            
            NSLog(@"****** waterIM user authenticat Check VerifiCode expire ******");
            [protoMulticasDelegate WTProtoUserAuthenticatCheckVerifiCodeExpire:self];
            
            break;
        
        case WTProtoUserAuthenticatCheckVerifiCodeFail:
            
            NSLog(@"****** waterIM user authenticat check verifiCode fail ******");
            [protoMulticasDelegate WTProtoUserAuthenticatCheckVerifiCodeFail:self Error:error];
            
            break;
        
        case WTProtoUserAuthenticatCheckVerifiCodeNotFound:
            
            NSLog(@"****** waterIM user authenticat check verifiCode not found ******");
            [protoMulticasDelegate WTProtoUserAuthenticatCheckVerifiCodeNotFound:self];
            
            break;
            
        case WTProtoUserAuthenticatCheckVerifiCodeUpdateError:
            
            NSLog(@"****** waterIM user authenticat check verifiCode update error ******");
            [protoMulticasDelegate WTProtoUserAuthenticatCheckVerifiCodeUpdateError:self];
            
            break;
            
        case WTProtoUserAuthenticatCheckUserNotFound:
            
            NSLog(@"****** waterIM user authenticat Check user not found ******");
            [protoMulticasDelegate WTProtoUserAuthenticatCheckUserNotFound:self];
            
            break;
            
        case WTProtoUserAuthenticatCheckUnsupportedMechanism:
            
            NSLog(@"****** waterIM user authenticat check unsupported mechanism ******");
            [protoMulticasDelegate WTProtoUserAuthenticatCheckUnsupportedMechanism:self];
            
            break;
            
        case WTProtoUserAuthenticateNeedUpgrade:
            
            NSLog(@"****** waterIM user authenticate need upgrade ******");
            [protoMulticasDelegate WTProtoUserAuthenticateNeedUpgrade:self];
            
            break;
            
        case WTProtoUserAuthenticateNeedVerifiCode:
            
            NSLog(@"****** waterIM user authenticate need verifiCode ******");
            [protoMulticasDelegate WTProtoUserAuthenticateNeedVerifiCode:self];
            
            break;
            
        case WTProtoUserAuthenticateInvalidUser:
            
            NSLog(@"****** waterIM user authenticate invalid user ******");
            [protoMulticasDelegate WTProtoUserAuthenticateInvalidUser:self];
            
            break;
        
        default:
            break;
    }
    
    
}

#pragma mark - WTProtoMessageCenter Delegate - Receive Message
- (void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter
    didReceiveConversationDecryptMessage:(WTProtoConversationMessage *)decryptMessage
                         OriginalMessage:(XMPPMessage *)originalMessage
{
    [protoMulticasDelegate WTProto:self didReceiveConversationDecryptMessage:decryptMessage
                                                 OriginalMessage:originalMessage];
}


-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter
    didReceiveWebRTCDecryptMessage:(nonnull WTProtoWebRTCMessage *)decryptMessage
                   OriginalMessage:(nonnull XMPPMessage *)originalMessage
{
    [protoMulticasDelegate WTProto:self didReceiveWebRTCDecryptMessage:decryptMessage
                                                       OriginalMessage:originalMessage];
}


-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter didReceiveShakeDecryptMessage:(WTProtoShakeMessage *)decryptMessage
                  OriginalMessage:(XMPPMessage *)originalMessage
{
    [protoMulticasDelegate WTProto:self didReceiveShakeDecryptMessage:decryptMessage
                                        OriginalMessage:originalMessage];
}


-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter didReceiveShakeResultDecryptMessage:(WTProtoshakedResultMessage *)decryptMessage
                        OriginalMessage:(XMPPMessage *)originalMessage
{
    
     [protoMulticasDelegate WTProto:self didReceiveShakeResultDecryptMessage:decryptMessage OriginalMessage:originalMessage];
}

#pragma mark - WTProtoContact Delegate
- (void)WTProtoContact:(WTProtoContact *)protoContact getContacts_ResultWithSucceed:(BOOL)succeed matchcount:(NSUInteger)matchcount info:(id)info{
   
    [protoMulticasDelegate WTProto:self getContacts_ResultWithSucceed:succeed matchcount:matchcount info:info];
}

- (void)WTProtoContact:(WTProtoContact *)protoContact getContactDetails_ResultWithSucceed:(BOOL)succeed info:(id)info{
    [protoMulticasDelegate WTProto:self getContactDetails_ResultWithSucceed:succeed info:info];
}

- (void)WTProtoContact:(WTProtoContact *)protoContact setFriend_MemoName_ResultWithSucceed:(BOOL)succeed info:(id)info{
    
    [protoMulticasDelegate WTProto:self setFriend_MemoName_ResultWithSucceed:succeed info:info];
}

- (void)WTProtoContact:(WTProtoContact *)protoContact setFriend_StarMark_ResultWithSucceed:(BOOL)succeed info:(id)info{
    [protoMulticasDelegate WTProto:self setFriend_StarMark_ResultWithSucceed:succeed info:info];
}

- (BOOL)WTProtoContact:(WTProtoContact *)protoContact isExistFriendJid:(NSString *)jid{
    return [protoMulticasDelegate WTProto:self isExistFriendJid:jid];
}

- (void)WTProtoContact:(WTProtoContact *)protoContact addFriend_ResultWithSucceed:(BOOL)succeed jid:(NSString *)jid{
    [protoMulticasDelegate WTProto:self addFriend_ResultWithSucceed:succeed jid:jid];
}

- (void)WTProtoContact:(WTProtoContact *)protoContact deleteFriend_ResultWithSucceed:(BOOL)succeed jid:(NSString *)jid{
    [protoMulticasDelegate WTProto:self deleteFriend_ResultWithSucceed:succeed jid:jid];
}

@end
