//
//  WTProtoGroupIQ.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoIQ;
@class XMPPIQ;
@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoGroupIQ : NSObject


/**
*  获取指定群的信息
*  @param roomID        群ID
*/
+ (WTProtoIQ *)IQ_GetRoomInfoWithRoomID:(WTProtoUser* )roomID;



/**
*  邀请User订阅加入群
 *  @param roomID           群ID
 *  @param roomName         房间名
 *  @param jointype         加入类型
 *  @param friends          加入人
 *  @param inviterNickName  邀请者的好友
 *  @param inviterID        邀请者ID
 *  @param reason           理由
*/
+ (WTProtoIQ *)IQ_InviteUserSubscribesWithFromUser:(WTProtoUser*)fromUser
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
+ (WTProtoIQ *)IQ_GetGroupListByFromUser:(WTProtoUser *)fromUser;



/**
*  获取订阅成员（成员列表)
*  @param roomID        群ID
*/
+ (WTProtoIQ *)IQ_GetGroupMembersListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID;




/**
 *  取消订阅（退群）
 *  @param roomID           群ID
 *  @param roomName         群名
 *  @param roomOwnerID      群主ID
 *  @param nickName         退群成员NickName
*/
+ (WTProtoIQ *)IQ_ExitUserSubscribesWithFromUser:(WTProtoUser *)fromUser
                                          RoomID:(WTProtoUser *)roomID
                                        roomName:(NSString *)roomName
                                     roomOwnerID:(WTProtoUser *)roomOwnerID
                             memberGroupNickName:(NSString *)nickName;


///移出群（管理员踢人,多人）
+(WTProtoIQ *)IQ_RemoveMemberUnscribesChatRoomWithFromUser:(WTProtoUser *)fromUser
                                                    RoomID:(WTProtoUser *)roomID
                                                  roomName:(NSString *)roomName
                                               roomOwnerID:(WTProtoUser *)roomOwnerID
                                       memberGroupNickName:(NSString *)nickName
                                                   Friends:(NSArray *)friends;



/**
*  保存群到通讯录
*  @param roomID        群ID
*  @param state         开关， 0否， 1是
*/
+ (WTProtoIQ *)IQ_SaveGroupToContactListWithFromUser:(WTProtoUser *)fromUser
                                             RoomJid:(WTProtoUser *)roomID
                                               state:(BOOL)state;



///消息免打扰
/**
*  修改我的群昵称
*  @param roomID        群ID
*  @param state         打扰开关， 0 是取消， 1是设置
*/
+ (WTProtoIQ *)IQ_UnDisturbWithFromUser:(WTProtoUser *)fromUser
                                 RoomID:(WTProtoUser *)roomID
                                  state:(BOOL)state;


/**
*  修改我的群昵称
*  @param roomID        群ID
*  @param newNickname   群名
*  @param changeflag    设置类型， 0 是取消， 1是设置
*/
+ (WTProtoIQ *)IQ_ModifyRoomNickNameWithFromUser:(WTProtoUser *)fromUser
                                          RoomID:(WTProtoUser *)roomID
                                        nickname:(NSString *)newNickname
                                      changeflag:(NSInteger)changeflag;


/**
*  群主权限转让
*  @param roomID        群成员列表
*  @param newOwernick   新群主NickName
*  @param newOwerID     新群主ID
*/
+ (WTProtoIQ *)IQ_ExChangeGroupOwnerAuthorityWithFromUser:(WTProtoUser *)fromUser
                                                   RoomID:(WTProtoUser *)roomID
                                              newOwernick:(NSString *)newOwernick
                                                newOwerID:(WTProtoUser *)newOwerID;


/**
*  群管理员设置
*  @param member    群成员列表
*  @param roomJid   房间的JID
*  @param style     设置类型， 0 是取消， 1是设置
*/
+ (WTProtoIQ *)IQ_SetGroupAdminWithFromUser:(WTProtoUser *)fromUser
                                   Memebers:(NSArray *)member
                                    roomJid:(WTProtoUser *)roomJid
                                      style:(NSString *)style;


