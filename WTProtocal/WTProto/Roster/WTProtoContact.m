//
//  WTProtoContact.m
//  WTProtocalKit
//
//  Created by Mark on 2020/1/2.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import "WTProtoContact.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoQueue.h"
#import "WTProtoTimer.h"
#import "WTProtoIQ.h"
#import "WTProtoPresence.h"
#import "WTProtoContactIQ.h"
#import "WTProtoContactPresent.h"
#import "NSObject+PerformSelector.h"
#import "WTProtoIDTracker.h"
#import "WTProtoTrackerManager.h"
#import "WTProtoRoster.h"
#import "WTProtoRosterCoreDataStorage.h"

#define WEAKSELF                            typeof(self) __weak weakSelf = self;

static WTProtoContact *protoContact = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *contactQueue = nil;
static dispatch_once_t queueOnceToken;

@interface WTProtoContact () <
                                WTProtoStreamDelegate,
                                WTProtoTrackerManagerDelegate,
                                XMPPRosterDelegate
                             >
{
    
    WTProtoQueue                                           *protoContactQueue;
    GCDMulticastDelegate <WTProtoContactDelegate>          *protoContactMulticasDelegate;
    
    WTProtoTrackerManager *trackerManager;
}

@property (nonatomic,copy)NSMutableDictionary * IQ_Result_distributie_Dic;

@end


@implementation WTProtoContact

- (NSMutableDictionary *)IQ_Result_distributie_Dic{
    
    if (!_IQ_Result_distributie_Dic) {
        _IQ_Result_distributie_Dic = [NSMutableDictionary dictionary];
    }
    return _IQ_Result_distributie_Dic;
}

+ (void)dellocSelf{
    protoContact = nil;
    onceToken = 0l;
    
    contactQueue = nil;
    queueOnceToken = 0l;
}

+ (WTProtoQueue *)contactQueue{
    dispatch_once(&queueOnceToken, ^
    {
        contactQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:contact"];
    });
    return contactQueue;
}

+ (WTProtoContact *)shareContactWithProtoStream:(WTProtoStream *)protoStream
                                                    interface:(NSString *)interface{
    dispatch_once(&onceToken, ^{
        
        protoContact = [[WTProtoContact alloc] initContactWithProtoStream:protoStream
                                                        interface:interface];
           
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
        
       });
    
    return protoContact;
}


