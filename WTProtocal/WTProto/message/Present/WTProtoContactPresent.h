//
//  WTProtoContactPresent.h
//  WTProtocalKit
//
//  Created by Mark on 2020/1/3.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoPresence;
@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoContactPresent : NSObject

/**
 *  添加联系人
 *  @param   jidStr       用户的JID
 *  @param   source       添加联系人的来源途径
 *  @param   statusInfo   申请添加好友的信息 dict:{phone:手机号,nickname:昵称,userAvatar:头像地址,reason:理由说明}
 *  @param   verify       是否需要验证
 *  @param   time         添加好友的时间
*/
+ (WTProtoPresence *)addFriendWithJid:(NSString *)jidStr source:(NSString *)source verify:(NSString *)verify time:(NSString *)time statusInfo:(NSDictionary *)statusInfo fromUser:(WTProtoUser *)fromUser;

/**
 * 回复已收到好友添加我的请求
 */
+ (WTProtoPresence *)agreeAddFriendRequestWithContactJid:(NSString *)jidStr source:(NSString *)source fromUserJid:(NSString *)fromUserJid;

/**
 * 回复好友同意添加我的请求
 */
+ (WTProtoPresence *)replyAddFriendRequestReceivedWithContactJid:(NSString *)jidStr;

@end

NS_ASSUME_NONNULL_END
