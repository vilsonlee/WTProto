//
//  WTProtoUserConfigIQ.h
//  WTProtocalKit
//
//  Created by Mark on 2020/3/13.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoIQ;
@class WTProtoUser;
@class XMPPIQ;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoUserConfigIQ : NSObject

//获取用户偏好设置
+ (WTProtoIQ *)IQ_getUserPerferenceWithLocalUser:(WTProtoUser *)fromUser;
+ (void)parse_IQ_getUserPerference:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

//获取用户聊天设置
+ (WTProtoIQ *)IQ_getUserChatSettingWithLocalUser:(WTProtoUser *)fromUser;
+ (void)parse_IQ_getUserChatSetting:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

//更新用户偏好设置
+ (WTProtoIQ *)IQ_updateUserConfigWithDict:(NSDictionary *)updateDict localUser:(WTProtoUser *)fromUser;
+ (void)parse_IQ_updateUserConfig:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

//更新用户聊天配置
+ (WTProtoIQ *)IQ_updateUserChatSettingWithDict:(NSDictionary *)updateDict localUser:(WTProtoUser *)fromUser;
+ (void)parse_IQ_updateUserChatSetting:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

//移除用户聊天配置
+ (WTProtoIQ *)IQ_removeUserChatSettingWithDict:(NSDictionary *)updateDict localUser:(WTProtoUser *)fromUser;
+ (void)parse_IQ_removeUserChatSetting:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

@end

NS_ASSUME_NONNULL_END
