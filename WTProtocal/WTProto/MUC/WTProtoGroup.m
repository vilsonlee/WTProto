//
//  WTProtoGroup.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoGroup.h"

#import "WTProtoQueue.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoMUC.h"
#import "WTProtoRoom.h"
#import "WTProtoGroupPresent.h"
#import "WTProtoGroupIQ.h"
#import "WTProtoIQ.h"
#import "WTProtoIDTracker.h"
#import "NSObject+PerformSelector.h"

#define WEAKSELF                            typeof(self) __weak weakSelf = self;

static WTProtoGroup *protoGroup= nil;
static dispatch_once_t onceToken;

static WTProtoQueue *groupQueue = nil;
static dispatch_once_t queueOnceToken;

@interface WTProtoGroup()<
                           WTProtoStreamDelegate,
                           XMPPMUCDelegate,
                           XMPPRoomDelegate
                         >
{
    WTProtoQueue*  protoGroupQueue;
    GCDMulticastDelegate <WTProtoGroupDelegate> *protoGroupMulticasDelegate;
    NSString* create_room_failure;
}

@property (nonatomic,copy)NSMutableDictionary * IQ_Result_distributie_Dic;

@end

@implementation WTProtoGroup


#pragma mark -- 初始化
+ (WTProtoQueue *)groupQueue{
    
    dispatch_once(&queueOnceToken, ^
    {
        groupQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:group"];
    });
    return groupQueue;
}


+ (void)dellocSelf
{
    protoGroup = nil;
    onceToken = 0l;
    
    groupQueue = nil;
    queueOnceToken = 0l;
}


+ (WTProtoGroup *)shareGroupWithProtoStream:(WTProtoStream *)protoStream
                                  interface:(NSString *)interface
{
    dispatch_once(&onceToken, ^{
        
        protoGroup = [[WTProtoGroup alloc]initGroupWithProtoStream:protoStream
                                                        interface:interface];
           
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
        
       });
    
    return protoGroup;
}


