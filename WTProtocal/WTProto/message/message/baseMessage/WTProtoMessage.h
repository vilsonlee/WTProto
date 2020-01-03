//
//  WTProtoMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/27.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <WTXMPPFramework/XMPPFramework.h>
#import "NSObject+JSONTool.h"
#import "NSString+WTString.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoMessage : XMPPMessage

@property(nonatomic,copy)NSString* fromID;
@property(nonatomic,copy)NSString* toID;


-(instancetype)initWithFromID:(NSString *)fromID toID:(NSString *)toID;

-(instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary;


-(void)setBody;
-(void)reSetBody;

-(void)setAttribute;
-(void)reSetAttribute;
-(void)propertyAddbody:(NSString *)property key:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
