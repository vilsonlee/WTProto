//
//  WTProtoWebRTCMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <WTXMPPFramework/XMPPFramework.h>
#import "WTProtoMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoWebRTCMessage : WTProtoMessage

@property(nonatomic,copy)NSString *eventName;
@property(nonatomic,copy)NSString *sectionID;


- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     eventName:(NSString *)eventName
                     sectionID:(NSString *)sectionID;


-(instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary;


-(void)setEventName:(NSString * _Nonnull)eventName;
-(void)setSectionID:(NSString * _Nonnull)sectionID;

@end

NS_ASSUME_NONNULL_END
