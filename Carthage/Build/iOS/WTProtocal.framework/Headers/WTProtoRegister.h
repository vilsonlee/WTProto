//
//  WTProtoRegister.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoRegister;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoQueue;
@class WTProtoServerAddress;

typedef NS_ENUM(NSUInteger, WTProtoUserRegisterStatus) {
    
    WTProtoUserRegisterCheck      = 0,
    WTProtoUserRegisterStart,
    WTProtoUserRegisterAlready,
    WTProtoUserRegisterNone,
    WTProtoUserRegisterSuccess,
    WTProtoUserRegisterFail,

};


NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoRegisterDelegate

@optional

-(void)WTProtoRegister:(WTProtoRegister *)protoRegister RegisterStatus:(WTProtoUserRegisterStatus)registerStatus
                                                             withError:(nullable NSError *)error;

@end


@interface WTProtoRegister : NSObject

@property (nonatomic, strong, readonly)WTProtoStream* registerStream;

@property (nonatomic, strong, readonly)WTProtoUser* registerUser;

@property (nonatomic, strong, readonly)WTProtoServerAddress* serverAddress;


+ (WTProtoRegister *)shareRegisterWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface;


- (BOOL)registerWithError:(NSError **)errPtr;
- (BOOL)checkRegister;

- (void)resetRegisterStream:(WTProtoStream*)protoStream;


- (void)addProtoRegisterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoRegisterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoRegisterDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