/**
*  获取退群成员列表
*  @param roomID    房间的JID
*/
+ (WTProtoIQ *)IQ_GetGroupQuiteMemberListWithFromUser:(WTProtoUser *)fromUser
                                               RoomID:(WTProtoUser *)roomID;



/**
*  设置群禁言
*  @param member                群成员列表
*  @param roomID                房间的ID
*  @param nickName              设置禁言的操作者的群昵称
*  @param style 设置类型，        0是取消禁言， 1是设置禁言
*/
+ (WTProtoIQ *)IQ_SetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser
                                                RoomID:(WTProtoUser *)roomID
                                              memebers:(NSArray *)member
                                              nickName:(NSString *)nickName
                                                 style:(NSString *)style;



/**
*  设置群全员禁言
*  @param roomID       房间的JID
*  @param nickName     设置禁言的操作者的群昵称
*  @param style        设置类型， 0 是取消全员禁言， 1是设置全员禁言
*/
+ (WTProtoIQ *)IQ_SetGroupBannedAllWithFromUser:(WTProtoUser *)fromUser
                                         RoomID:(WTProtoUser *)roomID
                                       nickName:(NSString *)nickName
                                          style:(NSString *)style;


/**
 *  获取群禁言名单
 *  @param roomID         房间的JID
*/
+ (WTProtoIQ *)IQ_GetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID;



/**
 *  获取活跃度群成员
 *  @param roomID        房间的JID
 *  @param activityTime  活跃时长，"3/7/30/90"/ （三天不活跃、一个星期不活跃、三十天不活跃、三个月不活跃）
*/
+ (WTProtoIQ *)IQ_GetGroupActivityMemberWithFromUser:(WTProtoUser *)fromUser
                                              RoomID:(WTProtoUser *)roomID
                                        activityTime:(NSString *)activityTime;


/**
 *  设置陌生人备注
 *  @param roomID         房间的JID
 *  @param memberID       设置备注名的陌生人的JID
 *  @param name           备注名
*/
+ (WTProtoIQ *)IQ_SetGroupMemberRemarkNameWithFromUser:(WTProtoUser *)fromUser
                                                RoomID:(WTProtoUser *)roomID
                                              memberID:(WTProtoUser *)memberID
                                              noteName:(NSString *)name;


+ (void)parse_IQ_GetRoomInfo:(XMPPIQ *)iq
                 parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_InviteUserSubscribes:(XMPPIQ *)iq
                          parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_GetGroupList:(XMPPIQ *)iq
                  parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_GetGroupMembersList:(XMPPIQ *)iq
                         parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_ExitUserSubscribes:(XMPPIQ *)iq
                        parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_RemoveMemberUnscribesChatRoom:(XMPPIQ *)iq
                                   parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_SaveGroupToContactList:(XMPPIQ *)iq
                            parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_UnDisturb:(XMPPIQ *)iq
               parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_ModifyRoomNickName:(XMPPIQ *)iq
                        parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_ExChangeGroupOwnerAuthority:(XMPPIQ *)iq
                                 parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_SetGroupAdmin:(XMPPIQ *)iq
                   parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_GetGroupQuiteMemberList:(XMPPIQ *)iq
                             parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_SetGroupBannedMemberList:(XMPPIQ *)iq
                              parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_SetGroupBannedAll:(XMPPIQ *)iq
                       parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_GetGroupBannedMemberList:(XMPPIQ *)iq
                              parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_GetGroupActivityMember:(XMPPIQ *)iq
                            parseResult:(void (^)(BOOL succeed, id Info))parseResult;


+ (void)parse_IQ_SetGroupMemberRemarkName:(XMPPIQ *)iq
                              parseResult:(void (^)(BOOL succeed, id Info))parseResult;


@end

NS_ASSUME_NONNULL_END
