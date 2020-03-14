//
//  WTProto.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/10/31.
//  Copyright © 2019 Vilson. All rights reserved.
//

/**
 * WTProtocol re-encapsulates the XMPP communication protocol based on XMPPFramework.
 * WTProto is the most core class that manager the all the XMPP communication.
**/


#import <Foundation/Foundation.h>

@class WTProto;
@class WTProtoLogging;
@class WTProtoQueue;
@class WTProtoUser;
@class WTProtoStream;
@class WTProtoStreamManager;
@class WTProtoServerAddress;
@class WTProtoConnection;
@class WTProtoRegister;
@class WTProtoAuth;
@class WTProtoReConnection;
@class WTProtoBlock;
@class WTProtoPing;
@class WTProtoRosters;
@class WTProtoContact;
@class WTProtoGroup;
@class WTProtoUserConfigService;
@class WTProtoMessageCenter;
@class WTProtoConversationMessage;
@class WTProtoWebRTCMessage;
@class WTProtoShakeMessage;
@class WTProtoshakedResultMessage;
@class WTProtoUserInfoService;
@class XMPPMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoDelegate

@optional

#pragma mark - WTProto Connection
- (void)WTProtoConnecting:(WTProto* )wtProto;
- (void)WTProtoConnected:(WTProto* )wtProto;
- (void)WTProtoDisconnected:(WTProto* )wtProto Error:(NSError *)error;
- (void)WTProtoConnectTimeout:(WTProto* )wtProto;
- (void)WTProtoConnectFailed:(WTProto* )wtProto Error:(NSError *)error;


#pragma mark - WTProto Register
- (void)WTProtoUserRegisterCheck:(WTProto* )wtProto;
- (void)WTProtoUserRegisterStart:(WTProto* )wtProto;
- (void)WTProtoUserRegisterAlready:(WTProto* )wtProto;
- (void)WTProtoUserRegisterNone:(WTProto* )wtProto;
- (void)WTProtoUserRegisterSuccess:(WTProto* )wtProto;
- (void)WTProtoUserRegisterFail:(WTProto* )wtProto Error:(NSError *)error;


#pragma mark - WTProto Authenticat
- (void)WTProtoUserAuthenticatStart:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticated:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticateFail:(WTProto* )wtProto Error:(NSError *)error;


#pragma mark - WTProto Authenticat Get Verifi Code
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeSuccess:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeFail:(WTProtoAuth* )protoAuth
                                                              Error:(NSError *)error;

- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeSeclimit:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeDaylimit:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeNoTFound:(WTProtoAuth* )protoAuth;
- (void)WTProto:(WTProto* )wtProto UserAuthenticatGetVerifiCodeError:(WTProtoAuth* )protoAuth;


#pragma mark - WTProto Authenticat Check Verifi Code
- (void)WTProtoUserAuthenticatCheckVerifiCodeSuccess:(WTProto* )wtProto VerifiUser:(WTProtoUser*)user;
- (void)WTProtoUserAuthenticatCheckVerifiCodeExpire:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckVerifiCodeFail:(WTProto* )wtProto Error:(NSError *)error;;
- (void)WTProtoUserAuthenticatCheckVerifiCodeNotFound:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckVerifiCodeUpdateError:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckUserNotFound:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticatCheckUnsupportedMechanism:(WTProto* )wtProto;

#pragma mark - WTProto Authenticat Need
- (void)WTProtoUserAuthenticateNeedUpgrade:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticateNeedVerifiCode:(WTProto* )wtProto;
- (void)WTProtoUserAuthenticateInvalidUser:(WTProto* )wtProto;



#pragma mark - WTProto message Receive
- (void)WTProto:(WTProto*)wtProto didReceiveConversationDecryptMessage:(WTProtoConversationMessage *)decryptMessage
                                                       OriginalMessage:(XMPPMessage *)originalMessage;

- (void)WTProto:(WTProto*)wtProto didReceiveWebRTCDecryptMessage:(WTProtoWebRTCMessage *)decryptMessage
                                                 OriginalMessage:(XMPPMessage *)originalMessage;


