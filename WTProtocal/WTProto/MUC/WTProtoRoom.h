//
//  WTProtoRoom.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoRoom : XMPPRoom


- (void)joinRoomUsingNickname:(NSString *)desiredNickname
                      history:(NSXMLElement *)history
                  inviteUsers:(NSArray *)inviteUsers
                     roomName:(NSString *)roomName;


- (void)joinRoomUsingNickname:(NSString *)desiredNickname
                      history:(NSXMLElement *)history
                     password:(nullable NSString *)passwd
                  inviteUsers:(NSArray *)inviteUsers
                     roomName:(NSString *)roomName;


+ (WTProtoRoom *)initWithXMPPRoom:(XMPPRoom *)XMPPRoom;

/**
 * 房间配置
 */
- (void)configNewRoom;


/**
 * 群邀请确认 flag: @"0",关闭 @"1" 开启
 */
- (void)setGroupConfigInviteConfirmWithFlag:(NSString *)flag;

/**
 * 群定时销毁开启状态 time>0 开启
 */
- (void)setGroupConfigdestoryWithTime:(NSInteger)time;


/**
 * 群截屏通知 muc#roomconfig_screenshotsnotify flag: @"0"：关闭， @"1"：开启
*/
- (void)setGroupConfigScreenshotsnotify:(NSString *)flag;



/**
 * 禁止私聊 muc#roomconfig_no_private_chat flag: @"0"：关闭， @"1"：开启
*/
- (void)setGroupConfigPrivateChatFlag:(NSString *)flag;


/**
 * 群名称修改
*/
- (void)setGroupConfigGroupName:(NSString *)title;



/**
 * 群头像更新, updateTime: 更新的时间戳
*/
- (void)setGroupConfigGroupIcon:(NSString *)updateTime;


/**
 * 群公告修改
*/
- (void)setGroupConfigGroupDescription:(NSString *)desc;


@end

NS_ASSUME_NONNULL_END
