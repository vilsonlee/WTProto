//
//  WTProtoPing.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoPing;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoAutoPing;
@class WTProtoManualPing;


NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoPingDelegate

@optional

//FIXME:This protocol is written when needed.

@end


@interface WTProtoPing : NSObject

@property (nonatomic, strong, readonly)WTProtoStream     *pingStream;
@property (nonatomic, strong, readonly)WTProtoAutoPing   *protoAutoPing;
@property (nonatomic, strong, readonly)WTProtoManualPing *protoManualPing;

/**
 * How often to send a ping.
 *
 * The internal timer fires every (pingInterval / 4) seconds.
 * Upon firing it checks when data was last received from the target,
 * and sends a ping if the elapsed time has exceeded the pingInterval.
 * Thus the effective resolution of the timer is based on the configured interval.
 *
 * To temporarily disable auto-ping, set the interval to zero.
 *
 * The default pingInterval is 60 seconds.
**/
@property (nonatomic, readwrite) NSTimeInterval pingInterval;

/**
 * How long to wait after sending a ping before timing out.
 *
 * The timeout is decoupled from the pingInterval to allow for longer pingIntervals,
 * which avoids flooding the network, and to allow more precise control overall.
 *
 * After a ping is sent, if a reply is not received by this timeout,
 * the delegate method is invoked.
 *
 * The default pingTimeout is 10 seconds.
**/
@property (nonatomic, readwrite) NSTimeInterval pingTimeout;

/**
 * The target to send pings to.
 *
 * If the targetJID is nil, this implies the target is the xmpp server we're connected to.
 * In this case, receiving any data means we've received data from the target.
 *
 * If the targetJID is non-nil, it must be a full JID (user@domain.tld/rsrc).
 * In this case, the module will monitor the stream for data from the given JID.
 *
 * The default targetJID is nil.
**/
@property (nonatomic, readwrite, strong) WTProtoUser *targetUser;

/**
 * Corresponds to the last time data was received from the target.
 * The NSTimeInterval value comes from [NSDate timeIntervalSinceReferenceDate]
**/
@property (readonly) NSTimeInterval lastReceiveTime;

/**
 * XMPPAutoPing is used to automatically send pings on a regular interval.
 * Sometimes the target is also sending pings to us as well.
 * If so, you may optionally set respondsToQueries to YES to allow the module to respond to incoming pings.
 *
 * If you create multiple instances of XMPPAutoPing or XMPPPing,
 * then only one instance should respond to queries.
 *
 * The default value is NO.
**/
@property (nonatomic, readwrite) BOOL respondsToQueries;


+ (void)dellocSelf;


+ (WTProtoQueue *)pingQueue;


+ (WTProtoPing *)sharePingWithProtoStream:(WTProtoStream *)protoStream
                                interface:(NSString *)interface;


- (void)addProtoPingDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoPingDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoPingDelegate:(id)delegate;


- (NSString *)sendPingToServer;
- (NSString *)sendPingToServerWithTimeout:(NSTimeInterval)timeout;
- (NSString *)sendPingToJID:(WTProtoUser *)ProtoUser;
- (NSString *)sendPingToJID:(WTProtoUser *)ProtoUser withTimeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
