//
//  WTProtoReConnection.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>


@class WTProtoStream;
@class WTProtoReConnection;
@class WTProtoQueue;
@class WTProtoReconnect;

NS_ASSUME_NONNULL_BEGIN



@protocol WTProtoReConnectionDelegate

@optional


@end



@interface WTProtoReConnection : NSObject

@property (nonatomic, strong,readonly)WTProtoStream* reConnectStream;

+ (WTProtoQueue *)reConnectQueue;

+ (WTProtoReConnection *)shareReConnecionWithProtoStream:(WTProtoStream *)protoStream
                                          ReconnectDelay:(NSTimeInterval )reconnectDelay
                                  ReconnectTimerInterval:(NSTimeInterval )reconnectTimerInterval
                                               interface:(NSString *)interface;


-(void)addProtoReConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoReConnectionDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoReConnectionDelegate:(id)delegate;


/**
 * Whether auto reconnect is enabled or disabled.
 *
 * The default value is YES (enabled).
 *
 * Note: Altering this property will only affect future accidental disconnections.
*/
@property (nonatomic, assign) BOOL autoReconnect;


/**
 * Whether you want to reconnect using the legacy method -[XMPPStream oldSchoolSecureConnectWithTimeout:error:]
 * instead of the standard -[XMPPStream connect:].
 *
 * If you initially connect using -oldSchoolSecureConnectWithTimeout:error:, set this to YES to reconnect the same way.
 *
 * The default value is NO (disabled).
 */
@property (nonatomic, assign) BOOL usesOldSchoolSecureConnect;


/**
 * When the accidental disconnection first happens,
 * a short delay may be used before attempting the reconnection.
 *
 * The default value is DEFAULT_XMPP_RECONNECT_DELAY (defined at the top of this file).
 *
 * To disable this feature, set the value to zero.
 *
 * Note: NSTimeInterval is a double that specifies the time in seconds.
**/
@property (nonatomic, assign) NSTimeInterval reconnectDelay;


/**
 * A reconnect timer may optionally be used to attempt a reconnect periodically.
 * The timer will be started after the initial reconnect delay.
 *
 * The default value is DEFAULT_XMPP_RECONNECT_TIMER_INTERVAL (defined at the top of this file).
 *
 * To disable this feature, set the value to zero.
 *
 * Note: NSTimeInterval is a double that specifies the time in seconds.
**/
@property (nonatomic, assign) NSTimeInterval reconnectTimerInterval;


/**
 * As opposed to using autoReconnect, this method may be used to manually start the reconnect process.
 *
 * This may be useful, for example, if one needs network monitoring in order to setup the inital xmpp connection.
 * Or if one wants autoReconnect but only in very limited situations which they prefer to control manually.
 *
 * After invoking this method one can expect the class to act as if an accidental disconnect just occurred.
 *
 * That is, a reconnect attempt will be tried after reconnectDelay seconds,and the class will begin monitoring the network
 * for changes in reachability to the xmpp host.
 *
 * A manual start of the reconnect process will effectively end once the xmpp stream has been opened.
 *
 * That is, if you invoke manualStart and the xmpp stream is later opened,
 * then future disconnections will not result in an auto reconnect process (unless the autoReconnect property applies).
 *
 * This method does nothing if the xmpp stream is not disconnected.
 *
 * 与使用autoReconnect相反，此方法可用于手动启动xmpp重新连接过程。
 * 例如若需要网络监视以设置初始xmpp连接时，这可能很有用。
 * 或者开发者如果只想在非常有限的情况下希望自动xmpp重新连接，而这时他们更倾向于手动控制。
 * 调用此方法后，可以期望该对象类像模拟刚刚发生意外断开连接一样起作用。
 * 也就是说，将在reconnectDelay秒后尝试进行xmpp重新连接，并且该类将开始监视网络以了解xmpp主机的可达性更改。
 * 一旦打开xmpp流，重新连接过程的手动启动将有效终止。
 * 也就是说，如果您调用manualStart并且稍后开启xmpp流后，那么将来的断开连接将不会调用自动重新连接过程（除非应用了autoReconnect属性）。
 * 若xmpp没有disconnected 调用此方法将不会有什么作用。

 */
- (void)ManualStart;


/**
 * Stops the current reconnect process.
 *
 * This method will stop the current reconnect process regardless of whether the
 * reconnect process was started due to the autoReconnect property or due to a call to manualStart.
 *
 * Stopping the reconnect process does NOT prevent future auto reconnects if the property is enabled.
 * That is, if the autoReconnect property is still enabled, and the xmpp stream is later opened, authenticated and
 * accidentally disconnected, this class will still attempt an automatic reconnect.
 *
 * Stopping the reconnect process does NOT prevent future calls to manualStart from working.
 * It only stops the CURRENT reconnect process.
 *
 * 停止当前的重新连接过程。
 * 无论由于autoReconnect属性还是由于对manualStart的调用而启动了重新连接过程，此方法都将停止当前的重新连接过程。
 * 如果启用了属性，则停止重新连接过程不会阻止以后的自动重新连接。
 * 也就是说，如果仍启用autoReconnect属性，并且以后打开xmpp流，对其进行身份验证并意外断开连接，则此类仍将尝试自动重新连接。
 * 停止重新连接过程不会阻止以后调用manualStart的工作。
 * 它仅停止CURRENT重新连接过程。
 *
 */
- (void)Stop;

@end

NS_ASSUME_NONNULL_END