- (instancetype)initGroupWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface
{
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"protoStream should not be nil");
    #endif
    
    if (self = [super init])
    {
        _groupStream = protoStream;
        
        [_groupStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        protoGroupQueue = [WTProtoGroup groupQueue];
        
        protoGroupMulticasDelegate = (GCDMulticastDelegate <WTProtoGroupDelegate> *)[[GCDMulticastDelegate alloc] init];
        
        _protoMUC  = [[WTProtoMUC alloc]initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
        [_protoMUC activate:_groupStream];
        
        [_protoMUC addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
        _protoTracker = [[WTProtoIDTracker alloc] initWithDispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
    }
    return self;
}

///WTProtoRoom 初始化方法
- (WTProtoRoom * )creatRoomWithRoomID:(WTProtoUser *)roomID
{
    WTProtoRoom * protoRoom = [[WTProtoRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance]
                                                                  jid:roomID
                                                        dispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
    return protoRoom;
    
}



- (NSMutableDictionary *)IQ_Result_distributie_Dic{
    
    if (!_IQ_Result_distributie_Dic) {
        _IQ_Result_distributie_Dic = [NSMutableDictionary dictionary];
    }
    return _IQ_Result_distributie_Dic;
}


#pragma mark -- 代理设置
- (void)addProtoGroupDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoGroupQueue dispatchOnQueue:^{
        
        [self->protoGroupMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}


- (void)removeProtoGroupDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoGroupQueue dispatchOnQueue:^{
        
        [self->protoGroupMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}


- (void)removeProtoGroupDelegate:(id)delegate
{
    [protoGroupQueue dispatchOnQueue:^{
        
        [self->protoGroupMulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
}


-(void)IQ_Result_distributieWithSEL:(SEL)sel methodID:(NSString*)methodID fetchID:(NSString *)fetchID{
    NSString * handleSEL = NSStringFromSelector(sel);//结果处理的回调方法
    NSDictionary * infoDict = @{@"methodID":methodID, @"sel":handleSEL};
    [self.IQ_Result_distributie_Dic setObject:infoDict forKey:fetchID];
}


#pragma mark -- 群初始化
- (void)setProtoRoom:(WTProtoRoom * _Nonnull)protoRoom
{
    _protoRoom = protoRoom;
    [_protoRoom addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    [_protoRoom activate:_groupStream];
}

/// 邀请好友入群
-(void)inviteUserChatMembers:(NSArray *)ChatMembers{
    
    
    [_protoRoom inviteUsers:ChatMembers withMessage:@"join in!"];
    
}


- (void)joinRoomWithJid:(WTProtoUser *)jid Nickname:(NSString *)nickname
                                           roomName:(NSString *)roomName
                                        inviteUsers:(NSArray *)inviteUsers
{
    /* 初始化房间 */
    self.protoRoom = [[WTProtoRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:jid dispatchQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
    /* 如果加入的房间在服务器中不存在,则创建,如果存在,就直接加入 */
    NSXMLElement *xml = [[NSXMLElement alloc] initWithXMLString:@"<history maxstanzas='0'/>"error:nil];
    
    [_protoRoom joinRoomUsingNickname:nickname history:xml inviteUsers:inviteUsers roomName:roomName];
    
}

- (void)presenceGroupWithRoomId:(WTProtoUser *)roomID
{
    WTProtoPresence* presenceGroup = [WTProtoGroupPresent presenceGroupWithRoomID:roomID];
    [_groupStream sendElement:(XMPPPresence*)presenceGroup];
}





#pragma mark - 群操作请求IQ -

#pragma mark 获取群(房间)信息
- (void)request_IQ_GetRoomInfoWithRoomID:(WTProtoUser* )roomID
{
    WTProtoIQ* getRoomInfo_IQ = [WTProtoGroupIQ IQ_GetRoomInfoWithRoomID:roomID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetRoomInfo:)
                              methodID:@"GetRoomInfo"
                               fetchID:getRoomInfo_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)getRoomInfo_IQ];
    
    [self addtracker:getRoomInfo_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}

//群(房间)信息请求IQ结果处理
-(void)handeleResult_IQ_GetRoomInfo:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_GetRoomInfo:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf GetRoomInfo_Result:succeed info:Info];
    }];
    
}


#pragma mark 邀请User订阅加入群
- (void)request_IQ_InviteUserSubscribesWithFromUser:(WTProtoUser*)fromUser
                                  RoomID:(WTProtoUser *)roomID
                                roomName:(NSString *)roomName
                                joinType:(NSString *)jointype
                                 Friends:(NSArray *)friends
                         inviterNickName:(NSString *)inviterNickName
                               inviterID:(NSString *)inviterID
                                  reason:(NSString *)reason
{
    
    WTProtoIQ* inviteUser_IQ = [WTProtoGroupIQ IQ_InviteUserSubscribesWithFromUser:fromUser
                                                                           RoomID:roomID
                                                                         roomName:roomName
                                                                         joinType:jointype
                                                                          Friends:friends
                                                                  inviterNickName:inviterNickName
                                                                        inviterID:inviterID
                                                                           reason:reason];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_InviteUserSubscribes:)
                              methodID:@"InviteUserSubscribes"
                               fetchID:inviteUser_IQ.elementID];
    
    
    [_groupStream sendElement:(XMPPIQ*)inviteUser_IQ];
    
    
    [self addtracker:inviteUser_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}
//邀请User订阅加入群 请求IQ结果处理
-(void)handeleResult_IQ_InviteUserSubscribes:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_InviteUserSubscribes:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf InviteUserSubscribes_Result:succeed info:Info];
    }];
    
}


#pragma mark 获取群列表
- (void)request_IQ_GetGroupListByFromUser:(WTProtoUser *)fromUser
{
    WTProtoIQ* getGroupList_IQ = [WTProtoGroupIQ IQ_GetGroupListByFromUser:fromUser];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetGroupList:)
                              methodID:@"GetGroupList"
                               fetchID:getGroupList_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)getGroupList_IQ];
    
    [self addtracker:getGroupList_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}

