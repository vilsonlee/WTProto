//
//  WTProtoRosters.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/21.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoRosters.h"
#import "WTProtoQueue.h"
#import "WTProtoStream.h"
#import "WTProtoRoster.h"
#import "WTProtoRosterCoreDataStorage.h"

static WTProtoRosters *protoRoster = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *rostersQueue = nil;
static dispatch_once_t queueOnceToken;

@interface WTProtoRosters()<XMPPRosterDelegate>
{
    WTProtoQueue*  protoRostersQueue;
    GCDMulticastDelegate <WTProtoRostersDelegate> *protoRostersMulticasDelegate;
}
@end

@implementation WTProtoRosters


+ (WTProtoQueue *)rostersQueue
{
    dispatch_once(&queueOnceToken, ^
    {
        rostersQueue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:roster"];
    });
    return rostersQueue;
}


+ (void)dellocSelf
{
    protoRoster = nil;
    onceToken = 0l;
    
    rostersQueue = nil;
    queueOnceToken = 0l;
}


+ (WTProtoRosters *)shareRostersWithProtoStream:(WTProtoStream *)protoStream
                                      interface:(NSString *)interface
{
    dispatch_once(&onceToken, ^{
        
        protoRoster = [[WTProtoRosters alloc]initRostersWithProtoStream:protoStream
                                                              interface:interface];
           
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
        
       });
    
    return protoRoster;
}


- (instancetype)initRostersWithProtoStream:(WTProtoStream *)protoStream
                                 interface:(NSString *)interface
{
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"address should not be nil");
    #endif

    if (self = [super init])
    {
        _RostersStream = protoStream;
        
        protoRostersQueue = [WTProtoRosters rostersQueue];
        
        protoRostersMulticasDelegate = (GCDMulticastDelegate <WTProtoRostersDelegate> *)[[GCDMulticastDelegate alloc] init];
    
        _protoRosterCoreDataStorage = [[WTProtoRosterCoreDataStorage alloc]init];
        
//        _ProtoRoster = [[WTProtoRoster alloc]initWithRosterStorage:_protoRosterCoreDataStorage];
        
//        _ProtoRoster = [[WTProtoRoster alloc]initWithRosterStorage:[[XMPPRosterCoreDataStorage alloc]init]];
//
//        _ProtoRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
//        _ProtoRoster.autoFetchRoster = YES;
//
//        [_ProtoRoster activate:_RostersStream];
//        [_ProtoRoster addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
    }

    return self;
}




