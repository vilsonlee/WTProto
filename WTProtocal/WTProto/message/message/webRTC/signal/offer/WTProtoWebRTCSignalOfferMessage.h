//
//  WTProtoWebRTCSignalOfferMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoWebRTCSignalOfferMessage : WTProtoWebRTCSignalMessage

@property(nonatomic,copy)NSString *fromName;
@property(nonatomic,copy)NSString *isVideo;

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
                      fromName:(NSString *)fromName
                       isVideo:(NSString *)isVideo
                          data:(NSString *)data;


-(void)setFromName:(NSString * _Nonnull)fromName;
-(void)setIsVideo:(NSString * _Nonnull)isVideo;

@end

NS_ASSUME_NONNULL_END