//获取群列表 请求IQ结果处理
-(void)handeleResult_IQ_GetGroupList:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_GetGroupList:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf GetGroupList_Result:succeed info:Info];
    }];
    
}


#pragma mark 获取订阅成员（成员列表)
- (void)request_IQ_GetGroupMembersListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID
{
    WTProtoIQ* getGroupMembers_IQ = [WTProtoGroupIQ IQ_GetGroupMembersListWithFromUser:fromUser
                                                                                RoomID:roomID];
    
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetGroupMembersList:)
                              methodID:@"GetGroupMembersList"
                               fetchID:getGroupMembers_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)getGroupMembers_IQ];
    
    [self addtracker:getGroupMembers_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark 取消订阅（退群）
- (void)request_IQ_ExitUserSubscribesWithFromUser:(WTProtoUser *)fromUser
                                           RoomID:(WTProtoUser *)roomID
                                         roomName:(NSString *)roomName
                                      roomOwnerID:(WTProtoUser *)roomOwnerID
                              memberGroupNickName:(NSString *)nickName
{
    WTProtoIQ* exitUser_IQ = [WTProtoGroupIQ IQ_ExitUserSubscribesWithFromUser:fromUser
                                                                               RoomID:roomID
                                                                             roomName:roomName
                                                                          roomOwnerID:roomOwnerID
                                                                  memberGroupNickName:nickName];
    [_groupStream sendElement:(XMPPIQ*)exitUser_IQ];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_ExitUserSubscribes:)
                              methodID:@"ExitUserSubscribes"
                               fetchID:exitUser_IQ.elementID];
    
    [self addtracker:exitUser_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}


#pragma mark 移出群（管理员踢人,多人）
- (void)request_IQ_RemoveMemberUnscribesChatRoomWithFromUser:(WTProtoUser *)fromUser
                                                      RoomID:(WTProtoUser *)roomID
                                                    roomName:(NSString *)roomName
                                                 roomOwnerID:(WTProtoUser *)roomOwnerID
                                         memberGroupNickName:(NSString *)nickName
                                                     Friends:(NSArray *)friends
{
    
    WTProtoIQ* removeMember_IQ = [WTProtoGroupIQ IQ_RemoveMemberUnscribesChatRoomWithFromUser:fromUser
                                                                                       RoomID:roomID
                                                                                     roomName:roomName
                                                                                  roomOwnerID:roomOwnerID
                                                                          memberGroupNickName:nickName
                                                                                      Friends:friends];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_RemoveMemberUnscribesChatRoom:)
                              methodID:@"RemoveMemberUnscribesChatRoom"
                               fetchID:removeMember_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)removeMember_IQ];
    
    [self addtracker:removeMember_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark 保存群到通讯录
- (void)request_IQ_SaveGroupToContactListWithFromUser:(WTProtoUser *)fromUser
                                              RoomJid:(WTProtoUser *)roomID
                                                state:(BOOL)state
{
    
    WTProtoIQ* saveGroupToContactList_IQ = [WTProtoGroupIQ IQ_SaveGroupToContactListWithFromUser:fromUser
                                                                                         RoomJid:roomID
                                                                                           state:state];
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SaveGroupToContactList:)
                              methodID:@"SaveGroupToContactList"
                               fetchID:saveGroupToContactList_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)saveGroupToContactList_IQ];
    
    [self addtracker:saveGroupToContactList_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark 消息免打扰
- (void)request_IQ_UnDisturbWithFromUser:(WTProtoUser *)fromUser
                       RoomID:(WTProtoUser *)roomID
                        state:(BOOL)state
{
    WTProtoIQ* unDistur_IQ = [WTProtoGroupIQ IQ_UnDisturbWithFromUser:fromUser RoomID:roomID state:state];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_UnDisturb:)
                              methodID:@"UnDisturb"
                               fetchID:unDistur_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)unDistur_IQ];
    
    [self addtracker:unDistur_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark 修改我的群昵称
- (void)request_IQ_ModifyRoomNickNameWithFromUser:(WTProtoUser *)fromUser
                                           RoomID:(WTProtoUser *)roomID
                                         nickname:(NSString *)newNickname
                                       changeflag:(NSInteger)changeflag
{
    WTProtoIQ* modifyRoomNickName_IQ = [WTProtoGroupIQ IQ_ModifyRoomNickNameWithFromUser:fromUser
                                                                                  RoomID:roomID
                                                                                nickname:newNickname
                                                                              changeflag:changeflag];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_ModifyRoomNickName:)
                              methodID:@"ModifyRoomNickName"
                               fetchID:modifyRoomNickName_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)modifyRoomNickName_IQ];
    
    [self addtracker:modifyRoomNickName_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}



