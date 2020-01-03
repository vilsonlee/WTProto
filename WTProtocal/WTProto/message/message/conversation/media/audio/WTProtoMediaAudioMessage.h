//
//  WTProtoMediaAudioMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoMediaAudioMessage : WTProtoMediaMessage

@property(nonatomic,copy)NSString *duration;
@property(nonatomic,copy)NSArray *meteringLevels;


- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     mediaPath:(NSString *)mediaPath
                      duration:(NSString *)duration
                meteringLevels:(NSArray *)meteringLevels;


-(void)setDuration:(NSString *)duration;
-(void)setMeteringLevels:(NSArray * _Nonnull)meteringLevels;



@end

NS_ASSUME_NONNULL_END
