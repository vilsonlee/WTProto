//
//  WTProtoPresence.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoPresence.h"

@implementation WTProtoPresence


+ (WTProtoPresence *)presenceFromElement:(NSXMLElement *)element{
    
    return [self presenceFromElement:element];
}

+ (WTProtoPresence *)presence{
    
    return [self presence];
}
+ (WTProtoPresence *)presenceWithType:(nullable NSString *)type{
    
    return [self presenceWithType:type];
}
+ (WTProtoPresence *)presenceWithType:(nullable NSString *)type to:(nullable XMPPJID *)to{
    
    return [self presenceWithType:type to:to];
}

@end