#pragma mark 群主权限转让
- (void)request_IQ_ExChangeGroupOwnerAuthorityWithFromUser:(WTProtoUser *)fromUser
                                                    RoomID:(WTProtoUser *)roomID
                                               newOwernick:(NSString *)newOwernick
                                                 newOwerID:(WTProtoUser *)newOwerID
{
    WTProtoIQ* exChangeGroup_IQ = [WTProtoGroupIQ IQ_ExChangeGroupOwnerAuthorityWithFromUser:fromUser
                                                                                      RoomID:roomID
                                                                                 newOwernick:newOwernick
                                                                                   newOwerID:newOwerID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_ExChangeGroupOwnerAuthority:)
                              methodID:@"ExChangeGroupOwnerAuthority"
                               fetchID:exChangeGroup_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)exChangeGroup_IQ];
    
    [self addtracker:exChangeGroup_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}


#pragma mark 群管理员设置
- (void)request_IQ_SetGroupAdminWithFromUser:(WTProtoUser *)fromUser
                                    Memebers:(NSArray *)member
                                     roomJid:(WTProtoUser *)roomJid
                                       style:(NSString *)style
{
    WTProtoIQ* setGroupAdmin_IQ = [WTProtoGroupIQ IQ_SetGroupAdminWithFromUser:fromUser
                                                                      Memebers:member
                                                                       roomJid:roomJid
                                                                         style:style];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SetGroupAdmin:)
                              methodID:@"SetGroupAdmin"
                               fetchID:setGroupAdmin_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)setGroupAdmin_IQ];
    
    
    [self addtracker:setGroupAdmin_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}



#pragma mark 获取退群成员列表
- (void)request_IQ_GetGroupQuiteMemberListWithFromUser:(WTProtoUser *)fromUser
                                     RoomID:(WTProtoUser *)roomID
{
    
    WTProtoIQ* getGroupQuiteMemberList_IQ = [WTProtoGroupIQ IQ_GetGroupQuiteMemberListWithFromUser:fromUser
                                                                                            RoomID:roomID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetGroupQuiteMemberList:)
                              methodID:@"GetGroupQuiteMemberList"
                               fetchID:getGroupQuiteMemberList_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)getGroupQuiteMemberList_IQ];

    [self addtracker:getGroupQuiteMemberList_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark 设置群禁言
- (void)request_IQ_SetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser
                                                 RoomID:(WTProtoUser *)roomID
                                               memebers:(NSArray *)member
                                               nickName:(NSString *)nickName
                                                  style:(NSString *)style
{
    
    WTProtoIQ* setGroupBannedMemberList_IQ = [WTProtoGroupIQ IQ_SetGroupBannedMemberListWithFromUser:fromUser
                                                                                              RoomID:roomID
                                                                                            memebers:member
                                                                                            nickName:nickName
                                                                                               style:style];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SetGroupBannedMemberList:)
                              methodID:@"SetGroupBannedMemberList"
                               fetchID:setGroupBannedMemberList_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)setGroupBannedMemberList_IQ];
    
    [self addtracker:setGroupBannedMemberList_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}


