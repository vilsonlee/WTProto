//
//  WTProtoIQ.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <WTXMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoIQ : XMPPIQ

+ (WTProtoIQ *)iq;
+ (WTProtoIQ *)iqWithType:(nullable NSString *)type;
+ (WTProtoIQ *)iqWithType:(nullable NSString *)type to:(nullable XMPPJID *)jid;
+ (WTProtoIQ *)iqWithType:(nullable NSString *)type to:(nullable XMPPJID *)jid elementID:(nullable NSString *)eid child:(nullable NSXMLElement *)childElement;
+ (WTProtoIQ *)iqWithType:(nullable NSString *)type elementID:(nullable NSString *)eid;
+ (WTProtoIQ *)iqWithType:(nullable NSString *)type elementID:(nullable NSString *)eid child:(nullable NSXMLElement *)childElement;
+ (WTProtoIQ *)iqWithType:(nullable NSString *)type child:(nullable NSXMLElement *)childElement;

@end

NS_ASSUME_NONNULL_END
