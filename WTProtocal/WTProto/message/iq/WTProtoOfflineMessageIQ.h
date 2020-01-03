//
//  WTProtoOfflineMessageIQ.h
//  WTProtocalKit
//
//  Created by Mark on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoIQ;
@class XMPPIQ;
@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoOfflineMessageIQ : NSObject


#pragma mark -  IQ请求生成
/**
 *  获取单聊离线消息 (旧方式)
 *
 *  @param fromUser               来自于谁发出的iq
 *  @param toID                   接收的iq的
 *  @param timestamp              消息的时间戳，传空表示从最开始的位置获取
*/
+ (WTProtoIQ *)IQ_GetSingleChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID timestamp:(NSString *)timestamp;


/**
 *  获取单聊离线会话列表 (新方式) ，返回有离线消息的会话单聊部分的列表

 *
 *  @param fromUser               来自于谁发出的iq
 *  @param toID                   接收的iq的
*/
+ (WTProtoIQ *)IQ_GetSingleChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID;


/**
 *  获取群聊离线会话列表（旧方式）
 *
 *  @param fromUser               来自于谁发出的iq
 *  @param toID                   接收的iq的
*/
+ (WTProtoIQ *)IQ_GetGroupChatOfflineListWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID;



/**
 *  获取群聊离线会话列表（新方式）
 *
 *  @param fromUser               来自于谁发出的iq
 *  @param toID                   接收的iq的
*/
+ (WTProtoIQ *)IQ_GetGroupChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID;



/**
 *  获取单聊离线消息, 动态拉取单聊离线消息, 与新单聊列表对应使用
 *
 *  @param fromUser               来自于谁发出的iq
 *  @param toID                   接收的iq的
 *  @param start                  开始位置自增id
 *  @param end                    结束位置自增id
 *  @param ascending              当startIndexID和endIndexID有传值时 ascending
 *                                的值在后台不起作用，后台会默认从start正序返回离线消息
 *  @param chatJid                会话id/聊天对象JID
*/
+ (WTProtoIQ *)IQ_GetSingleChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID startIndex:(NSString *)start endIndex:(NSString *)end ascending:(BOOL)ascending chatJid:(NSString *)chatJid;


/**
 *  获取群聊的离线消息(旧方式)
 *
 *  @param fromUser               来自于谁发出iq的jid
 *  @param toID                   接收iq的jid
 *  @param timestamp              消息的时间戳，传空表示从最开始的位置获取
 *  @param chatJid                会话id/聊天对象JID/群JID
*/
+ (WTProtoIQ *)IQ_GetGroupChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID timestamp:(NSString *)timestamp chatJid:(NSString *)chatJid;



/**
 *  获取群聊的离线消息(新方式)
 *
 *  @param fromUser               来自于谁发出iq的jid
 *  @param toID                   接收iq的jid
 *  @param start                  开始位置自增id
 *  @param end                    结束位置自增id
 *  @param ascending              当startIndexID和endIndexID有传值时 ascending 的值在后台不起作用，后台会默认从start正序返回离线消息
 *  @param chatJid                会话id/聊天对象JID/群JID
*/
+ (WTProtoIQ *)IQ_GetGroupChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser toID:(WTProtoUser *)toID startIndex:(NSString *)start endIndex:(NSString *)end ascending:(BOOL)ascending chatJid:(NSString *)chatJid;








#pragma mark -  返回结果解释

///获取单聊离线消息 (旧方式) 返回结果处理方法
+ (void)parse_IQ_GetSingleChatOfflineMessage:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, BOOL isEmpty, id info))parseResult;

///获取单聊离线消息 (新方式) 返回结果处理方法
+ (void)parse_IQ_GetSingleChatOfflineListDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

///获取单聊离线消息 (新方式) 返回结果处理方法
+ (void)parse_IQ_GetSingleChatOfflineMessageDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;


///获取群聊离线会话列表（旧方式) 返回结果处理方法
+ (void)parse_IQ_GetGroupChatOfflineList:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

///获取群聊离线会话列表（新方式）返回结果处理方法
+ (void)parse_IQ_GetGroupChatOfflineListDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

///获取群聊的离线消息(旧方式) 返回结果处理方法
+ (void)parse_IQ_GetGroupChatOfflineMessage:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, BOOL isEmpty, id info))parseResult;

///获取群聊的离线消息(新方式) 返回结果处理方法
+ (void)parse_IQ_GetGroupChatOfflineMessageDynamics:(XMPPIQ *)iq parseResult:(void (^)(BOOL succeed, id info))parseResult;

@end

NS_ASSUME_NONNULL_END