- (void)WTProto:(WTProto*)wtProto didReceiveShakeDecryptMessage:(WTProtoShakeMessage *)decryptMessage
                                                OriginalMessage:(XMPPMessage *)originalMessage;


- (void)WTProto:(WTProto*)wtProto didReceiveShakeResultDecryptMessage:(WTProtoshakedResultMessage *)decryptMessage
                                                      OriginalMessage:(XMPPMessage *)originalMessage;



#pragma mark - WTProto Contact
- (void)WTProto:(WTProto*)wtProto getContacts_ResultWithSucceed:(BOOL)succeed
                                                     matchcount:(NSUInteger)matchcount
                                                           info:(id)info;

- (void)WTProto:(WTProto*)wtProto getContactDetails_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto setFriend_MemoName_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto setFriend_StarMark_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (BOOL)WTProto:(WTProto*)wtProto isExistFriendJid:(NSString *)jid;

- (void)WTProto:(WTProto* )wtProto newContact:(NSDictionary *)contactInfo isWaitPass:(BOOL)isWaitPass;

- (void)WTProto:(WTProto*)wtProto addFriend_ResultWithSucceed:(BOOL)succeed jid:(NSString *)jid;

- (void)WTProto:(WTProto*)wtProto agreeAddFriend_ResultWithSucceed:(BOOL)succeed jid:(NSString *)jid;

- (void)WTProto:(WTProto*)wtProto deleteFriend_ResultWithSucceed:(BOOL)succeed jid:(NSString *)jid;


#pragma mark - WTProto Group
- (void)WTProto:(WTProto*)wtProto getGroups_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto getGroupInfo_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto RoomDidCreate_ResultWithSucceed:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto inviteUserSubscribes_Result:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto getGroupMembersList_Result:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto exitUserSubscribes_Result:(BOOL)succeed info:(id)info;

- (void)WTProto:(WTProto*)wtProto removeMemberUnscribesChatRoom_Result:(BOOL)succeed info:(id)info;

#pragma mark - WTProto UserInfo
- (void)WTProto:(WTProto*)wtProto SearchUserInfoWithResult:(BOOL)result UserInfo:(NSDictionary *)userInfo;


#pragma mark - WTProto UserConfig Service
-(void)WTProto:(WTProto*)wtProto getUserPerferenceResult:(BOOL)result info:(id)info;

-(void)WTProto:(WTProto*)wtProto getUserChatSettingResult:(BOOL)result info:(id)info;
    
-(void)WTProto:(WTProto*)wtProto updateUserConfigResult:(BOOL)result info:(id)info;

-(void)WTProto:(WTProto*)wtProto updateUserChatSettingResult:(BOOL)result info:(id)info;

-(void)WTProto:(WTProto*)wtProto removeUserChatSettingResult:(BOOL)result info:(id)info;

@end


typedef NS_ENUM(NSUInteger, WTProtoMessageEncryptionType) {
    WTProtoMessageEncryptionAES     = 0,      //AES
    WTProtoMessageEncryptionOTR,              //OTR
    WTProtoMessageEncryptionOMEMO,            //OMEMO
};


typedef NS_ENUM(NSUInteger, WTProtoOnlineStatus) {
    WTProtoOnlineStatusAway                = 0,      //away   -- 实体或资源临时离开.
    WTProtoOnlineStatusChat,                         //chat   -- 实体或资源在聊天中是激活的.
    WTProtoOnlineStatusDoNotDisturb,                 //dnd    -- 实体或资源是忙(dnd = "不要打扰").
    WTProtoOnlineStatusExtendedAway                  //xa     -- 实体或资源是长时间的离开(xa = "长时间离开").
};

typedef NS_ENUM(NSUInteger, WTProtoOnlinePriority) {
    WTProtoOnlinePriorityLow                = 0,      //away   -- 实体或资源临时离开.
    WTProtoOnlinePriorityMedium,                      //chat   -- 实体或资源在聊天中是激活的.
    WTProtoOnlinePriorityHigh,                        //dnd    -- 实体或资源是忙(dnd = "不要打扰").
};