- (instancetype)initContactWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface
{
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"protoStream should not be nil");
    #endif
    
    if (self = [super init])
    {
        _contactStream = protoStream;
        
        [_contactStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        protoContactQueue = [WTProtoContact contactQueue];
        
        protoContactMulticasDelegate = (GCDMulticastDelegate <WTProtoContactDelegate> *)[[GCDMulticastDelegate alloc] init];
    
        trackerManager = [[WTProtoTrackerManager alloc]initTrackerManager];
        [trackerManager addProtoTrackerDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
        _ProtoRoster = [[WTProtoRoster alloc]initWithRosterStorage:[[XMPPRosterCoreDataStorage alloc]init]];
        _ProtoRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
        _ProtoRoster.autoFetchRoster = YES;
        
        [_ProtoRoster activate:_contactStream];
        [_ProtoRoster addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    }
    return self;
}

- (void)addProtoContactDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    
    [protoContactQueue dispatchOnQueue:^{
        
        [self->protoContactMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}

- (void)removeProtoContactDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    [protoContactQueue dispatchOnQueue:^{
        
        [self->protoContactMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}

- (void)removeProtoContactDelegate:(id)delegate{
    [protoContactQueue dispatchOnQueue:^{
        
        [self->protoContactMulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
}


-(void)IQ_Result_distributieWithSEL:(SEL)sel methodID:(NSString*)methodID fetchID:(NSString *)fetchID{
    NSString * handleSEL = NSStringFromSelector(sel);//结果处理的回调方法
    NSDictionary * infoDict = @{@"methodID":methodID, @"sel":handleSEL};
    [self.IQ_Result_distributie_Dic setObject:infoDict forKey:fetchID];
}

#pragma mark - Main Method

#pragma mark - 匹配好友
//发送请求
- (void)IQ_GetContactsByFromUser:(WTProtoUser *)fromUser matchableContacts:(NSArray *)matchableContacts phoneCode:(NSString *)phoneCode type:(NSString *)emptyType nickName:(NSString *)nickName userPhone:(NSString *)userPhone{
    
//    WTProtoUser * toID = (WTProtoUser *)[_contactStream.myJID domainJID];
    WTProtoIQ* getContact_IQ = [WTProtoContactIQ IQ_GetContactsByFromUser:fromUser matchableContacts:matchableContacts phoneCode:phoneCode type:emptyType nickName:nickName userPhone:userPhone];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_MatchFriends:)
                              methodID:@"MatchFriend"
                               fetchID:getContact_IQ.elementID];
    
    [_contactStream sendElement:(XMPPIQ*)getContact_IQ];
    
    [trackerManager addTimeOutTrack:getContact_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}

//匹配好友请求回调结果
-(void)handeleResult_IQ_MatchFriends:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoContactIQ parse_IQ_GetContactsAndMatchFriends:iq parseResult:^(BOOL succeed, NSInteger matchcount, id  _Nonnull info) {
        
           [self->protoContactMulticasDelegate WTProtoContact:weakSelf getContacts_ResultWithSucceed:succeed matchcount:matchcount info:info];
        
    }];
    
}


#pragma mark - 获取联系人详情, 通过手机号/wchatid/jid 搜索查询用户
//发送请求
- (void)IQ_GetUserDetailWithKeyWord:(NSString *)key keyType:(WTProtoContactGetContactDetailsKeyType)type searchFromGroup:(BOOL)fromGroup source:(NSString *)source IPAddress:(NSString *)IPAddress fromUser:(WTProtoUser *)fromUser{
    
    WTProtoUser * toID = (WTProtoUser *)[_contactStream.myJID domainJID];
    WTProtoIQ* getContactDetails_IQ = [WTProtoContactIQ IQ_GetUserDetailsWithKeyWord:key keyType:(NSInteger)type searchFromGroup:fromGroup source:source IPAddress:IPAddress fromUser:fromUser toUser:toID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_GetUserDetails:)
                              methodID:@"GetUserDetails"
                               fetchID:getContactDetails_IQ.elementID];
    
    [_contactStream sendElement:(XMPPIQ*)getContactDetails_IQ];
    
    [trackerManager addTimeOutTrack:getContactDetails_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
       
}

//获取联系人详情请求回调结果
-(void)handeleResult_IQ_GetUserDetails:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoContactIQ parse_IQ_GetUserDetails:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->protoContactMulticasDelegate WTProtoContact:weakSelf getContactDetails_ResultWithSucceed:succeed info:info];
    }];
    
}


#pragma mark - 设置好友备注名
// 发送请求
- (void)IQ_SetFriend_MemoName:(NSString *)memoName
                          jid:(NSString *)jidstr
                     fromUser:(WTProtoUser *)fromUser{
    
    WTProtoUser * toID = (WTProtoUser *)[_contactStream.myJID domainJID];
    WTProtoIQ* setFriendMemoName_IQ = [WTProtoContactIQ IQ_SetFriend_MemoName:memoName jid:jidstr fromUser:fromUser toUser:toID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SetFriendMemoName:)
                              methodID:@"SetFriend_MemoName"
                               fetchID:setFriendMemoName_IQ.elementID];
    
    [_contactStream sendElement:(XMPPIQ*)setFriendMemoName_IQ];
    
    [trackerManager addTimeOutTrack:setFriendMemoName_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
    
}

// 设置好友备注名 请求回调结果
-(void)handeleResult_IQ_SetFriendMemoName:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoContactIQ parse_IQ_SetFriend_MemoName:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->protoContactMulticasDelegate WTProtoContact:weakSelf setFriend_MemoName_ResultWithSucceed:succeed info:info];
    }];
    
}

