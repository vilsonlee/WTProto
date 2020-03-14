//
//  WTProtoMessageCenter.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/26.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMessageCenter.h"
#import "WTProtoStream.h"
#import "WTProtoQueue.h"
#import "WTProtoTimer.h"

#import "WTProtoAckManager.h"
#import "WTProtoTrackerManager.h"

#import "WTProtoConversationMessage.h"
#import "WTProtoTextMessage.h"
#import "WTProtoMediaAudioMessage.h"
#import "WTProtoMediaImageMessage.h"
#import "WTProtoMediaVideoMessage.h"
#import "WTProtoMediaGIFMessage.h"
#import "WTProtoFileMessage.h"
#import "WTProtoVCardMessage.h"
#import "WTProtoConversationErrorMessage.h"
#import "WTProtoAckMessage.h"

#import "WTProtoWebRTCMessage.h"
#import "WTProtoWebRTCPrepareMessage.h"
#import "WTProtoWebRTCInvitationMessage.h"
#import "WTProtoWebRTCAcceptanceMessage.h"
#import "WTProtoWebRTCBusyMessage.h"
#import "WTProtoWebRTCSignalMessage.h"
#import "WTProtoWebRTCSignalOfferMessage.h"
#import "WTProtoWebRTCSignalAnswerMessage.h"
#import "WTProtoWebRTCSignalReOfferMessage.h"
#import "WTProtoWebRTCSignalReAnswerMessage.h"
#import "WTProtoWebRTCSignalICEMessage.h"
#import "WTProtoWebRTCSignalHangUpMessage.h"
#import "WTProtoWebRTCSignalAudioAcceptMessage.h"

#import "WTProtoShakeMessage.h"
#import "WTProtoshakedResultMessage.h"


#import "NSString+AES.h"
#import "NSString+DateFormat.h"

#define WEAKSELF                            typeof(self) __weak weakSelf = self;

static WTProtoMessageCenter *protoMessageCenter = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *messageCenterQueue_Serial      = nil;
static WTProtoQueue *messageCenterQueue_Concurrent  = nil;

static dispatch_once_t Serial_queueOnceToken;
static dispatch_once_t Concurrent_queueOnceToken;


@interface WTProtoMessageCenter () <WTProtoStreamDelegate,
                                    WTProtoTrackerManagerDelegate>


{
    
    WTProtoQueue *protoMessageCenterQueue_Concurrent;
    
    WTProtoQueue *protoMessageCenterQueue_Serial;
    
    WTProtoAckManager *ackManager;
    
    WTProtoTrackerManager *trackerManager;
    
    GCDMulticastDelegate <WTProtoMessageCenterDelegate> *protoMessageCenterMulticasDelegate;
    
    NSMutableDictionary *msgSendComfirmateDic;
    
}

@property(nonatomic,copy)void(^sendConversationResultHandler)(BOOL result, WTProtoConversationMessage *message);
@property(nonatomic,copy)void(^sendSkakeHandler)(BOOL result, WTProtoShakeMessage *message);
@property(nonatomic,copy)void(^sendSkakeResultHandler)(BOOL result, WTProtoshakedResultMessage *message);
@end


@implementation WTProtoMessageCenter


+ (WTProtoQueue *)messageCenterQueue_Serial{
    
    dispatch_once(&Serial_queueOnceToken, ^
    {
        messageCenterQueue_Serial = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:messageCenter_Serial"];
    });
    return messageCenterQueue_Serial;
    
}


+ (WTProtoQueue *)messageCenterQueue_Concurrent{

    dispatch_once(&Concurrent_queueOnceToken, ^
    {
        messageCenterQueue_Concurrent = [[WTProtoQueue alloc]
                                         initWithName:"org.wtproto.Queue:messageCenter_Concurrent"
                                           concurrent:YES];
    });
    return messageCenterQueue_Concurrent;
    
}


+ (void)dellocSelf
{
    protoMessageCenter = nil;
    onceToken = 0l;
    
    messageCenterQueue_Serial       = nil;
    messageCenterQueue_Concurrent   = nil;
    Serial_queueOnceToken           = 0l;
    Concurrent_queueOnceToken       = 0l;
}


-(void)dealloc
{
    [WTProtoAckManager      dellocSelf];
    [WTProtoTrackerManager  dellocSelf];
}