#pragma mark 设置群全员禁言
- (void)request_IQ_SetGroupBannedAllWithFromUser:(WTProtoUser *)fromUser
                               RoomID:(WTProtoUser *)roomID
                             nickName:(NSString *)nickName
                                style:(NSString *)style
{
    WTProtoIQ* setGroupBannedAll_IQ = [WTProtoGroupIQ IQ_SetGroupBannedAllWithFromUser:fromUser
                                                                                RoomID:roomID
                                                                              nickName:nickName
                                                                                 style:style];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SetGroupBannedAll:)
                              methodID:@"SetGroupBannedAll"
                               fetchID:setGroupBannedAll_IQ.elementID];
    
    
    [_groupStream sendElement:(XMPPIQ*)setGroupBannedAll_IQ];
    
    [self addtracker:setGroupBannedAll_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark 获取群禁言名单
- (void)request_IQ_GetGroupBannedMemberListWithFromUser:(WTProtoUser *)fromUser RoomID:(WTProtoUser *)roomID
{
    
    WTProtoIQ* getGroupBannedMemberList_IQ = [WTProtoGroupIQ IQ_GetGroupBannedMemberListWithFromUser:fromUser
                                                                              RoomID:roomID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetGroupBannedMemberList:)
                              methodID:@"GetGroupBannedMemberList"
                               fetchID:getGroupBannedMemberList_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)getGroupBannedMemberList_IQ];
    
    [self addtracker:getGroupBannedMemberList_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark 获取活跃度群成员
- (void)request_IQ_GetGroupActivityMemberWithFromUser:(WTProtoUser *)fromUser
                                               RoomID:(WTProtoUser *)roomID
                                         activityTime:(NSString *)activityTime
{

    WTProtoIQ* getGroupActivityMember_IQ = [WTProtoGroupIQ IQ_GetGroupActivityMemberWithFromUser:fromUser
                                                                                          RoomID:roomID
                                                                                    activityTime:activityTime];
    
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetGroupActivityMember:)
                              methodID:@"GetGroupActivityMember"
                               fetchID:getGroupActivityMember_IQ.elementID];
    
    [_groupStream sendElement:(XMPPIQ*)getGroupActivityMember_IQ];
    
    [self addtracker:getGroupActivityMember_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}


#pragma mark 设置陌生人备注
- (void)request_IQ_SetGroupMemberRemarkNameWithFromUser:(WTProtoUser *)fromUser
                                                 RoomID:(WTProtoUser *)roomID
                                               memberID:(WTProtoUser *)memberID
                                               noteName:(NSString *)name
{
    
    WTProtoIQ* setGroupMemberRemarkName_IQ = [WTProtoGroupIQ IQ_SetGroupMemberRemarkNameWithFromUser:fromUser
                                                                                              RoomID:roomID
                                                                                            memberID:memberID
                                                                                            noteName:name];
    [_groupStream sendElement:(XMPPIQ*)setGroupMemberRemarkName_IQ];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SetGroupMemberRemarkName:)
                              methodID:@"SetGroupMemberRemarkName"
                               fetchID:setGroupMemberRemarkName_IQ.elementID];
    
    [self addtracker:setGroupMemberRemarkName_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
}


#pragma mark - 群操作请求IQ结果处理





-(void)handeleResult_IQ_GetGroupMembersList:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_GetGroupMembersList:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf GetGroupMembersList_Result:succeed info:Info];
    }];
    
}


-(void)handeleResult_IQ_ExitUserSubscribes:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_ExitUserSubscribes:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf ExitUserSubscribes_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_RemoveMemberUnscribesChatRoom:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_RemoveMemberUnscribesChatRoom:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf RemoveMemberUnscribesChatRoom_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_SaveGroupToContactList:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_SaveGroupToContactList:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf SaveGroupToContactList_Result:succeed info:Info];
    }];
    
}


