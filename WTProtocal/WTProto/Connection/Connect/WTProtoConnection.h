//
//  WTProtoConnection.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/1.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoServerAddress;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, WTProtoConnectStatus) {
    
    WTProtoConnectStatusConnecting      = 0,
    WTProtoConnectStatusConnected,
    WTProtoConnectStatusDisconnected,
    WTProtoConnectStatusConnectTimeout,
    WTProtoConnectStatusConnectFailed
    
};


@class WTProtoConnection;

@protocol WTProtoConnectionDelegate

@optional

-(void)WTProtoConnection:(WTProtoConnection* )protoConnection
            connectState:(WTProtoConnectStatus)connectState
               withError:(nullable NSError *)error;

@end


@interface WTProtoConnection : NSObject

@property (nonatomic, strong, readonly)WTProtoStream* connectStream;

@property (nonatomic, strong, readonly)WTProtoUser* connectUser;

@property (nonatomic, strong, readonly)WTProtoServerAddress* serverAddress;

+ (WTProtoQueue *)tcpQueue;


+ (WTProtoConnection *)shareConnecionWithProtoStream:(WTProtoStream *)protoStream
                                           interface:(NSString *)interface;


- (BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError **)error;
- (void)disconnect;
- (void)resetConnectionStream:(WTProtoStream*)protoStream;


- (void)addProtoConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoConnectionDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