//获取联系人详情方式的类型
typedef NS_ENUM(NSUInteger, WTGetContactDetailsKeyType) {
    WTGetContactDetailsKeyType_SELF               = 0,      //查询自己的信息
    WTGetContactDetailsKeyType_Phone,                       //联系人的 手机号 （带区号）
    WTGetContactDetailsKeyType_ID,                          //联系人设置的 wChatid
    WTGetContactDetailsKeyType_JID,                         //联系人的 jid
    WTGetContactDetailsKeyType_QRcode                       //联系人的 个人二维码
};

@interface WTProto : NSObject

@property (nonatomic, strong, readonly)WTProtoUser                  *protoUser;
@property (nonatomic, strong, readonly)WTProtoStream                *protoStream;
@property (nonatomic, strong, readonly)WTProtoServerAddress         *serverAddress;
@property (nonatomic, strong, readonly)WTProtoStreamManager         *proStreamManager;
@property (nonatomic, strong, readonly)WTProtoConnection            *protoConnection;
@property (nonatomic, strong, readonly)WTProtoRegister              *protoRegister;
@property (nonatomic, strong, readonly)WTProtoAuth                  *protoAuth;
@property (nonatomic, strong, readonly)WTProtoReConnection          *protoReConnection;
@property (nonatomic, strong, readonly)WTProtoBlock                 *protoBlock;
@property (nonatomic, strong, readonly)WTProtoPing                  *protoPing;
@property (nonatomic, strong, readonly)WTProtoRosters               *protoRosters;
@property (nonatomic, strong, readonly)WTProtoGroup                 *protoGroup;
@property (nonatomic, strong, readonly)WTProtoMessageCenter         *protoMessageCenter;
@property (nonatomic, strong, readonly)WTProtoContact               *protoContact;
@property (nonatomic, strong, readonly)WTProtoUserInfoService       *protoUserInfoService;
@property (nonatomic, strong, readonly)WTProtoUserConfigService     *protoUserConfigService;



+ (void)dellocSelf;


+ (WTProtoQueue *)ProtoQueue;


+ (WTProto *)shareWTProtoDomain:(NSString *)domain Resource:(NSString *)resource;


+ (WTProto *)shareWTProtoPhoneNumber:(NSString *)phoneNumber
                              Domain:(NSString *)domain
                            Resource:(NSString *)resource;


+ (WTProto *)shareWTProtoUserID:(NSString *)UserID
                         Domain:(NSString *)domain
                       Resource:(NSString *)resource
                       Password:(NSString *)password;


-(void)ProtoResetProtoUserWithUserID:(NSString *)userID
                            password:(NSString *)password
                            UserType:(NSInteger)userType
                       loginAuthType:(NSInteger)loginAuthType;


- (void)addWTProtoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeWTProtoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeWTProtoDelegate:(id)delegate;



- (void)Start;

- (void)Stop;

- (void)ProtoCheckUser;

- (void)ProtoRegisterUserWithNickName:(NSString *)nickName CountrieName:(NSString *)countrieName;

- (void)ProtoGetVerifiCodeWithRegister:(WTProtoRegister *)protoRegister;

- (void)ProtoGotoCheckVerifiCodeWithAuth:(WTProtoAuth *)protoAuth VerifiCode:(NSString*)verifiCode;

- (void)ProtoDellocFuctionModule;

- (void)ProtoOnlineState:(WTProtoOnlineStatus)onlineStatus
                  status:(NSString *)status
                priority:(WTProtoOnlinePriority)priority
                  device:(NSString *)device;

-(void)ProtoSearchUserInfoWithLocalUser:(WTProtoUser*)localUser
                                KeyWord:(NSString *)key
                                keyType:(NSString *)type
                        searchFromGroup:(BOOL)fromGroup;


-(void)sendWTProtoConversationMessage:(WTProtoConversationMessage *)message
                       encryptionType:(WTProtoMessageEncryptionType)encryptionType
                           sendResult:(void (^)(BOOL succeed , WTProtoConversationMessage *sendmessage))sendResult;


