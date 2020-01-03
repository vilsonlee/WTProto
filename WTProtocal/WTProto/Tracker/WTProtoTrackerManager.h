//
//  WTProtoTrackerManager.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoQueue;
@class WTProtoMessage;
@class WTProtoConversationMessage;
@class WTProtoShakeMessage;
@class WTProtoshakedResultMessage;
@class WTProtoIQ;
@class XMPPElement;
@class WTProtoTrackerManager;

NS_ASSUME_NONNULL_BEGIN

#define TrackerTimeOutInterval 10 //消息请求，消息发送 超时时间


@protocol WTProtoTrackerManagerDelegate

@optional

-(void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager
       trackTimeOutConversationMessage:(WTProtoConversationMessage *)message;

-(void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager
       trackTimeOutShakeMessage:(WTProtoShakeMessage *)message;

-(void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager
       trackTimeOutShakeResultMessage:(WTProtoshakedResultMessage *)message;


-(void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager trackTimeOutIQ:(WTProtoIQ*)iq;

@end

@interface WTProtoTrackerManager : NSObject


+ (void)dellocSelf;

+ (WTProtoQueue *)trackerManagerQueue;

+ (WTProtoTrackerManager *)shareTrackerManager;

- (instancetype)initTrackerManager;

- (void)addProtoTrackerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoTrackerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoTrackerDelegate:(id)delegate;

- (void)addTimeOutTrack:(XMPPElement *)element timeout:(NSTimeInterval)timeout;

- (void)invokeForMessage:(WTProtoMessage *)message;

- (void)invokeForIQ:(WTProtoIQ *)iq;


@end

NS_ASSUME_NONNULL_END
