//
//  WTProtoTextMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoConversationMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoTextMessage : WTProtoConversationMessage

@property(nonatomic,copy)NSString *msgContent;
@property(nonatomic,copy)NSString *remindJids;


- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
                    msgContent:(NSString *)msgContent
                    remindJids:(NSString *)remindJids
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device;



-(void)setMsgContent:(NSString * _Nonnull)msgContent;
-(void)setRemindJids:(NSString * _Nonnull)remindJids;

@end

NS_ASSUME_NONNULL_END