#pragma mark - 联系人 - 星标好友标记设置
//发送请求
- (void)IQ_SetFriend_StarMarkWithJid:(NSString *)jidstr
                           straState:(BOOL)state
                            fromUser:(WTProtoUser *)fromUser{
    
    WTProtoUser * toID = (WTProtoUser *)[_contactStream.myJID domainJID];
    WTProtoIQ* setFriendStarMark_IQ = [WTProtoContactIQ IQ_SetFriend_StarMarkWithJid:jidstr straState:state fromUser:fromUser toUser:toID];
    
    [self IQ_Result_distributieWithSEL:@selector(handeleResult_IQ_SetFriendStarMark:)
                              methodID:@"SetFriend_StarMark"
                               fetchID:setFriendStarMark_IQ.elementID];
    
    [_contactStream sendElement:(XMPPIQ*)setFriendStarMark_IQ];
    
    [trackerManager addTimeOutTrack:setFriendStarMark_IQ timeout:WT_IQ_TIME_OUT_INTERVAL];
    
}

// 联系人 - 星标好友标记设置 请求回调结果
-(void)handeleResult_IQ_SetFriendStarMark:(XMPPIQ *)iq{
    
    WEAKSELF
    [WTProtoContactIQ parse_IQ_SetFriend_StarMark:iq parseResult:^(BOOL succeed, id  _Nonnull info) {
        [self->protoContactMulticasDelegate WTProtoContact:weakSelf setFriend_StarMark_ResultWithSucceed:succeed info:info];
    }];
    
}


#pragma mark -  添加联系人
-(void)addFriendWithJid:(NSString *)jidStr source:(NSString *)source verify:(NSString *)verify time:(NSString *)time statusInfo:(NSDictionary *)statusInfo fromUser:(WTProtoUser *)fromUser{
    
    WTProtoPresence * addFriendPresent = [WTProtoContactPresent addFriendWithJid:jidStr source:source verify:verify time:time statusInfo:statusInfo fromUser:fromUser];
    [_contactStream sendElement:(XMPPPresence*)addFriendPresent];
}

-(void)handeleResult_addFriendWithSucceed:(BOOL)succeed jid:(NSString *)jid{
    [self->protoContactMulticasDelegate WTProtoContact:self addFriend_ResultWithSucceed:succeed jid:jid];
}

#pragma mark - 删除联系人
-(void)deleteFriendWithJid:(NSString *)jidStr{
    //从服务器移除
    XMPPJID * userJid = [XMPPJID jidWithString:jidStr];
    
    [_ProtoRoster unsubscribePresenceFromUser:userJid];
    [_ProtoRoster removeUser:userJid];
}

-(void)handeleResult_deleteFriendWithSucceed:(BOOL)succeed jid:(id)jid{
    [self->protoContactMulticasDelegate WTProtoContact:self deleteFriend_ResultWithSucceed:succeed jid:jid];
}

#pragma mark -   同意添加联系人
- (void)agreeAddFriendWithJid:(NSString *)jidStr source:(NSString *)source{
    
    XMPPJID * userJid = [XMPPJID jidWithString:jidStr];
    
    WTProtoPresence * agreePresent = [WTProtoContactPresent agreeAddFriendRequestWithContactJid:jidStr source:source fromUserJid:_contactStream.myJID.full];
           [_contactStream sendElement:(XMPPPresence*)agreePresent];

    [_ProtoRoster addUser:userJid withNickname:nil];
}

//同意添加的回调
-(void)handeleResult_agreeAddFriendWithSucceed:(BOOL)succeed jid:(id)jid{
    [self->protoContactMulticasDelegate WTProtoContact:self agreeAddFriend_ResultWithSucceed:succeed jid:jid];
}




