//
//  WTProtoOffLineMessage.h
//  WTProtocalKit
//
//  Created by Mark on 2019/12/19.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoOffLineMessageManager;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoIDTracker;

NS_ASSUME_NONNULL_BEGIN


@protocol WTProtoOffLineMessageDelegate

@optional
- (void)WTProtoOffLineMessage:(WTProtoOffLineMessageManager* )protoOffLineMessage
    getSingleChatOfflineMessage_ResultWithSucceed:(BOOL)succeed isEmpty:(BOOL)isEmpty info:(id)info;

- (void)WTProtoOffLineMessage:(WTProtoOffLineMessageManager* )protoOffLineMessage
    getSingleChatOfflineListDynamics_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProtoOffLineMessage:(WTProtoOffLineMessageManager* )protoOffLineMessage
    getSingleChatOfflineMessageDynamics_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProtoOffLineMessage:(WTProtoOffLineMessageManager* )protoOffLineMessage
    getGroupChatOfflineList_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProtoOffLineMessage:(WTProtoOffLineMessageManager* )protoOffLineMessage
    getGroupChatOfflineListDynamics_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProtoOffLineMessage:(WTProtoOffLineMessageManager* )protoOffLineMessage
    getGroupChatOfflineMessage_ResultWithSucceed:(BOOL)succeed isEmpty:(BOOL)isEmpty info:(id)info;

- (void)WTProtoOffLineMessage:(WTProtoOffLineMessageManager* )protoOffLineMessage
    getGroupChatOfflineMessageDynamics_ResultWithSucceed:(BOOL)succeed info:(id)info;

@end

@interface WTProtoOffLineMessageManager : NSObject

@property (nonatomic, strong, readonly)WTProtoStream    *offLineMessageStream;
@property (nonatomic, strong, readonly)WTProtoIDTracker *protoTracker;


+ (void)dellocSelf;

+ (WTProtoQueue *)offLineMessageQueue;

+ (WTProtoOffLineMessageManager *)shareOffLineMessageWithProtoStream:(WTProtoStream *)protoStream
                                                           interface:(NSString *)interface;


- (void)addProtoOffLineMessageDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoOffLineMessageDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoOffLineMessageDelegate:(id)delegate;



/**
 *  获取单聊离线消息 (旧方式)
 *
 *  @param fromUser               来自于谁发出的iq
 *  @param timestamp              消息的时间戳，传空表示从最开始的位置获取
*/
- (void)getSingleChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser timestamp:(NSString *)timestamp;


/**
 *  获取单聊离线会话列表 (新方式) ，返回有离线消息的会话单聊部分的列表

 *
 *  @param fromUser               来自于谁发出的iq
*/
- (void)getSingleChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser;


/**
 *  获取单聊离线消息, 动态拉取单聊离线消息, 与新单聊列表对应使用
 *
 *  @param fromUser               来自于谁发出的iq
 *  @param start                  开始位置自增id
 *  @param end                    结束位置自增id
 *  @param ascending              当startIndexID和endIndexID有传值时 ascending
 *                                的值在后台不起作用，后台会默认从start正序返回离线消息
 *  @param chatJid                会话id/聊天对象JID
*/
- (void)getSingleChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser
                                             startIndex:(NSString *)start
                                               endIndex:(NSString *)end
                                              ascending:(BOOL)ascending
                                                chatJid:(NSString *)chatJid;


/**
 *  获取群聊离线会话列表（旧方式）
 *
 *  @param fromUser               来自于谁发出的iq
*/
- (void)getGroupChatOfflineListWithFromUser:(WTProtoUser *)fromUser;


/**
 *  获取群聊离线会话列表（新方式）
 *
 *  @param fromUser               来自于谁发出的iq
*/
- (void)getGroupChatOfflineListDynamicsWithFromUser:(WTProtoUser *)fromUser;


/**
 *  获取群聊的离线消息(旧方式)
 *
 *  @param fromUser               来自于谁发出iq的jid
 *  @param timestamp              消息的时间戳，传空表示从最开始的位置获取
 *  @param chatJid                会话id/聊天对象JID/群JID
*/
- (void)getGroupChatOfflineMessageWithFromUser:(WTProtoUser *)fromUser
                                     timestamp:(NSString *)timestamp
                                       chatJid:(NSString *)chatJid;



/**
 *  获取群聊的离线消息(新方式)
 *
 *  @param fromUser               来自于谁发出iq的jid
 *  @param start                  开始位置自增id
 *  @param end                    结束位置自增id
 *  @param ascending              当startIndexID和endIndexID有传值时 ascending
 *                                的值在后台不起作用，后台会默认从start正序返回离线消息
 *  @param chatJid                会话id/聊天对象JID/群JID
*/
- (void)getGroupChatOfflineMessageDynamicsWithFromUser:(WTProtoUser *)fromUser
                                            startIndex:(NSString *)start
                                              endIndex:(NSString *)end
                                             ascending:(BOOL)ascending
                                               chatJid:(NSString *)chatJid;

@end

NS_ASSUME_NONNULL_END