-(void)sendWTProtoWebRTCMessage:(WTProtoWebRTCMessage *)message
                 encryptionType:(WTProtoMessageEncryptionType)encryptionType
                     sendResult:(void (^)(BOOL succeed, WTProtoWebRTCMessage * sendmessage))sendResult;


-(void)sendWTProtoShakeMessage:(WTProtoShakeMessage *)message
                encryptionType:(WTProtoMessageEncryptionType)encryptionType
                    sendResult:(void (^)(BOOL succeed, WTProtoShakeMessage * sendmessage))sendResult;


-(void)sendWTProtoShakeResultMessage:(WTProtoshakedResultMessage *)message
                      encryptionType:(WTProtoMessageEncryptionType)encryptionType
                          sendResult:(void (^)(BOOL succeed, WTProtoshakedResultMessage * sendmessage))sendResult;

- (void)Ack:(XMPPMessage*)message;

- (void)ReadAckToID:(NSString *)toID IncrementID:(NSInteger)incrementID;

//通讯录联系人相关方法
- (void)getContactsWithMatchableContacts:(NSArray *)matchableContacts phoneCode:(NSString *)phoneCode type:(NSString *)emptyType nickName:(NSString *)nickName userPhone:(NSString *)userPhone;

- (void)getUserDetailWithKeyWord:(NSString *)key keyType:(WTGetContactDetailsKeyType)type searchFromGroup:(BOOL)fromGroup source:(NSString *)source IPAddress:(NSString *)IPAddress;

- (void)setFriend_MemoName:(NSString *)memoName jid:(NSString *)jidstr;

- (void)setFriend_StarMarkWithJid:(NSString *)jidstr straState:(BOOL)state;

- (void)deleteFriendWithJid:(NSString *)jidStr;

- (void)agreeAddFriendWithJid:(NSString *)jidStr source:(NSString *)source;

- (void)addFriendWithJid:(NSString *)jidStr source:(NSString *)source verify:(NSString *)verify time:(NSString *)time statusInfo:(NSDictionary *)statusInfo;

//群聊列表相关方法
- (void)getGroupList;

- (void)getGroupInfoWithGroupJid:(WTProtoUser *)groupJId;

//创建群
- (void)createGroupWithGroupJid:(WTProtoUser *)groupJid groupName:(NSString *)groupName ownerNickName:(NSString *)ownerNickName inviteUsers:(NSArray *)inviteUsers;

//邀请进群
- (void)invitaFriendsSubscribesGroupWithGroupid:(WTProtoUser *)groupJId groupName:(NSString *)groupName joinType:(NSString *)jointype andFriends:(NSArray *)friends inviterNickName:(NSString *)inviterNickName inviterJID:(NSString *)inviterJid reason:(NSString *)reason;

- (void)getMemberListWithRoomJid:(WTProtoUser *)groupJId bringMemoName:(BOOL)bringMemoName;

- (void)exitGroupWithRoomJid:(WTProtoUser *)groupJId roomName:(NSString *)roomName roomOwnerJid:(WTProtoUser *)roomOwnerJid memberGroupNickName:(NSString *)nickName;

- (void)removeMemberUnscribesChatRoomWithRoomJid:(WTProtoUser *)groupJId roomName:(NSString *)roomName roomOwnerJid:(WTProtoUser *)roomOwnerJid memberGroupNickName:(NSString *)nickName andFriends:(NSArray *)friends;

//用户配置相关方法
/**
 *  获取用户偏好设置
*/
- (void)getUserPerferenceInfo;

/**
 *  获取用户聊天设置
*/
- (void)getUserChatSettingInfo;

/**
 *  更新用户偏好设置
*/
- (void)updateUserConfigWithDict:(NSDictionary *)data;

/**
 *  更新用户聊天配置
*/
- (void)updateUserChatSettingWithDict:(NSDictionary *)data;

/**
 *  移除用户聊天配置
*/
- (void)removeUserChatSettingWithDict:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
