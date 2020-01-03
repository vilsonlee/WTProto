//
//  WTProtoVCardMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoConversationMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoVCardMessage : WTProtoConversationMessage

@property(nonatomic,copy)NSString *msgCard;

@property(nonatomic,copy)NSString *msgContent;

- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
                    msgContent:(NSString *)msgContent
                        jidStr:(NSString *)jidStr
                      nickName:(NSString *)nickName
                           sex:(int64_t)sex
                     signature:(NSString *)signature
                    userAvatar:(NSString *)userAvatar
                       wchatid:(NSString *)wchatid
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device;

-(void)setMsgContent:(NSString * _Nonnull)msgContent;
-(void)setJidStr:(NSString * _Nonnull)jidStr;
-(void)setNickName:(NSString * _Nonnull)nickName;
-(void)setSignature:(NSString * _Nonnull)signature;
-(void)setUserAvatar:(NSString * _Nonnull)userAvatar;
-(void)setWchatid:(NSString * _Nonnull)wchatid;
-(void)setSex:(int64_t)sex;

-(NSString *) jidStr;
-(NSString *) nickName;
-(NSString *) signature;
-(NSString *) userAvatar;
-(NSString *) wchatid;
-(int64_t) sex;

@end

NS_ASSUME_NONNULL_END