-(void)handeleResult_IQ_UnDisturb:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_UnDisturb:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf UnDisturb_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_ModifyRoomNickName:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_ModifyRoomNickName:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf ModifyRoomNickName_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_ExChangeGroupOwnerAuthority:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_ExChangeGroupOwnerAuthority:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf ExChangeGroupOwnerAuthority_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_SetGroupAdmin:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_SetGroupAdmin:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf SetGroupAdmin_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_GetGroupQuiteMemberList:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_GetGroupQuiteMemberList:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf GetGroupQuiteMemberList_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_SetGroupBannedMemberList:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_SetGroupBannedMemberList:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf SetGroupBannedMemberList_Result:succeed info:Info];
    }];
    
}

-(void)handeleResult_IQ_SetGroupBannedAll:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_SetGroupBannedAll:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf SetGroupBannedAll_Result:succeed inf:Info];
    }];
    
}


-(void)handeleResult_IQ_GetGroupBannedMemberList:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_GetGroupBannedMemberList:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf GetGroupBannedMemberList_Result:succeed info:Info];
    }];
    
}


-(void)handeleResult_IQ_GetGroupActivityMember:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_GetGroupActivityMember:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf GetGroupActivityMember_Result:succeed info:Info];
    }];
    
}


-(void)handeleResult_IQ_SetGroupMemberRemarkName:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoGroupIQ parse_IQ_SetGroupMemberRemarkName:iq parseResult:^(BOOL succeed, id  _Nonnull Info) {
        [self->protoGroupMulticasDelegate WTProtoGroup:weakSelf SetGroupMemberRemarkName_Result:succeed info:Info];
    }];
    
}


#pragma mark -- 群配置信息修改
///群邀请确认 flag: @"0",关闭 @"1" 开启
- (void)setGroupConfigInviteConfirmWithFlag:(NSString *)flag roomID:(WTProtoUser *)roomID
{
    
    self.protoRoom = [self creatRoomWithRoomID:roomID];
    
    [_protoRoom setGroupConfigInviteConfirmWithFlag:flag];
    
}

///群定时销毁开启状态 time>0 开启
- (void)setGroupConfigdestoryWithTime:(NSInteger)time roomID:(WTProtoUser *)roomID
{

    self.protoRoom = [self creatRoomWithRoomID:roomID];
    
    [_protoRoom setGroupConfigdestoryWithTime:time];
    
}

//群截屏通知 muc#roomconfig_screenshotsnotify flag: @"0"：关闭， @"1"：开启
- (void)setGroupConfigScreenshotsnotify:(NSString *)flag roomID:(WTProtoUser *)roomID
{
    self.protoRoom = [self creatRoomWithRoomID:roomID];
    [_protoRoom setGroupConfigScreenshotsnotify:flag];
}

///禁止私聊 muc#roomconfig_no_private_chat flag: @"0"：关闭， @"1"：开启
- (void)setGroupConfigPrivateChatFlag:(NSString *)flag roomID:(WTProtoUser *)roomID
{
    self.protoRoom = [self creatRoomWithRoomID:roomID];
    [_protoRoom setGroupConfigPrivateChatFlag:flag];
}

///群名称修改
- (void)setGroupConfigGroupName:(NSString *)title roomID:(WTProtoUser *)roomID
{
    self.protoRoom = [self creatRoomWithRoomID:roomID];
    [_protoRoom setGroupConfigGroupName:title];
}

///群头像更新, updateTime: 更新的时间戳
- (void)setGroupConfigGroupIcon:(NSString *)updateTime roomID:(WTProtoUser *)roomID
{
    self.protoRoom = [self creatRoomWithRoomID:roomID];
    [_protoRoom setGroupConfigGroupIcon:updateTime];
}

///群公告修改
- (void)setGroupConfigGroupDescription:(NSString *)desc roomID:(WTProtoUser *)roomID
{
    self.protoRoom = [self creatRoomWithRoomID:roomID];
    [_protoRoom setGroupConfigGroupDescription:desc];
}
    


#pragma mark -  xmppRoom delegate


#pragma mark -- 创建群


- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    
    [sender fetchConfigurationForm];

    [protoGroupMulticasDelegate WTProtoGroup:self RoomDidCreate:sender];
    
}


- (void)xmppRoomDidCreateFail:(XMPPRoom *)sender code:(NSInteger)code
{
    [protoGroupMulticasDelegate WTProtoGroup:self RoomDidCreateFail:sender info:create_room_failure];
}


#pragma mark -- 加入群
- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    _protoRoom = sender;
    
}


#pragma mark -  邀请好友入群
//........

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(nonnull XMPPIQ *)iqResult
{
    [protoGroupMulticasDelegate WTProtoGroup:self RoomDidConfigure:sender iqResult:iqResult];
}


- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(nonnull XMPPIQ *)iqResult
{
    [protoGroupMulticasDelegate WTProtoGroup:self RoomDidNotConfigure:sender iqResult:iqResult];
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(nonnull DDXMLElement *)configForm
{
    WTProtoRoom* WTRoom = [WTProtoRoom initWithXMPPRoom:sender];
    
    [WTRoom configNewRoom];
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(nonnull NSArray *)items
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(nonnull XMPPIQ *)iqError
{
    
    
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(nonnull XMPPIQ *)iqError
{
    
}

#pragma mark -  解散群
- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    
    
}


#pragma mark -  XMPPStream Presence delegate

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{

    if (presence.isErrorPresence) {
        
        if ([presence elementForName:@"create_failure"]) {
           create_room_failure = [[presence elementForName:@"create_failure"] attributeStringValueForName:@"reason"];
        }
    }
}


-(void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(nonnull XMPPPresence *)presence error:(nonnull NSError *)error{
    
}



- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(nonnull XMPPIQ *)iq
{
    
    NSString *outgoingStr = [iq compactXMLString];
    
    NSLog(@"%s___%d",__FUNCTION__,__LINE__);
    NSLog(@"\n\n didReceiveIQ = %@ \n\n",outgoingStr);
    
    NSString * elementID = iq.elementID;
    
    if (elementID == nil) {
        return YES;
    }
    
    [_protoTracker invokeForID:elementID withObject:iq];
    
    if ([self.IQ_Result_distributie_Dic objectForKey:elementID]) {
        
        NSDictionary * dict = [self.IQ_Result_distributie_Dic objectForKey:elementID];
        
        if ([dict objectForKey:@"sel"])
        {
            SEL sel = NSSelectorFromString([dict objectForKey:@"sel"]);
            if ([self respondsToSelector:sel])
            {
                 [self performSelector:sel withObjects:@[iq]];
            }
        }
        else
        {
            
        }
    }
    
    return YES;
}


- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSLog(@"\n\n didFailToSendIQ %s___%d error = %@\n\n",__FUNCTION__,__LINE__,error);
    [iq addChild:[XMPPElement elementWithName:@"error" stringValue:error.description]];
    [iq addAttributeWithName:@"type" stringValue:@"error"];
    [self xmppStream:sender didReceiveIQ:iq];
}

#pragma mark - 超时设置
- (void)addtracker:(WTProtoIQ *)iq timeout:(NSTimeInterval)timeout
{
    XMPPElement *element =(XMPPElement *)iq;
    
    [_protoTracker addElement:element target:self selector:@selector(IQsendTimeout:withInfo:) timeout:timeout];
}

- (void)IQsendTimeout:(DDXMLElement *)element withInfo:(XMPPBasicTrackingInfo*)trackerInfo
{
    if (!element) {
        NSLog(@"发送超时");
        //trackerInfo.element
        if ([trackerInfo.element isKindOfClass:[XMPPIQ class]] ||
            [trackerInfo.element isKindOfClass:[WTProtoIQ class]])
        {
            //iq请求发送超时 FIXIME:调整error
            NSError *error = [NSError errorWithDomain:@"发送超时" code:0 userInfo:nil];
            [self xmppStream:_groupStream didFailToSendIQ:(WTProtoIQ *)trackerInfo.element error:error];
        }
    }
}


@end
