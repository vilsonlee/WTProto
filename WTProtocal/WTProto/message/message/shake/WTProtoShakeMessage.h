//
//  WTProtoShakeMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/27.
//  Copyright © 2019 Vilson. All rights reserved.
//



#import "WTProtoMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoShakeMessage : WTProtoMessage

@property(nonatomic,copy)NSString* sendShakeUserID;
@property(nonatomic,copy)NSString* sendShakeUserName;
@property(nonatomic,copy)NSString* msgContent;
@property(nonatomic,copy)NSString* msgID;
@property(nonatomic,copy)NSString* groupName;
@property(nonatomic,copy)NSString* createTime;

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                    createTime:(NSString *)createTime
               sendShakeUserID:(NSString *)sendShakeUserID
             sendShakeUserName:(NSString *)sendShakeUserName
                         msgID:(NSString *)msgID
                    msgContent:(NSString *)msgContent
                     groupName:(NSString *)groupName;



@end

NS_ASSUME_NONNULL_END
