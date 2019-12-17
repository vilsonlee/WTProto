//
//  WTProtoAuth.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoAuth;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoQueue;
@class WTProtoServerAddress;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WTProtoUserAuthStatus) {
    
    WTProtoUserAuthenticatStart                             =  0,
    
    WTProtoUserAuthenticatGetVerifiCodeSuccess,
    WTProtoUserAuthenticatGetVerifiCodeSeclimit,
    WTProtoUserAuthenticatGetVerifiCodeDaylimit,
    WTProtoUserAuthenticatGetVerifiCodeNoTFound,
    WTProtoUserAuthenticatGetVerifiCodeError,
    WTProtoUserAuthenticatGetVerifiCodeFail,
    
    WTProtoUserAuthenticatCheckVerifiCodeSuccess,
    WTProtoUserAuthenticatCheckVerifiCodeExpire,
    WTProtoUserAuthenticatCheckVerifiCodeFail,
    WTProtoUserAuthenticatCheckVerifiCodeNotFound,
    WTProtoUserAuthenticatCheckVerifiCodeUpdateError,
    
    WTProtoUserAuthenticatCheckUserNotFound,
    WTProtoUserAuthenticatCheckUnsupportedMechanism,
    
    WTProtoUserAuthenticateNeedUpgrade,
    WTProtoUserAuthenticateNeedVerifiCode,
    WTProtoUserAuthenticateInvalidUser,
    
    WTProtoUserAuthenticated,
    WTProtoUserAuthenticateFail
};

@protocol WTProtoAuthDelegate

@optional

-(void)WTProtoAuth:(WTProtoAuth *)protoAuth AuthenticateState:(WTProtoUserAuthStatus)authenticateState
                                                    withError:(nullable NSError *)error;

@end

@interface WTProtoAuth : NSObject

@property (nonatomic, strong, readonly)WTProtoStream* authStream;

@property (nonatomic, strong, readonly)WTProtoUser* authUser;

@property (nonatomic, strong, readonly)WTProtoServerAddress* serverAddress;


+ (void)dellocSelf;

+ (WTProtoQueue *)authQueue;


+ (WTProtoAuth *)shareAuthWithProtoStream:(WTProtoStream *)protoStream
                                interface:(NSString *)interface;

- (BOOL)authenticateWithError:(NSError **)errPtr;

- (void)resetAuthStream:(WTProtoStream*)protoStream;

- (void)addProtoAuthDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoAuthDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoAuthDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
