//
//  WTProtoUserInfoService.h
//  WTProtocalKit
//
//  Created by Vilson on 2020/1/17.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoUserInfoService;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoIDTracker;
@class WTProtoIQ;
@class XMPPIQ;

NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoUserInfoServiceDelegate

@optional

-(void)WTProtoUserInfoService:(WTProtoUserInfoService* )UserInfoService
             SearchUserResult:(BOOL)result
                         info:(id)info;

-(void)WTProtoUserInfoService:(WTProtoUserInfoService* )UserInfoService
                     methodID:(NSString *)methodID
         updateUserInfoResult:(BOOL)result
                         info:(id)info;


@end




@interface WTProtoUserInfoService : NSObject

@property (nonatomic, strong, readonly)WTProtoStream    *UserInfoServiceStream;
@property (nonatomic, strong, readonly)WTProtoIDTracker *protoTracker;


+ (void)dellocSelf;

+ (WTProtoQueue *)userInfoServiceQueue;

+ (WTProtoUserInfoService *)shareUserInfoServiceWithProtoStream:(WTProtoStream *)protoStream
                                                      interface:(NSString *)interface;

- (void)addProtoUserInfoServiceDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoUserInfoServiceDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoUserInfoServiceDelegate:(id)delegate;



/**
 *  通过手机号或wchatid搜索用户
 *  @param localUser        当前登录用户
 *  @param key              传入搜索的关键字
 *  @param type             搜索类型：（手机号 phone）/(id wChatid)/self :self是指查询自己的信息
 *  @param fromGroup        是否为群
*/
- (void)request_IQ_SearchUserInfoWithLocalUser:(WTProtoUser*)localUser
                                       KeyWord:(NSString *)key
                                       keyType:(NSString *)type
                               searchFromGroup:(BOOL)fromGroup;

//修改个人资料
-(void)request_IQ_UpdateUserInfoWithLocalUser:(WTProtoUser *)localUser
                                   updateInfo:(NSDictionary *)infoDict
                                     methodID:(NSString *)methodID;



@end

NS_ASSUME_NONNULL_END
