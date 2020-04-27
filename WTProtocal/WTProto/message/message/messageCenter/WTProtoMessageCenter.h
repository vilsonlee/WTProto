//
//  WTProtoMessageCenter.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/26.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, WTProtoMessageCenterEncryptionType) {
    WTProtoMessageCenterEncryptionAES     = 0,      //AES
    WTProtoMessageCenterEncryptionOTR,              //OTR
    WTProtoMessageCenterEncryptionOMEMO,            //OMEMO
};



@class WTProtoMessageCenter;
@class WTProtoQueue;
@class WTProtoStream;
@class WTProtoUser;
@class WTProtoConversationMessage;
@class WTProtoWebRTCMessage;
@class WTProtoShakeMessage;
@class WTProtoshakedResultMessage;
@class XMPPMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoMessageCenterDelegate

@optional

-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter
                          didReceiveConversationDecryptMessage:(nonnull WTProtoConversationMessage *)decryptMessage
                                               OriginalMessage:(nonnull XMPPMessage *)originalMessage;


-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter
                          didReceiveWebRTCDecryptMessage:(nonnull WTProtoWebRTCMessage *)decryptMessage
                                         OriginalMessage:(nonnull XMPPMessage *)originalMessage;


-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter
                          didReceiveShakeDecryptMessage:(nonnull WTProtoShakeMessage *)decryptMessage
                          OriginalMessage:(nonnull XMPPMessage *)originalMessage;


-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter
                          didReceiveShakeResultDecryptMessage:(nonnull WTProtoshakedResultMessage *)decryptMessage
                          OriginalMessage:(nonnull XMPPMessage *)originalMessage;

-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter didReceiveGroupDataUpDateInfo:(nonnull NSDictionary *)updateInfo originalMessage:(nonnull XMPPMessage *)originalMessage;

-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter didReceiveAcceptPresenceMessage:(nonnull NSDictionary *)acceptInfo originalMessage:(nonnull XMPPMessage *)originalMessage;

-(void)protoMessageCenter:(WTProtoMessageCenter *)messageCenter didReceiveMatchFriendWithMessage:(nonnull NSDictionary *)contactInfo originalMessage:(nonnull XMPPMessage *)originalMessage;

@end



@interface WTProtoMessageCenter : NSObject

@property (nonatomic, strong, readonly)WTProtoStream* messageCenterStream;

@property (nonatomic, strong, readonly)WTProtoUser* messageCenterUser;


+ (WTProtoQueue *)messageCenterQueue_Concurrent;
+ (WTProtoQueue *)messageCenterQueue_Serial;

+ (void)dellocSelf;


+ (WTProtoMessageCenter *)shareMessagerCenterWithProtoStream:(WTProtoStream *)protoStream
                                                   interface:(NSString *)interface;

- (void)addProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoMessageCenterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoMessageCenterDelegate:(id)delegate;

- (void)sendConversationMessage:(WTProtoConversationMessage *)message
                 encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
                     sendResult:(void (^)(BOOL succeed , WTProtoConversationMessage *sendmessage))sendResult;


-(void)sendWebRTCMessage:(WTProtoWebRTCMessage *)message
          encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
              sendResult:(void (^)(BOOL succeed , WTProtoWebRTCMessage *sendmessage))sendResult;


-(void)sendShakeMessage:(WTProtoShakeMessage *)message
         encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
             sendResult:(void (^)(BOOL succeed , WTProtoShakeMessage *sendmessage))sendResult;



-(void)sendShakeResultMessage:(WTProtoshakedResultMessage *)message
               encryptionType:(WTProtoMessageCenterEncryptionType)encryptionType
                   sendResult:(void (^)(BOOL succeed , WTProtoshakedResultMessage *sendmessage))sendResult;

-(WTProtoConversationMessage *)decryptConversationMessage:(XMPPMessage*)message;

- (void)ack:(XMPPMessage*)message;

- (void)readAckToID:(NSString *)toID incrementID:(NSInteger)incrementID;

@end

NS_ASSUME_NONNULL_END
