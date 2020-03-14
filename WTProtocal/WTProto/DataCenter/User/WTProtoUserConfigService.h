//
//  WTProtoUserConfigService.h
//  WTProtocalKit
//
//  Created by Mark on 2020/3/13.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoUserConfigService;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoUserConfigServiceDelegate

@optional

-(void)WTProtoUserConfigService:(WTProtoUserConfigService* )UserConfigService
        getUserPerferenceResult:(BOOL)result
                           info:(id)info;

-(void)WTProtoUserConfigService:(WTProtoUserConfigService* )UserConfigService
       getUserChatSettingResult:(BOOL)result
                           info:(id)info;
    
-(void)WTProtoUserConfigService:(WTProtoUserConfigService* )UserConfigService
         updateUserConfigResult:(BOOL)result
                           info:(id)info;

-(void)WTProtoUserConfigService:(WTProtoUserConfigService* )UserConfigService
    updateUserChatSettingResult:(BOOL)result
                           info:(id)info;

-(void)WTProtoUserConfigService:(WTProtoUserConfigService* )UserConfigService
    removeUserChatSettingResult:(BOOL)result
                           info:(id)info;

@end

@interface WTProtoUserConfigService : NSObject

@property (nonatomic, strong, readonly)WTProtoStream    *userConfigStream;

+ (void)dellocSelf;

+ (WTProtoQueue *)userConfigServiceQueue;

+ (WTProtoUserConfigService *)shareUserConfigServiceWithProtoStream:(WTProtoStream *)protoStream
                                                      interface:(NSString *)interface;

- (void)addProtoUserConfigServiceDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoUserConfigServiceDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoUserConfigServiceDelegate:(id)delegate;


#pragma mark - Main Method

/**
 *  获取用户偏好设置
*/
- (void)IQ_getUserPerferenceInfo:(WTProtoUser *)fromUser;

/**
 *  获取用户聊天设置
*/
- (void)IQ_getUserChatSettingInfo:(WTProtoUser *)fromUser;

/**
 *  更新用户偏好设置
*/
- (void)IQ_updateUserConfigWithDict:(NSDictionary *)data fromUser:(WTProtoUser *)fromUser;

/**
 *  更新用户聊天配置
*/
- (void)IQ_updateUserChatSettingWithDict:(NSDictionary *)data fromUser:(WTProtoUser *)fromUser;

/**
 *  移除用户聊天配置
*/
- (void)IQ_removeUserChatSettingWithDict:(NSDictionary *)data fromUser:(WTProtoUser *)fromUser;


@end

NS_ASSUME_NONNULL_END
