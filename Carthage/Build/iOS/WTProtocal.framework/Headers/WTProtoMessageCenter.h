//
//  WTProtoMessageCenter.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/26.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>


@class WTProtoMessageCenter;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;


NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoMessageCenterDelegate

@optional


@end



@interface WTProtoMessageCenter : NSObject

@property (nonatomic, strong, readonly)WTProtoStream* messageCenterStream;

@property (nonatomic, strong, readonly)WTProtoUser* messageCenterUser;


+ (WTProtoQueue *)messageCenterQueue_Concurrent;
+ (WTProtoQueue *)messageCenterQueue_Serial;




+ (WTProtoMessageCenter *)shareMessagerCenterWithProtoStream:(WTProtoStream *)protoStream
                                                   interface:(NSString *)interface;



- (void)addProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoMessageCenterDelegate:(id)delegate;



@end

NS_ASSUME_NONNULL_END
