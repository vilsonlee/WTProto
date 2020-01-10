//
//  WTProtoContactIQ.h
//  WTProtocalKit
//
//  Created by Mark on 2020/1/2.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoIQ;
@class XMPPIQ;
@class WTProtoUser;

//获取联系人详情方式的类型
typedef NS_ENUM(NSUInteger, WTProtoGetContactDetailsKeyType) {
    WTProtoGetContactDetailsKeyType_SELF               = 0,      //查询自己的信息
    WTProtoGetContactDetailsKeyType_Phone,                       //联系人的 手机号 （带区号）
    WTProtoGetContactDetailsKeyType_ID,                          //联系人设置的 wChatid
    WTProtoGetContactDetailsKeyType_JID,                         //联系人的 jid
    WTProtoGetContactDetailsKeyType_QRcode                       //联系人的 个人二维码
};



NS_ASSUME_NONNULL_BEGIN

@interface WTProtoContactIQ : NSObject

#pragma mark -  IQ请求生成

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
+ (WTProtoIQ *)IQ_GetContactsByFromUser:(WTProtoUser *)fromUser
                      matchableContacts:(NSArray *)matchableContacts
                              phoneCode:(NSString *)phoneCode
                                   type:(NSString *)emptyType
                               nickName:(NSString *)nickName
                              userPhone:(NSString *)userPhone;


/**
 *  获取联系人详情, 通过手机号/wchatid/jid 搜索查询用户
 *  @param keyWord        传入搜索的关键字   【 手机号 / wChatid /  查询自己的信息  /  用户的jid 】
 *  @param keyType        搜索类型：        【 phone /    id   /     self      /     jid   】
 *  @param fromGroup      是否从群聊触发相询联系人信息的布尔值
 *  @param source         来源，使用productName，去除空格，小写, 去掉Water.IM的"."。
 *  @param IPAddress      当前公网ip地址
*/
+ (WTProtoIQ *)IQ_GetUserDetailsWithKeyWord:(NSString *)keyWord
                                    keyType:(WTProtoGetContactDetailsKeyType)keyType
                            searchFromGroup:(BOOL)fromGroup
                                     source:(NSString *)source
                                  IPAddress:(NSString *)IPAddress
                                   fromUser:(WTProtoUser *)fromUser
                                     toUser:(WTProtoUser *)toUser;



/**
 *  设置好友备注名
 *  @param memoName       备注名
 *  @param jidstr         好友的JID
*/
+ (WTProtoIQ *)IQ_SetFriend_MemoName:(NSString *)memoName
                      jid:(NSString *)jidstr
                 fromUser:(WTProtoUser *)fromUser
                   toUser:(WTProtoUser *)toUser;

///联系人 - 星标好友标记设置
+ (WTProtoIQ *)IQ_SetFriend_StarMarkWithJid:(NSString *)jidstr
                          straState:(BOOL)state
                           fromUser:(WTProtoUser *)fromUser
                             toUser:(WTProtoUser *)toUser;








#pragma mark -  返回结果解释

//匹配好友并获取好友列表  返回结果处理方法
+ (void)parse_IQ_GetContactsAndMatchFriends:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, NSInteger matchcount, id info))parseResult;


//获取联系人详情, 通过手机号/wchatid/jid 搜索查询用户  返回结果处理方法
+ (void)parse_IQ_GetUserDetails:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;


//设置好友备注名  返回结果处理方法
+ (void)parse_IQ_SetFriend_MemoName:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;


//联系人 - 星标好友标记设置  返回结果处理方法
+ (void)parse_IQ_SetFriend_StarMark:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

@end

NS_ASSUME_NONNULL_END
