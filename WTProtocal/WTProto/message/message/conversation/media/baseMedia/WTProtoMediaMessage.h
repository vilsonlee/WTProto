//
//  WTProtoMediaMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoConversationMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoMediaMessage : WTProtoConversationMessage

@property(nonatomic,copy)NSString *mediaPath;

- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
                       msgType:(WTProtoConversationMessageType)msgType
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     mediaPath:(NSString *)mediaPath;


-(void)setMediaPath:(NSString * _Nonnull)mediaPath;

@end

NS_ASSUME_NONNULL_END
