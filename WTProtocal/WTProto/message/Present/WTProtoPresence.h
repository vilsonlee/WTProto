//
//  WTProtoPresence.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoPresence : XMPPPresence

+ (WTProtoPresence *)presenceFromElement:(NSXMLElement *)element;

+ (WTProtoPresence *)presence;
+ (WTProtoPresence *)presenceWithType:(nullable NSString *)type;
+ (WTProtoPresence *)presenceWithType:(nullable NSString *)type to:(nullable XMPPJID *)to;

@end

NS_ASSUME_NONNULL_END
