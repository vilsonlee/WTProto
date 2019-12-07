//
//  WTProto.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/10/31.
//  Copyright © 2019 Vilson. All rights reserved.
//

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
                       WTProtoMessageCenterDelegate
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
}

@end


@implementation WTProto


+ (WTProtoQueue *)ProtoQueue
{
    static WTProtoQueue *protoQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        protoQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue"];
    });
    return protoQueue;
}


+ (WTProto *)shareWTProtoUserID:(NSString *)UserID
                         Domain:(NSString *)domain
                       Resource:(NSString *)resource
                       Password:(NSString *)password
{
    
    
    static WTProto *proto = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        proto = [[WTProto alloc]initMTProtoWithUserID:UserID
                                               Domain:domain
                                             Resource:resource
                                             Password:password];
        
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return proto;
    
    
    
}


-(instancetype)initMTProtoWithUserID:(NSString *)UserID
                              Domain:(NSString *)domain
                            Resource:(NSString *)resource
                            Password:(NSString *)password

{
    
    #ifdef DEBUG
        NSAssert(UserID   != nil, @"UserID should not be nil");
        NSAssert(domain   != nil, @"domain should not be nil");
        NSAssert(resource != nil, @"Resource should not be nil");
    #endif

    if (self = [super init])
    {
        #pragma mark - init a new Proto User.
        _protoUser = [[WTProtoUser alloc]initProtoUserWithUserID:UserID
                                                          domain:domain
                                                        resource:resource
                                                        userType:WTProtoUserTypePhoneNumber
                                                     phoneNumber:@"13434386688"
                                                        password:password
                                                        deviceID:@"3a6c35d4c1c2b88fbfd9c37ed2adbfd9bca35f58"
                                                      verifiCode:@""
                                               verifiMsgLanguage:@"en"
                                                     loginSource:resource
                                                   loginAuthType:WTProtoUserLoginAuthTypeCheckUser];

        [_protoUser setPhoneCode:@"+86"];
        
        
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
    
    protoMulticasDelegate = (GCDMulticastDelegate <WTProtoDelegate> *)[[GCDMulticastDelegate alloc] init];
    
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


-(void)Start{
    
    #pragma mark - Using the protoConnection to Start the TCP/SSL Connection.
    [_protoConnection connectWithTimeout:30 error:nil];
}


-(void)Stop{

    [_protoConnection disconnect];
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
                                               password:(NSString *)password
                                               deviceID:(NSString *)deviceID
                                             verifiCode:(NSString *)verifiCode
                                      verifiMsgLanguage:(NSString *)verifiMsgLanguage
                                            loginSource:(NSString *)loginSource
                                          loginAuthType:(WTProtoUserLoginAuthType)loginAuthTyp
{
    [_protoConnection disconnect];
    
    WTProtoUser *newProtoUser = [[WTProtoUser alloc]initProtoUserWithUserID:userID
                                                                     domain:domain
                                                                   resource:resource
                                                                   userType:userType
                                                                phoneNumber:phoneNumber
                                                                   password:password
                                                                   deviceID:deviceID
                                                                 verifiCode:verifiCode
                                                          verifiMsgLanguage:verifiMsgLanguage
                                                                loginSource:loginSource
                                                              loginAuthType:loginAuthTyp];
    
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
                                                 password:protoRegister.registerUser.password
                                                 deviceID:protoRegister.registerUser.deviceID
                                               verifiCode:protoRegister.registerUser.deviceID
                                        verifiMsgLanguage:protoRegister.registerUser.verifiMsgLanguage
                                              loginSource:protoRegister.registerUser.loginSource
                                            loginAuthType:WTProtoUserLoginAuthTypeGetVerifiCode];
    
}


- (void)ProtoGotoAuthWithSuccessRegister:(WTProtoRegister *)protoRegister
{
    [self ProtoReconnectByResettingStreamUserWithUserID:protoRegister.registerUser.userID
                                                   domain:[protoRegister.registerUser domain]
                                                 resource:[protoRegister.registerUser resource]
                                                 userType:WTProtoUserTypeUserID
                                              phoneNumber:protoRegister.registerUser.phoneNumber
                                                 password:protoRegister.registerUser.password
                                                 deviceID:protoRegister.registerUser.deviceID
                                               verifiCode:protoRegister.registerUser.verifiCode
                                        verifiMsgLanguage:protoRegister.registerUser.verifiMsgLanguage
                                              loginSource:protoRegister.registerUser.loginSource
                                            loginAuthType:WTProtoUserLoginAuthTypeCheckUser];
}

-(void)ProtoGotoCheckVerifiCodeWithAuth:(WTProtoAuth *)protoAuth VerifiCode:(NSString*)verifiCode
{
    [self ProtoReconnectByResettingStreamUserWithUserID:[protoAuth.authUser fullPhoneNumber]
                                                   domain:[protoAuth.authUser domain]
                                                 resource:[protoAuth.authUser resource]
                                                 userType:WTProtoUserTypePhoneNumber
                                              phoneNumber:protoAuth.authUser.phoneNumber
                                                 password:protoAuth.authUser.password
                                                 deviceID:protoAuth.authUser.deviceID
                                               verifiCode:verifiCode
                                        verifiMsgLanguage:protoAuth.authUser.verifiMsgLanguage
                                              loginSource:protoAuth.authUser.loginSource
                                            loginAuthType:WTProtoUserLoginAuthTypeCheckVerifiCode];
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
                                                 password:password
                                                 deviceID:protoAuth.authUser.deviceID
                                               verifiCode:protoAuth.authUser.verifiCode
                                        verifiMsgLanguage:protoAuth.authUser.verifiMsgLanguage
                                              loginSource:protoAuth.authUser.loginSource
                                            loginAuthType:WTProtoUserLoginAuthTypeCheckUser];
    
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
            
//            [self WTProtoCheckUser];
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



@end