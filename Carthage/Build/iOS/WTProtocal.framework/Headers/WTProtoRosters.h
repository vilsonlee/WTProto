//
//  WTProtoRosters.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/21.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoRosters;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoRosterCoreDataStorage;
@class WTProtoRoster;
@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN


@protocol WTProtoRostersDelegate

@optional


@end


@interface WTProtoRosters : NSObject

@property (nonatomic, strong, readonly)WTProtoStream *RostersStream;
@property (nonatomic, strong, readonly)WTProtoRoster *ProtoRoster;
@property (nonatomic, strong, readonly)WTProtoRosterCoreDataStorage *protoRosterCoreDataStorage;


+ (WTProtoQueue *)rostersQueue;

+ (WTProtoRosters *)shareRostersWithProtoStream:(WTProtoStream *)protoStream
                                      interface:(NSString *)interface;


- (void)addProtoRostersDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoRostersDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoRostersDelegate:(id)delegate;


@property (nonatomic, assign) BOOL autoFetchRoster;

@property (nonatomic, assign) BOOL autoClearAllUsersAndResources;

@property (nonatomic, assign) BOOL autoAcceptKnownPresenceSubscriptionRequests;

@property (nonatomic, assign) BOOL allowRosterlessOperation;

@property (assign, readonly) BOOL hasRequestedRoster;

@property (assign, readonly) BOOL isPopulating;

@property (assign, readonly) BOOL hasRoster;


- (void)fetchRoster;
- (void)fetchRosterVersion:(nullable NSString *)version;

- (void)addUser:(WTProtoUser *)protoUser source:(NSString *)source reason:(NSString *)reason
         verify:(NSString *)verify;
- (void)addUser:(WTProtoUser *)protoUser withNickname:(nullable NSString *)optionalName;
- (void)addUser:(WTProtoUser *)protoUser withNickname:(nullable NSString *)optionalName
         groups:(nullable    NSArray<NSString*> *)groups;
- (void)addUser:(WTProtoUser *)protoUser withNickname:(nullable NSString *)optionalName
         groups:(nullable NSArray<NSString*> *)groups subscribeToPresence:(BOOL)subscribe;

- (void)removeUser:(WTProtoUser *)protoUser;

- (void)setNickname:(NSString *)nickname forUser:(WTProtoUser *)protoUser;

- (void)subscribePresenceToUser:(WTProtoUser *)protoUser;
- (void)unsubscribePresenceFromUser:(WTProtoUser *)protoUser;
- (void)revokePresencePermissionFromUser:(WTProtoUser *)protoUser;

- (void)acceptPresenceSubscriptionRequestFrom:(WTProtoUser *)protoUser andAddToRoster:(BOOL)flag;
- (void)rejectPresenceSubscriptionRequestFrom:(WTProtoUser *)protoUser;


@end

NS_ASSUME_NONNULL_END
