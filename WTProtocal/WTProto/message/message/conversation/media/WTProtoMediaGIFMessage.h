//
//  WTProtoMediaGIFMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaImageMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoMediaGIFMessage : WTProtoMediaImageMessage

- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     mediaPath:(NSString *)mediaPath
                         width:(float)width
                        height:(float)height
                   orientation:(int64_t)orientation;

@end

NS_ASSUME_NONNULL_END
