//
//  WTProtoGroup.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoGroup;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoMUC;
@class WTProtoRoom;
@class WTProtoIDTracker;
@class WTProtoIQ;
@class XMPPRoom;
@class XMPPIQ;

NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoGroupDelegate

@optional


-(void)WTProtoGroup:(WTProtoGroup* )protoGroup RoomDidCreat:(XMPPRoom *)room;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup RoomDidCreateFail:(XMPPRoom *)room info:(id)info;

-(void)WTProtoGroup:(WTProtoGroup* )protoGroup RoomDidConfigure:(XMPPRoom *)room iqResult:(WTProtoIQ *)iqResult;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup RoomDidNotConfigure:(XMPPRoom *)room iqResult:(WTProtoIQ *)iqResult;

-(void)WTProtoGroup:(WTProtoGroup* )protoGroup GetRoomInfo_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup InviteUserSubscribes_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup GetGroupList_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup GetGroupMembersList_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup ExitUserSubscribes_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup RemoveMemberUnscribesChatRoom_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup SaveGroupToContactList_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup UnDisturb_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup ModifyRoomNickName_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup ExChangeGroupOwnerAuthority_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup SetGroupAdmin_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup GetGroupQuiteMemberList_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup SetGroupBannedMemberList_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup SetGroupBannedAll_Result:(BOOL)resalut inf:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup GetGroupBannedMemberList_Result:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup GetGroupActivityMember_oResult:(BOOL)resalut info:(id)info;
-(void)WTProtoGroup:(WTProtoGroup* )protoGroup SetGroupMemberRemarkName_Result:(BOOL)resalut info:(id)info;

@end


@interface WTProtoGroup : NSObject


@property (nonatomic, strong, readonly)WTProtoStream    *groupStream;
@property (nonatomic, strong, readonly)WTProtoMUC       *protoMUC;
@property (nonatomic, strong, readonly)WTProtoRoom      *protoRoom;
@property (nonatomic, strong, readonly)WTProtoIDTracker *protoTracker;


+ (void)dellocSelf;

+ (WTProtoQueue *)groupQueue;

+ (WTProtoGroup *)shareGroupWithProtoStream:(WTProtoStream *)protoStream
                                  interface:(NSString *)interface;


- (void)addProtoGroupDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoGroupDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoGroupDelegate:(id)delegate;

- (void)joinRoomWithJid:(WTProtoUser *)jid Nickname:(NSString *)nickname
                                           roomName:(NSString *)roomName
                                        inviteUsers:(NSArray *)inviteUsers;



/**
 *  获取指定群的信息
*/
- (void)request_IQ_GetRoomInfoWithRoomID:(WTProtoUser* )roomID;



/**
 *  邀请User订阅加入群
*/
- (void)request_IQ_InviteUserSubscribesWithFromUser:(WTProtoUser*)fromUser
                                  RoomID:(WTProtoUser *)roomID
                                roomName:(NSString *)roomName
                                joinType:(NSString *)jointype
                                 Friends:(NSArray *)friends
                         inviterNickName:(NSString *)inviterNickName
                               inviterID:(NSString *)inviterID
                                  reason:(NSString *)reason;


/**
 *  获取群列表
*/
- (void)request_IQ_GetGroupListByFromUser:(WTProtoUser *)fromUser;


/**
 *  获取订阅成员（成员列表)
*/
- (void)request_IQ_GetGroupMembersListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID;


/**
 *  取消订阅（退群）
*/
- (void)request_IQ_ExitUserSubscribesWithFromUser:(WTProtoUser *)fromUser
                                           RoomID:(WTProtoUser *)roomID
                                         roomName:(NSString *)roomName
                                      roomOwnerID:(WTProtoUser *)roomOwnerID
                              memberGroupNickName:(NSString *)nickName;


/**
 * 移出群（管理员踢人,多人）
*/
- (void)request_IQ_RemoveMemberUnscribesChatRoomWithFromUser:(WTProtoUser *)fromUser
                                           RoomID:(WTProtoUser *)roomID
                                         roomName:(NSString *)roomName
                                      roomOwnerID:(WTProtoUser *)roomOwnerID
                              memberGroupNickName:(NSString *)nickName
                                          Friends:(NSArray *)friends;