- (void)addProtoRostersDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoRostersQueue dispatchOnQueue:^{

        [self->protoRostersMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}

- (void)removeProtoRostersDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [protoRostersQueue dispatchOnQueue:^{

        [self->protoRostersMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:YES];
}

- (void)removeProtoRostersDelegate:(id)delegate
{
    [protoRostersQueue dispatchOnQueue:^{

        [self->protoRostersMulticasDelegate removeDelegate:delegate];

    } synchronous:YES];
}



- (void)fetchRoster
{
    [_ProtoRoster fetchRoster];
}

- (void)fetchRosterVersion:(nullable NSString *)version
{
    [_ProtoRoster fetchRosterVersion:version];
}

- (void)addUser:(WTProtoUser *)protoUser source:(NSString *)source reason:(NSString *)reason verify:(NSString *)verify
{
    //向服务器发送添加请求
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"subscribe" to:protoUser];
    [presence addAttributeWithName:@"from" stringValue:_RostersStream.myJID.full];
    [presence setXmlns:@"jabber:client"];

    //FIXME:必要的参数phone、nickname、userAvatar
    NSMutableDictionary * statusDict = [[NSMutableDictionary alloc] init];
//    [statusDict setObject:[EMTContactManager defaultManager].currentLoginUserInfo.userPhone forKey:@"phone"];
//    [statusDict setObject:[EMTContactManager defaultManager].currentLoginUserInfo.nickName forKey:@"nickname"];
//    [statusDict setObject:[EMTContactManager defaultManager].currentLoginUserInfo.userAvatar forKey:@"userAvatar"];
        
    if (reason && reason.length) {
        //理由
        [statusDict setObject:reason forKey:@"reason"];
    }
        
    //NSJSONWritingPrettyPrinted
    NSError  *parseError    = nil;
    NSData   *jsonData      = [NSJSONSerialization dataWithJSONObject:statusDict
                                                              options:kNilOptions error:&parseError];
    
    NSString *statusJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    [presence addChild:[DDXMLElement elementWithName:@"status" stringValue:statusJsonStr]];
    
    //    <ext xmlns="jabber:iq:roster" src="" agree="" verify=""></ext>
    NSXMLElement *subNode = [NSXMLElement elementWithName:@"ext" xmlns:@"jabber:iq:roster"];
    [subNode addAttributeWithName:@"src" stringValue:source];
    [subNode addAttributeWithName:@"agree" stringValue:@""];
    //有理由 -> 需要等待同意接受
    [subNode addAttributeWithName:@"verify" stringValue:verify];
    
    //FIXME:当前正确时间
    NSDate * trueNowDate = [[NSDate alloc]init];//FIXME:当前正确时间
//    NSString * cStamp = [NSString dateFormatterWithDate:trueNowDate format:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"];
    //FIXME:trueNowDate转换成string
    NSString * cStamp = @"";
    [subNode addAttributeWithName:@"time" stringValue:cStamp];
        
    [presence addChild:subNode];
    
    [_RostersStream sendElement:presence];
}



- (void)addUser:(WTProtoUser *)protoUser withNickname:(nullable NSString *)optionalName
{
    [_ProtoRoster addUser:protoUser withNickname:optionalName];
    
}


- (void)addUser:(WTProtoUser *)protoUser withNickname:(nullable NSString *)optionalName
         groups:(nullable    NSArray<NSString*> *)groups
{
    
    [_ProtoRoster addUser:protoUser withNickname:optionalName groups:groups];
}


- (void)addUser:(WTProtoUser *)protoUser withNickname:(nullable NSString *)optionalName
         groups:(nullable NSArray<NSString*> *)groups subscribeToPresence:(BOOL)subscribe
{
    
    [_ProtoRoster addUser:protoUser withNickname:optionalName groups:groups subscribeToPresence:subscribe];
}


- (void)removeUser:(WTProtoUser *)protoUser
{
    [_ProtoRoster removeUser:protoUser];
}


- (void)setNickname:(NSString *)nickname forUser:(WTProtoUser *)protoUser
{
    [_ProtoRoster setNickname:nickname forUser:protoUser];
}

- (void)subscribePresenceToUser:(WTProtoUser *)protoUser
{
    [_ProtoRoster subscribePresenceToUser:protoUser];
}


- (void)unsubscribePresenceFromUser:(WTProtoUser *)protoUser
{
    [_ProtoRoster unsubscribePresenceFromUser:protoUser];
}


- (void)revokePresencePermissionFromUser:(WTProtoUser *)protoUser
{
    [_ProtoRoster revokePresencePermissionFromUser:protoUser];
}


- (void)acceptPresenceSubscriptionRequestFrom:(WTProtoUser *)protoUser andAddToRoster:(BOOL)flag
{
    [_ProtoRoster acceptPresenceSubscriptionRequestFrom:protoUser andAddToRoster:flag];
}


- (void)rejectPresenceSubscriptionRequestFrom:(WTProtoUser *)protoUser
{
    [_ProtoRoster rejectPresenceSubscriptionRequestFrom:protoUser];
}



/**
 * Sent when a presence subscription request is received.
 * That is, another user has added you to their roster,
 * and is requesting permission to receive presence broadcasts that you send.
 *
 * The entire presence packet is provided for proper extensibility.
 * You can use [presence from] to get the JID of the user who sent the request.
 *
 * The methods acceptPresenceSubscriptionRequestFrom: and rejectPresenceSubscriptionRequestFrom: can
 * be used to respond to the request.
**/
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
}

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
**/
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    
}

/**
 * Sent when the initial roster is received.
**/
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version
{
    
}

/**
 * Sent when the initial roster has been populated into storage.
**/
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    
}

/**
 * Sent when the roster receives a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
**/
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    
}





@end