+ (WTProtoMessageCenter *)shareMessagerCenterWithProtoStream:(WTProtoStream *)protoStream
                                                   interface:(NSString *)interface
{
    dispatch_once(&onceToken, ^{
        
        protoMessageCenter = [[WTProtoMessageCenter alloc]initMessageMessagerCenterWithProtoStream:protoStream
                                                                                         interface:interface];
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return protoMessageCenter;

    
}



- (instancetype)initMessageMessagerCenterWithProtoStream:(WTProtoStream *)protoStream
                                                   interface:(NSString *)interface
{
    
    #ifdef DEBUG
           NSAssert(protoStream != nil, @"protoStream not be nil");
       #endif

       if (self = [super init])
       {
           _messageCenterStream = protoStream;
           
           _messageCenterUser   = protoStream.streamUser;
           
           ackManager = [WTProtoAckManager shareAckManagerWith:_messageCenterStream];
           
           trackerManager = [WTProtoTrackerManager shareTrackerManager];
                   
           protoMessageCenterQueue_Concurrent   = [WTProtoMessageCenter messageCenterQueue_Concurrent];
           
           protoMessageCenterQueue_Serial       = [WTProtoMessageCenter messageCenterQueue_Serial];
           
           protoMessageCenterMulticasDelegate = (GCDMulticastDelegate <WTProtoMessageCenterDelegate> *)[[GCDMulticastDelegate alloc] init];
           
           msgSendComfirmateDic = [NSMutableDictionary dictionary];
           
           [_messageCenterStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
           
           [trackerManager addProtoTrackerDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
           
       }

       return self;
}

- (void)addProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    //异步+串行
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{

        [self->protoMessageCenterMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}


- (void)removeProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    //异步+串行
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{

        [self->protoMessageCenterMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
    
}


- (void)removeProtoMessageCenterDelegate:(id)delegate
{
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{

        [self->protoMessageCenterMulticasDelegate removeDelegate:delegate];

    } synchronous:NO];
}



-(void)sendConversationMessage:(WTProtoConversationMessage *)message
                encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
                    sendResult:(void (^)(BOOL succeed , WTProtoConversationMessage *sendmessage))sendResult
{
    
    WTProtoConversationMessage* encryptionMessage = [self encryptConversationMessage:message EncryptionType:encryptionType];
    
    [_messageCenterStream sendElement:encryptionMessage];

    [self WaitingSendConfirmConversationMessages:message];
    
    self.sendConversationResultHandler = sendResult;
}


-(void)sendWebRTCMessage:(WTProtoWebRTCMessage *)message
          encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
              sendResult:(void (^)(BOOL succeed , WTProtoWebRTCMessage *sendmessage))sendResult
{
    
    WTProtoWebRTCMessage* encryptionMessage = [self encryptWebRTCMessage:message EncryptionType:encryptionType];
    
    [_messageCenterStream sendElement:encryptionMessage];
    
    sendResult(YES,message);
}

-(void)sendShakeMessage:(WTProtoShakeMessage *)message
          encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
              sendResult:(void (^)(BOOL succeed , WTProtoShakeMessage *sendmessage))sendResult
{
    
    WTProtoShakeMessage* shakeMessage = message;
    
    [_messageCenterStream sendElement:shakeMessage];
    
    [self WaitingSendConfirmShakeMessages:message];
        
    self.sendSkakeHandler = sendResult;
    
    
}


-(void)sendShakeResultMessage:(WTProtoshakedResultMessage *)message
          encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
              sendResult:(void (^)(BOOL succeed , WTProtoshakedResultMessage *sendmessage))sendResult
{
    
    WTProtoshakedResultMessage* shakeResultMessage = message;
    
    [_messageCenterStream sendElement:shakeResultMessage];
    
    [self WaitingSendConfirmShakeResultMessages:message];
    
    self.sendSkakeResultHandler = sendResult;
}


-(void)WaitingSendConfirmConversationMessages:(WTProtoConversationMessage *)message
{
    [msgSendComfirmateDic setObject:message forKey:message.msgID];
    [trackerManager addTimeOutTrack:message timeout:TrackerTimeOutInterval];
}


-(void)WaitingSendConfirmShakeMessages:(WTProtoShakeMessage *)message
{
    [msgSendComfirmateDic setObject:message forKey:message.msgID];
    [trackerManager addTimeOutTrack:message timeout:TrackerTimeOutInterval];
}


-(void)WaitingSendConfirmShakeResultMessages:(WTProtoshakedResultMessage *)message
{
    [msgSendComfirmateDic setObject:message forKey:message.msgID];
    [trackerManager addTimeOutTrack:message timeout:TrackerTimeOutInterval];
}




- (void)handlerServerResponse:(DDXMLElement *)element
{
    ///FIXME:这里用新的消息ID规则（"toJID.user" + "_" + "incrementID"）替换成原消息ID
    
    NSString *type         = [element attributeStringValueForName:@"t"];   //t=s : 普通消息回执； t=r : 消息撤回
    NSString *msgID        = [element attributeStringValueForName:@"i"];   //成功发送的消息的msgID
    NSString *incrementID  = [element attributeStringValueForName:@"id"];  //自增id
    
    WTProtoMessage *SendComfirmateMessage = [msgSendComfirmateDic objectForKey:msgID];

    NSString * toUserFull;
    if (SendComfirmateMessage) {
        toUserFull = SendComfirmateMessage.to.full;
    }
    
    [trackerManager invokeForMessage:SendComfirmateMessage];

    NSLog(@"%@", [element compactXMLString]);
    
    NSLog(@" c = %@------- i = %@ ------ s = %@ incrementID = %@", SendComfirmateMessage.to.bare, msgID, type, incrementID);
    
    
    if (!msgID || !toUserFull) {
         return;
     }
    
    if ([type isEqualToString:@"s"])
    {
        
    }
    
    if ([type isEqualToString:@"r"])
    {
        
    }
    
    id msgSendComfirmateValue  = [msgSendComfirmateDic valueForKey:msgID];
    
    if ([msgSendComfirmateValue isKindOfClass:[WTProtoConversationMessage class]])
    {
        WTProtoConversationMessage* conversationMessage = (WTProtoConversationMessage *)SendComfirmateMessage;
        [conversationMessage setIncrementID:[incrementID longLongValue]];
        [self callBackConversationMessage:conversationMessage sendResult:YES];
    }
    else if ([msgSendComfirmateValue isKindOfClass:[WTProtoShakeMessage class]])
    {
        WTProtoShakeMessage* shakeMessage = (WTProtoShakeMessage *)SendComfirmateMessage;
        [self callBackShakeMessage:shakeMessage sendResult:YES];
    }
    else if ([msgSendComfirmateValue isKindOfClass:[WTProtoshakedResultMessage class]])
    {
        WTProtoshakedResultMessage* shakeReslutMessage = (WTProtoshakedResultMessage *)SendComfirmateMessage;
        [self callBackShakeResultMessage:shakeReslutMessage sendResult:YES];
    }
    
    [msgSendComfirmateDic removeObjectForKey:msgID];

}


-(WTProtoConversationMessage *)encryptConversationMessage:(WTProtoConversationMessage *)message
                               EncryptionType:(WTProtoMessageCenterEncryptionType)EncryptionType
{
    return (WTProtoConversationMessage *)[self encryptMessage:message EncryptionType:EncryptionType];
}

-(WTProtoWebRTCMessage *)encryptWebRTCMessage:(WTProtoWebRTCMessage *)message
                               EncryptionType:(WTProtoMessageCenterEncryptionType)EncryptionType
{
    return (WTProtoWebRTCMessage *)[self encryptMessage:message EncryptionType:EncryptionType];
}



-(id)encryptMessage:(XMPPMessage *)message EncryptionType:(WTProtoMessageCenterEncryptionType)EncryptionType
{
    
    NSXMLElement *body         = [message elementForName:@"body"];
    
    NSUInteger msgEncryptionType  = WTProtoMessageCenterEncryptionAES;
    
    NSString* vString = @"1";
        
    if (EncryptionType > 0) {
        msgEncryptionType = EncryptionType;
    }
    
    ///OTR加密
    if      (msgEncryptionType == WTProtoMessageCenterEncryptionOTR)
    {
        vString = @"3";
        
    }
    ///OMEMO加密
    else if (msgEncryptionType == WTProtoMessageCenterEncryptionOMEMO)
    {
        vString = @"2";
    }
    ///ASE加密
    else
    {
        NSString *normalbodyValue   = [body stringValue];
        NSString *AESBodyValue      = [normalbodyValue encryptWithAESPublicKey:
                                       [self generateAESEncryptPublicKey:message]];
        
        [body setStringValue:AESBodyValue];
    }
    
    NSXMLElement *v = [NSXMLElement elementWithName:@"v" stringValue:vString];
    [message addChild:v];
    
    return message;
}



-(WTProtoConversationMessage *)decryptConversationMessage:(XMPPMessage*)message
{

    WTProtoConversationMessage* decryptMessage = [self parsingConversationMessageWithMessageDictionary:
                                      [self decryptMessagetoDictionary:message]];
    
    if (!decryptMessage) {
        WTProtoConversationErrorMessage* chatErrorMessage = [[WTProtoConversationErrorMessage alloc]
                                                     initWithFromID:message.from.full
                                                               toID:message.to.full
                                                          errorType:WTProtoConversationError_UNKNOW];
        
        [chatErrorMessage  setMsgID:[_messageCenterStream generateUUID]];
        [chatErrorMessage  setCreateTime:[NSString getCurrentTimestamp]];
        
        decryptMessage = chatErrorMessage;
    }
    
    return decryptMessage;
}


-(WTProtoWebRTCMessage *)decryptWebRTCMessage:(XMPPMessage*)message
{
    
    NSMutableDictionary *decryptMessagetoDictionary = [NSMutableDictionary dictionaryWithDictionary:[self decryptMessagetoDictionary:message]];
    
    [decryptMessagetoDictionary setValue:message.from.bare forKey:@"fromID"];
    [decryptMessagetoDictionary setValue:message.to.bare forKey:@"toID"];
    
    WTProtoWebRTCMessage* decryptWebRTCMessage = [self parsingWebRTCMessageWithMessageDictionary:
                                                  decryptMessagetoDictionary];
    
    return decryptWebRTCMessage;
}


-(WTProtoShakeMessage *)decryptShakeMessage:(XMPPMessage*)message
{
    NSXMLElement *shakeElement = [message elementForName:@"shake"];

    NSXMLElement *delayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
    
    NSString *stamp  = [delayElement attributeStringValueForName:@"stamp"];
    NSString *cStamp = [NSString getTimestampFromTime:stamp format:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
        
    NSString *sendShakeUserName     = [shakeElement attributeStringValueForName:@"nickname"];
    NSString *sendShakeUserID       = [shakeElement attributeStringValueForName:@"jid"];
    NSString *groupName             = [shakeElement attributeStringValueForName:@"groupname"];
    NSString *msgID                 = message.elementID;
    NSString *createTime            = cStamp;
    
    NSString *msgContent = @"";
    
    if ([shakeElement stringValue].length) {
        
        if (![message.type isEqualToString:@"chat"])
            msgContent = [NSString stringWithFormat:@"%@: %@",sendShakeUserName, [shakeElement stringValue]];
        else
            msgContent = [shakeElement stringValue];
    }
    
    WTProtoShakeMessage* shakeMessage = [[WTProtoShakeMessage alloc]initWithFromID:message.from.bare
                                                                              toID:message.to.bare
                                                                        createTime:createTime
                                                                   sendShakeUserID:sendShakeUserID
                                                                 sendShakeUserName:sendShakeUserName
                                                                             msgID:msgID
                                                                        msgContent:msgContent
                                                                         groupName:groupName];
    
    return shakeMessage;
}



-(WTProtoshakedResultMessage *)decryptShakeResultMessage:(XMPPMessage*)message
{
    NSLog(@"shakeResult");
    NSXMLElement* shakedResultElement = [message elementForName:@"shakedResult"];

    NSXMLElement * delayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
    NSString * stamp = [delayElement attributeStringValueForName:@"stamp"];//取出stamp的值，以便转换

    //将stamp（2018-10-26T08:40:59.761468Z）转换为时间戳...yyyy-MM-dd'T'HH:mm:ss.SSS Z/yyyy-MM-dd'T'HH:mm:ssX
    //@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"/@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    NSString * cStamp = [NSString getTimestampFromTime:stamp format:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];

    NSInteger resultType = [shakedResultElement stringValueAsInt];
    NSString * sendShakeUserName = [shakedResultElement attributeStringValueForName:@"nickname"];
    NSString * sendShakeUserID = [shakedResultElement attributeStringValueForName:@"jid"];
    NSString * groupName = [shakedResultElement attributeStringValueForName:@"groupname"];
    NSString * sendFromShakeUserID = [shakedResultElement attributeStringValueForName:@"fromjid"];
    NSString * sendFromShakeUserName = [shakedResultElement attributeStringValueForName:@"fromname"];
    NSString * msgID = message.elementID;
    NSString * createTime = cStamp;
    
    WTProtoshakedResultMessage* shakedResultMessage = [[WTProtoshakedResultMessage alloc]
                                                       initWithFromID:message.from.bare
                                                       toID:message.to.bare
                                                       createTime:createTime
                                                       sendShakeUserID:sendShakeUserID
                                                       sendShakeUserName:sendShakeUserName
                                                       sendFromShakeUserID:sendFromShakeUserID
                                                       sendFromShakeUserName:sendFromShakeUserName
                                                       msgID:msgID
                                                       resultType:resultType
                                                       groupName:groupName];
    
    return shakedResultMessage;
}




-(NSDictionary*)decryptMessagetoDictionary:(XMPPMessage*)message
{
    NSDictionary* parsingMessageDic  = [NSDictionary dictionary];
    
    if ([message elementForName:@"v"]) {
    
        NSString* Vvalue = [[message elementForName:@"v"] stringValue];
        ///OTR解密
        if ([Vvalue isEqualToString:@"3"])
        {
             parsingMessageDic = [self parsingOTRMessage:message];
        }
        ///OMEMO解密
        else if ([Vvalue isEqualToString:@"2"])
        {
             parsingMessageDic = [self parsingOMEMOMessage:message];
        }
        ///AES解密
        else
        {
            parsingMessageDic = [self parsingAESMessage:message];
        }
        
        ///解密后添加自增ID标签
        if (parsingMessageDic) {
            
            NSString* increment_id = [[message elementForName:@"increment_id"] stringValue];
            
            NSMutableDictionary* KDic = [NSMutableDictionary
                                         dictionaryWithDictionary:parsingMessageDic];
            
            [KDic setValue:increment_id forKey:@"increment_id"];
            
            parsingMessageDic = [NSDictionary dictionaryWithDictionary:KDic];
            
        }
        
    }
    
    return parsingMessageDic;
}






-(WTProtoConversationMessage* )parsingConversationMessageWithMessageDictionary:(NSDictionary *)messageDictionary
{
    
    if (!messageDictionary || ![messageDictionary valueForKey:@"msgType"]) {
        return nil;
    }
    
    NSUInteger msgType = [[messageDictionary valueForKey:@"msgType"] unsignedLongLongValue];
    
    WTProtoConversationMessage* message;
    
    switch (msgType) {
        case WTProtoConversationMessage_TEXT:
        {
            WTProtoTextMessage *textMessage = [[WTProtoTextMessage alloc]initWithPropertyDictionary:messageDictionary];
            
            message = textMessage;
            
        }
            break;
        case WTProtoConversationMessage_AUDIO:
        {
            WTProtoMediaAudioMessage *audioMessage = [[WTProtoMediaAudioMessage alloc]initWithPropertyDictionary:messageDictionary];
            
            message = audioMessage;
        }
                   
            break;
        case WTProtoConversationMessage_IMAGE:
        {
            WTProtoMediaImageMessage *iamgeMessage = [[WTProtoMediaImageMessage alloc]initWithPropertyDictionary:messageDictionary];
            
            message = iamgeMessage;
        }
                   
            break;
        case WTProtoConversationMessage_VIDEO:
        {
            WTProtoMediaVideoMessage *videoMessage = [[WTProtoMediaVideoMessage alloc]initWithPropertyDictionary:messageDictionary];
            
            message = videoMessage;
        }
                   
            break;
        case WTProtoConversationMessage_GIF:
        {
            WTProtoMediaGIFMessage *gifMessage = [[WTProtoMediaGIFMessage alloc]initWithPropertyDictionary:messageDictionary];
            
            message = gifMessage;
        }
                   
            break;
        case WTProtoConversationMessage_FILE:
        {
            WTProtoFileMessage* fileMessage = [[WTProtoFileMessage alloc]initWithPropertyDictionary:messageDictionary];
            
            message = fileMessage;
        }
                   
            break;
        case WTProtoConversationMessage_VCARD:
        {
            WTProtoVCardMessage* vCardmessage = [[WTProtoVCardMessage alloc]initWithPropertyDictionary:messageDictionary];
            
            message = vCardmessage;
        }
            break;
            
        default:
        {
            WTProtoConversationErrorMessage* chatErrorMessage = [[WTProtoConversationErrorMessage alloc]
                                                         initWithPropertyDictionary:messageDictionary
                                                                  errorType:WTProtoConversationError_UPDATE];
            message = chatErrorMessage;
        }
            break;
    }
    
    return message;
    
}


-(WTProtoWebRTCMessage *)parsingWebRTCMessageWithMessageDictionary:(NSDictionary *)messageDictionary
{
    
    NSString* eventName = [messageDictionary valueForKey:@"eventName"];
    
    WTProtoWebRTCMessage* webRTCmessage;
    
    if ([eventName isEqualToString:@"__invitation"]) {
        
        WTProtoWebRTCInvitationMessage* WebRTC_Invitation_Message = [[WTProtoWebRTCInvitationMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_Invitation_Message;
        
    }else if ([eventName isEqualToString:@"__acceptance"]){
        
        WTProtoWebRTCAcceptanceMessage* WebRTC_Acceptance_Message = [[WTProtoWebRTCAcceptanceMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_Acceptance_Message;
        
    }else if ([eventName isEqualToString:@"__offer"]){
        
        WTProtoWebRTCSignalOfferMessage* WebRTC_Offer_Message = [[WTProtoWebRTCSignalOfferMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_Offer_Message;
        
    }else if ([eventName isEqualToString:@"__reoffer"]){
        
        WTProtoWebRTCSignalReOfferMessage* WebRTC_ReOffer_Message = [[WTProtoWebRTCSignalReOfferMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_ReOffer_Message;
        
    }else if ([eventName isEqualToString:@"__answer"]){
        
        WTProtoWebRTCSignalAnswerMessage* WebRTC_Answer_Message = [[WTProtoWebRTCSignalAnswerMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_Answer_Message;
        
    }else if ([eventName isEqualToString:@"__reanswer"]){
        
        WTProtoWebRTCSignalReAnswerMessage* WebRTC_ReAnswer_Message = [[WTProtoWebRTCSignalReAnswerMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_ReAnswer_Message;
        
    }else if ([eventName isEqualToString:@"__ice_candidate"]){
        
        WTProtoWebRTCInvitationMessage* WebRTC_ICE_Message = [[WTProtoWebRTCInvitationMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_ICE_Message;
        
    }else if ([eventName isEqualToString:@"__hangup"]){
        
        WTProtoWebRTCSignalHangUpMessage* WebRTC_Hangup_Message = [[WTProtoWebRTCSignalHangUpMessage alloc]
                                                                   initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_Hangup_Message;
        
    }else if ([eventName isEqualToString:@"__audioAccept"]){
        
        WTProtoWebRTCSignalAudioAcceptMessage* WebRTC_AudioAccept_Message = [[WTProtoWebRTCSignalAudioAcceptMessage alloc]initWithPropertyDictionary:messageDictionary];
        
        webRTCmessage = WebRTC_AudioAccept_Message;
        
    }else if ([eventName isEqualToString:@"__busy"]){
        
        WTProtoWebRTCBusyMessage* WebRTC_Busy_Message = [[WTProtoWebRTCBusyMessage alloc]
                                                             initWithPropertyDictionary:messageDictionary];
        webRTCmessage = WebRTC_Busy_Message;
    }
    
    return webRTCmessage;
}






- (NSString *)generateAESEncryptPublicKey:(XMPPMessage *)message {
    NSString *singleKey = nil;
    
    NSString *messageSender     = [message attributeStringValueForName:@"from"];
    NSString *messageReceiver   = [message attributeStringValueForName:@"to"];
    
    NSString *sender    = [[messageSender componentsSeparatedByString:@"@"] firstObject];
    NSString *receiver  = [[messageReceiver componentsSeparatedByString:@"@"] firstObject];
    
    if ([sender compare:receiver] == NSOrderedAscending) {
        singleKey = [NSString stringWithFormat:@"%@_%@",sender,receiver];
    }else {
        singleKey = [NSString stringWithFormat:@"%@_%@",receiver,sender];
    }
    
    NSString *messageKey    = [messageReceiver hasPrefix:@"gc"] ? messageReceiver : singleKey;
    NSString *publicKey     = [[messageKey base64EncodedString] substringToIndex:16];
    
    return publicKey;
}


- (NSString *)generateAESDecryptPublicKey:(XMPPMessage *)message {
    
    NSString *messageSender     = [message attributeStringValueForName:@"from"];
    NSString *messageReceiver   = [message attributeStringValueForName:@"to"];
    
    NSString* webSingleSendJID  = [message elementForName:@"web_single"].stringValue;
    
    if (webSingleSendJID && [webSingleSendJID isEqualToString:_messageCenterStream.myJID.user]) {
        
        NSString*  web_singleTo         = [[message elementForName:@"web_single"] attributeStringValueForName:@"to"];
        NSString* messageReceiverStr    = [NSString stringWithFormat:@"%@/%@",
                                           web_singleTo,
                                           _messageCenterStream.myJID.resource];
        
        messageReceiver = messageReceiverStr;
    }
    
    NSString *decryptKey = nil;
    
    //如果是群聊 密钥为群JID； 否则为 base64(A_B) 取前16位
    if ([message.type isEqualToString:@"groupchat"]) {
        
        decryptKey = [messageSender hasPrefix:@"gc"] ? messageSender : messageReceiver;
        
    }else {
        NSString *sender    = [[messageSender componentsSeparatedByString:@"@"] firstObject];
        NSString *receiver  = [[messageReceiver componentsSeparatedByString:@"@"] firstObject];
        
        if ([sender compare:receiver] == NSOrderedAscending) {
            decryptKey = [NSString stringWithFormat:@"%@_%@",sender,receiver];
        }else {
            decryptKey = [NSString stringWithFormat:@"%@_%@",receiver,sender];
        }
    }
    
    NSString *publicKey = [[decryptKey base64EncodedString] substringToIndex:16];
    
    return publicKey;
}



- (NSDictionary *)parsingAESMessage:(XMPPMessage *)message
{
    NSString *publicKey = [self generateAESDecryptPublicKey:message];
    NSString *msgJson   = [message.body decryptWithAESPublicKey:publicKey];
    if (msgJson)
    {
        return [NSDictionary parsingMessageBody:msgJson];
    }else
    {
        return nil;
    }
}


- (NSDictionary *)parsingOMEMOMessage:(XMPPMessage *)message
{
    return [NSDictionary dictionary];
}


- (NSDictionary *)parsingOTRMessage:(XMPPMessage *)message
{
    return [NSDictionary dictionary];
}


- (void)ack:(XMPPMessage*)message{
    
    [self->ackManager ack:message];
    
}

- (void)readAckToID:(NSString *)toID incrementID:(NSInteger)incrementID
{
    [self->ackManager readAckToID:toID incrementID:incrementID];
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(nonnull XMPPMessage *)message{
    
}


- (void)xmppStream:(XMPPStream *)sender didReceiveCustomElement:(DDXMLElement *)element
{
    //接收到自定义的标签消息
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{
                
        if ([element.name isEqualToString:@"s"]) {
            //处理消息发送状态
            WEAKSELF
            [[WTProtoQueue mainQueue] dispatchOnQueue:^
            {
                   [weakSelf handlerServerResponse:element];
            }];
        }
    } synchronous:NO];

}






-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(nonnull XMPPMessage *)message error:(nonnull NSError *)error
{
    
    [self callBackConversationMessage:(WTProtoConversationMessage *)message sendResult:NO];
    [protoMessageCenterQueue_Serial dispatchOnQueue:^{
        
        if ([message elementForName:@"shake"]) {
            [self callBackShakeMessage:(WTProtoShakeMessage *)message sendResult:NO];
            return;
        }
        
        if ([message elementForName:@"shakedResult"]) {
            [self callBackShakeResultMessage:(WTProtoshakedResultMessage *)message sendResult:NO];
            return;
        }
        
        if ([message elementForName:@"webrtc-invitation"] ||
            [message elementForName:@"webrtc"])
        {
            [self callBackShakeResultMessage:(WTProtoshakedResultMessage *)message sendResult:NO];
            return;
        }
        
        if ([message elementForName:@"conversation"])
        {
            [self callBackConversationMessage:(WTProtoConversationMessage *)message sendResult:NO];
            return;
        }
    }];
}



-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(nonnull XMPPMessage *)message
{
    
    WEAKSELF;
    [protoMessageCenterQueue_Concurrent dispatchOnQueue:^{
        
        
        if ([message elementForName:@"rece_ack"])
        {
            
            ///处理对方已收到的rece_ack
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"read_rece_ack"])
        {
            
            ///处理对方已读的read_rece_ack
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"encrypteReSend"])
        {
            [weakSelf ack:message];
            return;
        }
        
        
        if ([message elementForName:@"sendencrypteReSend"]){
            
            [weakSelf ack:message];
            return;
        }
        
        
        XMPPMessage* Message = [weakSelf handleRemarkMessage:message];
        
        
        if ([message elementForName:@"webrtc-invitation"] ||
            [message elementForName:@"webrtc"])
        {
            
            WTProtoWebRTCMessage* decrypt_webRTC_Message = [weakSelf decryptWebRTCMessage:Message];
            
            [self->protoMessageCenterMulticasDelegate protoMessageCenter:weakSelf
                                          didReceiveWebRTCDecryptMessage:decrypt_webRTC_Message
                                                         OriginalMessage:Message];
            
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"shake"]) {
            
            if ([message.type isEqualToString:@"groupchat"] &&
                [message.elementID containsString:[NSString
                                                   stringWithFormat:@"groupChatFromID:%@",sender.myJID.user]])
            {
                return;
            }
            
             WTProtoShakeMessage* shakeMessage = [weakSelf decryptShakeMessage:message];
            
            
            [self->protoMessageCenterMulticasDelegate protoMessageCenter:weakSelf
                                           didReceiveShakeDecryptMessage:shakeMessage
                                                         OriginalMessage:message];
            
            [weakSelf ack:message];
            return;
        }
        
        
        if ([message elementForName:@"shakedResult"])
        {
            if ([message.type isEqualToString:@"groupchat"] &&
                [message.elementID containsString:[NSString
                                                   stringWithFormat:@"groupChatFromID:%@",sender.myJID.user]])
            {
                return;
            }
            
            WTProtoshakedResultMessage* shakeResultMessage = [weakSelf decryptShakeResultMessage:message];
            
            [self->protoMessageCenterMulticasDelegate protoMessageCenter:weakSelf
                                     didReceiveShakeResultDecryptMessage:shakeResultMessage
                                                         OriginalMessage:message];
            
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"clienttoweb"])
        {
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"webtoclient"])
        {
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"web_send"] ||
            [message elementForName:@"web_single"])
        {
            
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"help_web_send"] &&
            [message.from.user isEqualToString: weakSelf.messageCenterStream.myJID.user])
        {
            [weakSelf ack:message];
            return;
        }
        
        
        if ([message elementForName:@"match_friend"])
        {
            [weakSelf ack:message];
            return;
        }
        
        
        if ([message elementForName:@"ext" xmlns:@"jabber:iq:roster"])
        {
            
            [weakSelf ack:message];
            return;
        }
        
        
        if ([message elementForName:@"recall" xmlns:@"wchat:user:msg"])
        {
            [weakSelf ack:message];
            return;
        }
        
        
        if ([message elementForName:@"delete_msg" xmlns:@"wchat:user:msg"])
        {
            
            [weakSelf ack:message];
            return;
        }
        
        
        if ([message elementForName:@"block"])
        {
            [weakSelf ack:message];
            return;
        }
        
        if ([message elementForName:@"invite_confirmed"])
        {
            [weakSelf ack:message];
            return;
        }
        
        
        WTProtoConversationMessage* decrypt_Conversation_Message = [weakSelf decryptConversationMessage:Message];
    
        [self->protoMessageCenterMulticasDelegate protoMessageCenter:weakSelf
                                didReceiveConversationDecryptMessage:decrypt_Conversation_Message
                                                     OriginalMessage:Message];
        
        [weakSelf ack:message];
        
    } synchronous:NO];
}


- (void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager
        trackTimeOutConversationMessage:(WTProtoConversationMessage *)message
{
    [self callBackConversationMessage:message sendResult:NO];
}


- (void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager
        trackTimeOutShakeMessage:(WTProtoShakeMessage *)message
{
    [self callBackShakeMessage:message sendResult:NO];
}


- (void)protoTrackerManager:(WTProtoTrackerManager *)trackerManager trackTimeOutShakeResultMessage:(WTProtoshakedResultMessage *)message
{
    [self callBackShakeResultMessage:message sendResult:NO];
}


- (void)callBackConversationMessage:(WTProtoConversationMessage *)message sendResult:(BOOL)sendResult
{
    [[WTProtoQueue mainQueue] dispatchOnQueue:^
    {
    
         if (self.sendConversationResultHandler)
         {
             self.sendConversationResultHandler(sendResult,message);
             self.sendConversationResultHandler = nil;
         }
         
     } synchronous:NO];
}


- (void)callBackShakeMessage:(WTProtoShakeMessage *)message sendResult:(BOOL)sendResult
{
    [[WTProtoQueue mainQueue] dispatchOnQueue:^{
    
         if (self.sendSkakeHandler)
         {
             self.sendSkakeHandler(sendResult,message);
             self.sendSkakeHandler = nil;
         }
         
     } synchronous:NO];
}


- (void)callBackShakeResultMessage:(WTProtoshakedResultMessage *)message sendResult:(BOOL)sendResult
{
    [[WTProtoQueue mainQueue] dispatchOnQueue:^{
    
         if (self.sendSkakeResultHandler)
         {
             self.sendSkakeResultHandler(sendResult,message);
             self.sendSkakeResultHandler = nil;
         }
         
     } synchronous:NO];
}




-(XMPPMessage*)handleRemarkMessage:(XMPPMessage*)message{
    
    if ([[[[message elementForName:@"event"]
           elementForName:@"items"]
          elementForName:@"item"]
         elementForName:@"message"] != nil)
    {
        NSXMLElement * nextMessage = [[[[message elementForName:@"event"]
                                        elementForName:@"items"]
                                       elementForName:@"item"]
                                      elementForName:@"message"];
        
        message = [XMPPMessage messageFromElement:nextMessage];
    }
    return message;
}



@end