/**
*  保存群到通讯录
*/
- (void)request_IQ_SaveGroupToContactListWithFromUser:(WTProtoUser *)fromUser
                                              RoomJid:(WTProtoUser *)roomID
                                                state:(BOOL)state;


/**
*  消息免打扰
*/
- (void)request_IQ_UnDisturbWithFromUser:(WTProtoUser *)fromUser
                                  RoomID:(WTProtoUser *)roomID
                                   state:(BOOL)state;


/**
*  修改我的群昵称
*/
- (void)request_IQ_ModifyRoomNickNameWithFromUser:(WTProtoUser *)fromUser
                                           RoomID:(WTProtoUser *)roomID
                                         nickname:(NSString *)newNickname
                                       changeflag:(NSInteger)changeflag;


/**
*  群主权限转让
*/
- (void)request_IQ_ExChangeGroupOwnerAuthorityWithFromUser:(WTProtoUser *)fromUser
                                                    RoomID:(WTProtoUser *)roomID
                                               newOwernick:(NSString *)newOwernick
                                                 newOwerID:(WTProtoUser *)newOwerID;


/**
*  群管理员设置
*/
- (void)request_IQ_SetGroupAdminWithFromUser:(WTProtoUser *)fromUser
                                    Memebers:(NSArray *)member
                                     roomJid:(NSString *)roomJid
                                       style:(NSString *)style;


/**
*  获取退群成员列表
*/
- (void)request_IQ_GetGroupQuiteMemberListWithFromUser:(WTProtoUser *)fromUser
                                                RoomID:(WTProtoUser *)roomID;



/**
*  设置群禁言
*/
- (void)request_IQ_SetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser
                                                 RoomID:(WTProtoUser *)roomID
                                               memebers:(NSArray *)member
                                               nickName:(NSString *)nickName
                                                  style:(NSString *)style;


/**
 *  设置群全员禁言
*/
- (void)request_IQ_SetGroupBannedAllWithFromUser:(WTProtoUser *)fromUser
                                          RoomID:(WTProtoUser *)roomID
                                        nickName:(NSString *)nickName
                                           style:(NSString *)style;


/**
 *  获取群禁言名单
*/
- (void)request_IQ_GetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID;


/**
 *  获取活跃度群成员
*/
- (void)request_IQ_GetGroupActivityMemberWithFromUser:(WTProtoUser *)fromUser
                                               RoomID:(WTProtoUser *)roomID
                                         activityTime:(NSString *)activityTime;


/**
 *  设置陌生人备注
*/
- (void)request_IQ_SetGroupMemberRemarkNameWithFromUser:(WTProtoUser *)fromUser
                                                 RoomID:(WTProtoUser *)roomID
                                               memberID:(WTProtoUser *)memberID
                                               noteName:(NSString *)name;



/**
 *  群邀请确认
*/
- (void)setGroupConfigInviteConfirmWithFlag:(NSString *)flag roomID:(WTProtoUser *)roomID;


/**
 *  群定时销毁开启状态 time>0 开启
*/
- (void)setGroupConfigdestoryWithTime:(NSInteger)time roomID:(WTProtoUser *)roomID;



/**
 *  群截屏通知 muc#roomconfig_screenshotsnotify flag: @"0"：关闭， @"1"：开启
 */
- (void)setGroupConfigScreenshotsnotify:(NSString *)flag roomID:(WTProtoUser *)roomID;



/**
 *  禁止私聊 muc#roomconfig_no_private_chat flag: @"0"：关闭， @"1"：开启
 */
- (void)setGroupConfigPrivateChatFlag:(NSString *)flag roomID:(WTProtoUser *)roomID;



/**
 *  群名称修改
 */
- (void)setGroupConfigGroupName:(NSString *)title roomID:(WTProtoUser *)roomID;



/**
 *  群头像更新, updateTime: 更新的时间戳
 */
- (void)setGroupConfigGroupIcon:(NSString *)updateTime roomID:(WTProtoUser *)roomID;




/**
 *  群公告修改
 */
- (void)setGroupConfigGroupDescription:(NSString *)desc roomID:(WTProtoUser *)roomID;

@end

NS_ASSUME_NONNULL_END
