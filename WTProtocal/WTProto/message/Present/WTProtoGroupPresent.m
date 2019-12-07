//
//  WTProtoGroupPresent.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoGroupPresent.h"
#import "WTProtoPresence.h"
#import "WTProtoUser.h"


@implementation WTProtoGroupPresent

+ (WTProtoPresence *)presenceGroupWithRoomID:(WTProtoUser *)roomID{
    
    WTProtoPresence *presence = [WTProtoPresence presence];
    [presence addAttributeWithName:@"to" stringValue:roomID.full];
        
    //      <x xmlns='http://jabber.org/protocol/muc'/>
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"http://jabber.org/protocol/muc"];
    [presence addChild:x];
    
    return presence;
}







@end
