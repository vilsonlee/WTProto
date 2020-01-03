//
//  WTProtoWebRTCPrepareMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCPrepareMessage.h"

@implementation WTProtoWebRTCPrepareMessage

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
                   prepareType:(WTProtoWebRTCPrepareType)prepareType
                      fromName:(NSString *)fromName
{
    NSString        * eventName;
        
    switch (prepareType) {
        case WTProtoWebRTCPrepare_INVITATION:
            eventName               = @"__invitation";
            break;
        case WTProtoWebRTCPrepare_ACCEPTANCE:
            eventName               = @"__acceptance";
            break;
        case WTProtoWebRTCPrepare_BUSY:
            eventName               = @"__busy";
            break;
        default:
            break;
    }
    
    if (self = [super initWithFromID:fromID
                                toID:toID
                           eventName:eventName
                           sectionID:sectionID])
    {
        self.fromName =  fromName;
        [self propertyAddbody:fromName  key:@"fromName"];
        [self reSetBody];
        [self addWebRTCPrepareTypeChildElement:self.eventName];
    }
    return self;
    
    
}

-(instancetype)initWithPropertyDictionary:(NSDictionary *)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.fromName       = [PropertyDictionary  valueForKey:@"fromName"];
        [self addWebRTCPrepareTypeChildElement:self.eventName];
    }
    
    return self;
}


-(void)addWebRTCPrepareTypeChildElement:(NSString* )eventName{
    
    NSString        * WebRTCInvitation_type;
       
    NSXMLElement    * WebRTCInvitation_type_element  = [NSXMLElement elementWithName:@"webrtc-invitation"
                                                                              xmlns:@"wchat:user:webrtc"];
   
    if ([eventName isEqualToString:@"__invitation"])
    {
        WebRTCInvitation_type   = @"invitation";
    }
    else if ([eventName isEqualToString:@"__acceptance"])
    {
        WebRTCInvitation_type   = @"acceptance";
    }
    else if ([eventName isEqualToString:@"__busy"])
    {
        WebRTCInvitation_type   = @"busy";
    }
        
    [WebRTCInvitation_type_element addAttributeWithName:@"type" stringValue:WebRTCInvitation_type];
    
    [self addChild:WebRTCInvitation_type_element];
}


-(void)setFromName:(NSString * _Nonnull)fromName
{
    _fromName = fromName;
    [self propertyAddbody:fromName key:@"fromName"];
    [self reSetBody];
}


@end