#pragma mark - protoTrackerManager 超时设置
-(void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager trackTimeOutIQ:(WTProtoIQ *)iq
{
    //iq请求发送超时 FIXIME:调整error
    NSError* error = [[NSError alloc]init];
    [self xmppStream:_contactStream didFailToSendIQ:iq error:error];
}


#pragma mark - didReceiveIQ
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(nonnull XMPPIQ *)iq
{
    
    NSString *outgoingStr = [iq compactXMLString];
    
    NSLog(@"%s___%d",__FUNCTION__,__LINE__);
    NSLog(@"\n\n didReceiveIQ = %@ \n\n",outgoingStr);
    
    NSString * elementID = iq.elementID;
    
    if (elementID == nil) {
        return YES;
    }
        
    [trackerManager invokeForIQ:[WTProtoIQ iqWithiq:iq]];
    
    if ([self.IQ_Result_distributie_Dic objectForKey:elementID]) {
        
        NSDictionary * dict = [self.IQ_Result_distributie_Dic objectForKey:elementID];
        
        if ([dict objectForKey:@"sel"])
        {
            SEL sel = NSSelectorFromString([dict objectForKey:@"sel"]);
            if ([self respondsToSelector:sel])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                    [self performSelector:sel withObject:completionHandle];
                [self performSelector:sel withObjects:@[iq]];
#pragma clang diagnostic pop
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




#pragma mark - didReceivePresence
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
       NSLog(@"presence = %@",presence);
        if ([presence elementForName:@"update"] && ![presence.from.bare isEqual:sender.myJID.bare]) {
    #pragma mark  联系人好友信息更新
        }
        else if ([presence elementForName:@"ext"] && [presence.type isEqualToString:@"subscribed"]) {
    //        NSLog(@"有联系人同意了我的好友请求");
            
            
            
            
        }else if ([presence elementForName:@"status"]){
            NSLog(@"好友 %@ 在线状态 - >  %@ 登录设备 - > %@", presence.from.user,[[presence elementForName:@"status"] stringValue], [[presence elementForName:@"device"] stringValue]);
        }
    
}

#pragma mark - 添加好友 didSendPresence 回调
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    NSXMLElement *subNode = [presence elementForName:@"ext" xmlns:@"jabber:iq:roster"];
    NSString * agree = [subNode attributeStringValueForName:@"agree"];
    if ([agree integerValue] == 2) {
        return;
    }
    
    if ([presence.type isEqualToString:@"subscribe"]) {
        [self handeleResult_addFriendWithSucceed:YES jid:presence.to.bare];
    }
    if ([presence.type isEqualToString:@"subscribed"]) {
        [self handeleResult_agreeAddFriendWithSucceed:YES jid:presence.to.bare];
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    NSLog(@"发送好友请求失败");
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        //删除好友
        [self handeleResult_deleteFriendWithSucceed:NO jid:presence.to.bare];
    }else if ([presence.type isEqualToString:@"subscribe"]){
        //添加好友
        [self handeleResult_addFriendWithSucceed:NO jid:presence.to.bare];
    }else if ([presence.type isEqualToString:@"subscribed"]){
        //同意添加好友
        [self handeleResult_agreeAddFriendWithSucceed:NO jid:presence.to.bare];
    }
}

#pragma mark - 删除好友 didReceiveRosterPush 回调
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    NSLog(@"%@",[iq compactXMLString]);
    
    NSString * userJidstr = [[[iq elementForName:@"query"] elementForName:@"item"] attributeStringValueForName:@"jid"];
//    XMPPJID * userJID = [XMPPJID jidWithString:userJidstr];
//        NSString * userJID_user = [userJidstr JID_user];
    
    NSXMLElement *query = [iq elementsForName:@"query"][0];
    NSXMLElement *item = [query elementsForName:@"item"][0];
    NSString *subscription = [[item attributeForName:@"subscription"] stringValue];
    
    if ([subscription isEqualToString:@"remove"]) {
        // 删除好友
        NSLog(@"已移除好友");
        [self handeleResult_deleteFriendWithSucceed:YES jid:userJidstr];

    }
}

#pragma mark 接收好友的请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{

    //取得好友状态
//    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
//    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    
    
    //通过代理询问是否已添加为好友
    BOOL isMyFriend = [self->protoContactMulticasDelegate WTProtoContact:self isExistFriendJid:presence.from.bare];
    
    if (isMyFriend) {
        //已经在我的好友列表的，忽略当前的添加好友验证设置（设置不同回复的内容不同），直接回复同意添加好友
        
        NSXMLElement *subNode = [presence elementForName:@"ext" xmlns:@"jabber:iq:roster"];
        NSString * source = [subNode attributeStringValueForName:@"src"];
        
        //如果是对方单方面删除后又重新添加我为好友，此时默认同意
        WTProtoPresence * agreePresent = [WTProtoContactPresent agreeAddFriendRequestWithContactJid:presence.from.bare source:source fromUserJid:_contactStream.myJID.full];
        [_contactStream sendElement:(XMPPPresence*)agreePresent];

        [_ProtoRoster addUser:presence.from withNickname:nil];
        
        return;
    }
    
    NSString * statusStr = presence.status;

    if (statusStr) {
        
        NSData *jsonData = [statusStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *statusDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
            return;
        }
        NSLog(@"didReceivePresenceSubscriptionRequest statusDict = %@",statusDict);
        
        //    <ext xmlns="jabber:iq:roster" src="" agree="" verify=""></ext>
        NSXMLElement *subNode = [presence elementForName:@"ext" xmlns:@"jabber:iq:roster"];
        NSString * source = [subNode attributeStringValueForName:@"src"];
        NSString * verify = [subNode attributeStringValueForName:@"verify"];
//        NSString * agree = [subNode attributeStringValueForName:@"agree"];
        NSString * time = [subNode attributeStringValueForName:@"time"];
        //将time（2018-10-26T08:40:59.761468Z）转换为时间戳...yyyy-MM-dd'T'HH:mm:ss.SSS Z/yyyy-MM-dd'T'HH:mm:ssX
        NSString * cStamp = [self getTimestampFromTime:time format:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"];
        
        //区分正常添加或是验证请求, verify=1: 需要验证接受 verify=0不需要验证
        BOOL isWaitPassStatus = [verify isEqualToString:@"1"];
        
        if (isWaitPassStatus) {
            
            WTProtoPresence * replyAddFriendPresent = [WTProtoContactPresent replyAddFriendRequestReceivedWithContactJid:presence.from.bare];
            [_contactStream sendElement:(XMPPPresence*)replyAddFriendPresent];
                        
        }else{
            
            //同意好友请求,带上来源
            WTProtoPresence * agreePresent = [WTProtoContactPresent agreeAddFriendRequestWithContactJid:presence.from.bare source:source fromUserJid:_contactStream.myJID.full];
            [_contactStream sendElement:(XMPPPresence*)agreePresent];
            
            //andAddToRoster
            [_ProtoRoster addUser:presence.from withNickname:nil];
        }
        
        NSMutableDictionary * contactInfoDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
        [contactInfoDict setValue:presence.from.full forKey:@"jid"];
        [contactInfoDict setValue:source forKey:@"source"];
        [contactInfoDict setValue:cStamp forKey:@"time"];//请求发送的时间,插入提示消息时使用此时间值
        
        [self->protoContactMulticasDelegate WTProtoContact:self newContact:contactInfoDict isWaitPass:isWaitPassStatus];

        
    }else{
        //收到对方同意/自动同意发出的添加好友的请求
        WTProtoPresence * responseAgreePresent = [WTProtoContactPresent agreeAddFriendRequestWithContactJid:presence.from.bare source:@"" fromUserJid:_contactStream.myJID.full];
        [_contactStream sendElement:(XMPPPresence*)responseAgreePresent];
    }
    
}

//将格式化的时间转换为时间戳
- (NSString *)getTimestampFromTime:(NSString *)timeStr format:(NSString *)format
{
    //转换为时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[NSLocale currentLocale]];
//    [formatter setTimeZone:[NSTimeZone localTimeZone]];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:format];
    NSDate* dateTodo = [formatter dateFromString:timeStr];
    
    //转为当前时区时间
//    formatter.timeZone = [NSTimeZone localTimeZone];
//    NSString *dateString = [formatter stringFromDate:dateTodo];
//    dateTodo = [formatter dateFromString:dateString];

    NSTimeInterval time=[dateTodo timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", time];
//    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[dateTodo timeIntervalSince1970]];
    
    return timeSp;
}

@end
