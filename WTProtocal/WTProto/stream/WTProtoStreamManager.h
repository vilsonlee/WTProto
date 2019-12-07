//
//  WTProtoStreamManager.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoStreamManager;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoStreamManagement;
@class WTProtoStreamManagementMemoryStorage;




NS_ASSUME_NONNULL_BEGIN


@protocol WTProtoStreamManagerDelegate

@optional


@end

@interface WTProtoStreamManager : NSObject

@property (nonatomic, strong, readonly)WTProtoStream *ManagerStream;

@property (nonatomic, strong, readonly)WTProtoStreamManagement *ProtoStreamManagement;

@property (nonatomic, strong, readonly)WTProtoStreamManagementMemoryStorage *ProtoStreamManagementMemoryStorage;


+ (WTProtoQueue *)streamManagerQueue;

+ (WTProtoStreamManager *)shareStreamManagerWithProtoStream:(WTProtoStream *)protoStream
                                                  interface:(NSString *)interface;


-(void)addProtoStreamManagerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoStreamManagerDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoStreamManagerDelegate:(id)delegate;




@end

NS_ASSUME_NONNULL_END
