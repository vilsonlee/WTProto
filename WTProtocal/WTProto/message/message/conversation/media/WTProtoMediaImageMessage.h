//
//  WTProtoMediaImageMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoMediaImageMessage : WTProtoMediaMessage

@property(nonatomic,assign)float width;
@property(nonatomic,assign)float height;
@property(nonatomic,assign)int64_t   orientation;

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


-(void)setWidth:(float)width;
-(void)setHeight:(float)height;
-(void)setOrientation:(int64_t)orientation;



@end

NS_ASSUME_NONNULL_END
