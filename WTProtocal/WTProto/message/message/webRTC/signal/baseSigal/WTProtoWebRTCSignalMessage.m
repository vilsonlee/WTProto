//
//  WTProtoWebRTCSignalMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalMessage.h"

@interface WTProtoWebRTCSignalMessage ()
{
   
}
@end

@implementation WTProtoWebRTCSignalMessage


-(instancetype)initWithFromID:(NSString *)fromID
                         toID:(NSString *)toID
                    sectionID:(NSString *)sectionID
                   signalType:(WTProtoWebRTCSignalType)signalType
                         data:(NSString *)data
{
    
    NSString* eventName;
    
    switch (signalType) {
        case WTProtoWebRTCSignal_OFFER:
            eventName = @"__offer";
            break;
        case WTProtoWebRTCSignal_RE_OFFER:
            eventName = @"__reoffer";
            break;
        case WTProtoWebRTCSignal_ANSWER:
            eventName = @"__answer";
            break;
        case WTProtoWebRTCSignal_RE_ANSWER:
            eventName = @"__reanswer";
            break;
        case WTProtoWebRTCSignal_ICE_CANDIDATE:
            eventName = @"__ice_candidate";
            break;
        case WTProtoWebRTCSignal_HANDUP:
            eventName = @"__hangup";
            break;
        case WTProtoWebRTCSignal_AUDIO_ACCEPT:
            eventName = @"__audioAccept";
            break;
        default:
            break;
    }
    
    if (self = [super initWithFromID:fromID
                                toID:toID
                           eventName:eventName
                           sectionID:sectionID])
    {
        
        
        if (signalType == WTProtoWebRTCSignal_OFFER         ||
            signalType == WTProtoWebRTCSignal_RE_OFFER      ||
            signalType == WTProtoWebRTCSignal_ANSWER        ||
            signalType == WTProtoWebRTCSignal_RE_ANSWER     ||
            signalType == WTProtoWebRTCSignal_ICE_CANDIDATE
            )
        {
            self.data = data;
            [self propertyAddbody:data key:@"data"];
            [self reSetBody];
        }
        
        [self addWebRTCSignalTypeChildElement:self.eventName];
    }
    
    return self;
}


-(instancetype)initWithPropertyDictionary:(NSDictionary *)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        
        if ([self.eventName isEqualToString:@"__offer"]     ||
            [self.eventName isEqualToString:@"__reoffer"]   ||
            [self.eventName isEqualToString:@"__answer"]    ||
            [self.eventName isEqualToString:@"__reanswer"]  ||
            [self.eventName isEqualToString:@"__ice_candidate"])
        {
            self.data = [PropertyDictionary  valueForKey:@"data"];
        }
        
        [self reSetBody];
        [self addWebRTCSignalTypeChildElement:self.eventName];
    }
    
    return self;
}


-(void)setData:(NSString *)data
{
    _data = data;
    [self propertyAddbody:data key:@"data"];
    [self reSetBody];
}


-(void)addWebRTCSignalTypeChildElement:(NSString* )eventName{
    
    NSString        * WebRTCSignal_type;
       
    NSXMLElement    * WebRTCSignal_type_element  = [NSXMLElement elementWithName:@"webrtc"
                                                                              xmlns:@"wchat:user:webrtc"];
   
    if ([eventName isEqualToString:@"__offer"])
    {
        WebRTCSignal_type   = @"offer";
    }
    else if ([eventName isEqualToString:@"__reoffer"])
    {
        WebRTCSignal_type   = @"reoffer";
    }
    else if ([eventName isEqualToString:@"__answer"])
    {
        WebRTCSignal_type   = @"answer";
    }
    else if ([eventName isEqualToString:@"__reanswer"])
    {
        WebRTCSignal_type   = @"reanswer";
    }
    else if ([eventName isEqualToString:@"__ice_candidate"])
    {
        WebRTCSignal_type   = @"ice";
    }
    else if ([eventName isEqualToString:@"__hangup"])
    {
        WebRTCSignal_type   = @"hangup";
    }
    else if ([eventName isEqualToString:@"__audioAccept"])
    {
        WebRTCSignal_type   = @"busy";
    }
        
    [WebRTCSignal_type_element addAttributeWithName:@"type" stringValue:WebRTCSignal_type];
    
    [self addChild:WebRTCSignal_type_element];
}


@end
