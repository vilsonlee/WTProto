//
//  WTProtoContact.h
//  WTProtocalKit
//
//  Created by Mark on 2020/1/2.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoContact;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoRoster;

//获取联系人详情方式的类型
typedef NS_ENUM(NSUInteger, WTProtoContactGetContactDetailsKeyType) {
    WTProtoContactGetContactDetailsKeyType_SELF               = 0,      //查询自己的信息
    WTProtoContactGetContactDetailsKeyType_Phone,                       //联系人的 手机号 （带区号）
    WTProtoContactGetContactDetailsKeyType_ID,                          //联系人设置的 wChatid
    WTProtoContactGetContactDetailsKeyType_JID,                         //联系人的 jid
    WTProtoContactGetContactDetailsKeyType_QRcode                       //联系人的 个人二维码
};

NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoContactDelegate
@optional

- (void)WTProtoContact:(WTProtoContact* )protoContact getContacts_ResultWithSucceed:(BOOL)succeed matchcount:(NSUInteger)matchcount info:(id)info;

- (void)WTProtoContact:(WTProtoContact* )protoContact getContactDetails_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProtoContact:(WTProtoContact* )protoContact setFriend_MemoName_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProtoContact:(WTProtoContact* )protoContact setFriend_StarMark_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProtoContact:(WTProtoContact* )protoContact addFriend_ResultWithSucceed:(BOOL)succeed jid:(NSString *)jid;

- (void)WTProtoContact:(WTProtoContact* )protoContact deleteFriend_ResultWithSucceed:(BOOL)succeed jid:(NSString *)jid;


- (BOOL)WTProtoContact:(WTProtoContact* )protoContact isExistFriendJid:(NSString *)jid;

- (BOOL)WTProtoContact:(WTProtoContact* )protoContact newContact:(NSDictionary *)contactInfo isWaitPass:(BOOL)isWaitPass;


@end

@interface WTProtoContact : NSObject

@property (nonatomic, strong, readonly)WTProtoStream    *contactStream;
@property (nonatomic, strong, readonly)WTProtoRoster    *ProtoRoster;


+ (void)dellocSelf;

+ (WTProtoQueue *)contactQueue;

+ (WTProtoContact *)shareContactWithProtoStream:(WTProtoStream *)protoStream
                                                    interface:(NSString *)interface;


- (void)addProtoContactDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoContactDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoContactDelegate:(id)delegate;



/**
 *  匹配好友并获取好友列表
 *
 *  @param fromUser               来自于谁发出的iq
 *  @param matchableContacts      可匹配的联系人
 *  @param phoneCode              手机号地区号码国家区号
 *  @param emptyType              本地是否有缓存好友
 *  @param nickName               当前登录用户的昵称
 *  @param userPhone              当前登录用户的手机号码
*/
- (void)IQ_GetContactsByFromUser:(WTProtoUser *)fromUser matchableContacts:(NSArray *)matchableContacts phoneCode:(NSString *)phoneCode type:(NSString *)emptyType nickName:(NSString *)nickName userPhone:(NSString *)userPhone;


/**
 *  获取联系人详情, 通过手机号/wchatid/jid 搜索查询用户
 *  @param key         传入搜索的关键字   【 手机号 / wChatid /  查询自己的信息  /  用户的jid 】
 *  @param type        搜索类型：        【 phone /    id   /     self      /     jid   】
 *  @param fromGroup   是否从群聊触发相询联系人信息的布尔值
*/
- (void)IQ_GetUserDetailWithKeyWord:(NSString *)key keyType:(WTProtoContactGetContactDetailsKeyType)type searchFromGroup:(BOOL)fromGroup source:(NSString *)source IPAddress:(NSString *)IPAddress fromUser:(WTProtoUser *)fromUser;

/**
 *  添加联系人
 *  @param   jidStr       用户的JID
 *  @param   source       添加联系人的来源途径, 0 手机号匹配 1 手机号搜索 2 wchatid搜索 3 扫一扫 4 群聊 5 名片 6......
 *  @param   statusInfo   申请添加好友的信息 dict:{phone:手机号,nickname:昵称,userAvatar:头像地址,reason:理由说明}
 *  @param   verify       是否需要验证
 *  @param   time         添加好友的时间
*/
-(void)addFriendWithJid:(NSString *)jidStr source:(NSString *)source verify:(NSString *)verify time:(NSString *)time statusInfo:(NSDictionary *)statusInfo fromUser:(WTProtoUser *)fromUser;

/**
 *  删除联系人
 *  @param   jidStr       用户的JID
*/
-(void)deleteFriendWithJid:(NSString *)jidStr;

/**
 *  将联系人添加到黑名单
*/

/**
 *  将联系人从黑名单移除
*/


/**
 *  设置好友备注名
 *  @param memoName       备注名
 *  @param jidstr         好友的JID
*/
- (void)IQ_SetFriend_MemoName:(NSString *)memoName
                          jid:(NSString *)jidstr
                     fromUser:(WTProtoUser *)fromUser;



/**
 *  联系人 - 星标好友标记设置
 *  @param jidstr         好友的JID
 *  @param state          标记的状态 0 不是 、1 是
*/
- (void)IQ_SetFriend_StarMarkWithJid:(NSString *)jidstr
                           straState:(BOOL)state
                            fromUser:(WTProtoUser *)fromUser;

@end

NS_ASSUME_NONNULL_END
