//
//  WTProto.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/10/31.
//  Copyright © 2019 Vilson. All rights reserved.
//

/**
 * WTProtocol re-encapsulates the XMPP communication protocol based on XMPPFramework.
 * WTProto is the most core class that manager the all the XMPP communication.
**/


#import <Foundation/Foundation.h>

@class WTProto;
@class WTProtoLogging;
@class WTProtoQueue;
@class WTProtoUser;
@class WTProtoStream;
@class WTProtoStreamManager;
@class WTProtoServerAddress;
@class WTProtoConnection;
@class WTProtoRegister;
@class WTProtoAuth;
@class WTProtoReConnection;
@class WTProtoBlock;
@class WTProtoPing;
@class WTProtoRosters;
@class WTProtoGroup;
@class WTProtoMessageCenter;


NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoDelegate

@optional

#pragma mark - WTProto Connection
- (void)WTProtoConnecting:(WTProto* )wtProto;
- (void)WTProtoConnected:(WTProto* )wtProto;
- (void)WTProtoDisconnected:(WTProto* )wtProto Error:(NSError *)error;
- (void)WTProtoConnectTimeout:(WTProto* )wtProto;
- (void)WTProtoConnectFailed:(WTProto* )wtProto Error:(NSError *)error;


#pragma mark - WTProto Register
- (void)WTProtoUserRegisterCheck:(WTProto* )wtProto;
- (void)WTProtoUserRegisterStart:(WTProto* )wtProto;
- (void)WTProtoUserRegisterAlready:(WTProto* )wtProto;
- (void)WTProtoUserRegisterNone:(WTProto* )wtProto;
- (void)WTProtoUserRegisterSuccess:(WTProto* )wtProto;
- (void)WTProtoUserRegisterFail:(WTProto* )wtProto Error:(NSError *)error;


#pragma mark - WTProto Authenticat
- (void)WTProtoUserAuthenticatStart:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticated:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticateFail:(WTProto* )wtProto Error:(NSError *)error;


#pragma mark - WTProto Authenticat Get Verifi Code
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeSuccess:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeFail:(WTProtoAuth* )protoAuth
                                                              Error:(NSError *)error;

- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeSeclimit:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeDaylimit:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeNoTFound:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeError:(WTProtoAuth* )protoAuth;


#pragma mark - WTProto Authenticat Check Verifi Code
- (void)WTProtoUserAuthenticatCheckVerifiCodeSuccess:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckVerifiCodeExpire:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckVerifiCodeFail:(WTProto* )wtProto Error:(NSError *)error;;
- (void)WTProtoUserAuthenticatCheckVerifiCodeNotFound:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckVerifiCodeUpdateError:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckUserNotFound:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckUnsupportedMechanism:(WTProto* )wtProto;

#pragma mark - WTProto Authenticat Need
- (void)WTProtoUserAuthenticateNeedUpgrade:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticateNeedVerifiCode:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticateInvalidUser:(WTProto* )wtProto;



@end


@interface WTProto : NSObject

@property (nonatomic, strong, readonly)WTProtoUser              *protoUser;
@property (nonatomic, strong, readonly)WTProtoStream            *protoStream;
@property (nonatomic, strong, readonly)WTProtoServerAddress     *serverAddress;
@property (nonatomic, strong, readonly)WTProtoStreamManager     *proStreamManager;
@property (nonatomic, strong, readonly)WTProtoConnection        *protoConnection;
@property (nonatomic, strong, readonly)WTProtoRegister          *protoRegister;
@property (nonatomic, strong, readonly)WTProtoAuth              *protoAuth;
@property (nonatomic, strong, readonly)WTProtoReConnection      *protoReConnection;
@property (nonatomic, strong, readonly)WTProtoBlock             *protoBlock;
@property (nonatomic, strong, readonly)WTProtoPing              *protoPing;
@property (nonatomic, strong, readonly)WTProtoRosters           *protoRosters;
@property (nonatomic, strong, readonly)WTProtoGroup             *protoGroup;
@property (nonatomic, strong, readonly)WTProtoMessageCenter     *protoMessageCenter;


+ (void)dellocSelf;

+ (WTProtoQueue *)ProtoQueue;


+ (WTProto *)shareWTProtoDomain:(NSString *)domain Resource:(NSString *)resource;


+ (WTProto *)shareWTProtoPhoneNumber:(NSString *)phoneNumber
                              Domain:(NSString *)domain
                            Resource:(NSString *)resource;


+ (WTProto *)shareWTProtoUserID:(NSString *)UserID
                         Domain:(NSString *)domain
                       Resource:(NSString *)resource
                       Password:(NSString *)password;


-(void)ProtoResetProtoUserWithUserID:(NSString *)userID
                            password:(NSString *)password
                            UserType:(NSInteger)userType
                       loginAuthType:(NSInteger)loginAuthType;


- (void)addWTProtoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeWTProtoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeWTProtoDelegate:(id)delegate;



- (void)Start;

- (void)Stop;

- (void)ProtoCheckUser;

- (void)ProtoRegisterUserWithNickName:(NSString *)nickName CountrieName:(NSString *)countrieName;

- (void)ProtoGetVerifiCodeWithRegister:(WTProtoRegister *)protoRegister;

- (void)ProtoGotoCheckVerifiCodeWithAuth:(WTProtoAuth *)protoAuth VerifiCode:(NSString*)verifiCode;

- (void)ProtoDellocFuctionModule;
@end

NS_ASSUME_NONNULL_END
