//
//  WTProtoIQ.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoIQ.h"

@implementation WTProtoIQ

+ (WTProtoIQ *)iq
{
    return [[WTProtoIQ alloc] initWithType:nil to:nil elementID:nil child:nil];
}


+ (WTProtoIQ *)iqWithiq:(XMPPIQ*)iq
{
    return [[WTProtoIQ alloc] initWithType:iq.type to:iq.to elementID:iq.elementID child:iq.childElement];
}

+ (WTProtoIQ *)iqWithType:(NSString *)type
{
    return [[WTProtoIQ alloc] initWithType:type to:nil elementID:nil child:nil];
}

+ (WTProtoIQ *)iqWithType:(NSString *)type to:(XMPPJID *)jid
{
    return [[WTProtoIQ alloc] initWithType:type to:jid elementID:nil child:nil];
}

+ (WTProtoIQ *)iqWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid
{
    return [[WTProtoIQ alloc] initWithType:type to:jid elementID:eid child:nil];
}

+ (WTProtoIQ *)iqWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement
{
    return [[WTProtoIQ alloc] initWithType:type to:jid elementID:eid child:childElement];
}

+ (WTProtoIQ *)iqWithType:(NSString *)type elementID:(NSString *)eid
{
    return [[WTProtoIQ alloc] initWithType:type to:nil elementID:eid child:nil];
}

+ (WTProtoIQ *)iqWithType:(NSString *)type elementID:(NSString *)eid child:(NSXMLElement *)childElement
{
    return [[WTProtoIQ alloc] initWithType:type to:nil elementID:eid child:childElement];
}

+ (WTProtoIQ *)iqWithType:(NSString *)type child:(NSXMLElement *)childElement
{
    return [[WTProtoIQ alloc] initWithType:type to:nil elementID:nil child:childElement];
}


@end
