//
//  WTProtoWebRTCMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCMessage.h"


@interface WTProtoWebRTCMessage ()
{
    NSMutableDictionary* _bodyDic;
}
@end

@implementation WTProtoWebRTCMessage

-(instancetype)initWithFromID:(NSString *)fromID
                         toID:(NSString *)toID
                    eventName:(NSString *)eventName
                    sectionID:(NSString *)sectionID
{
    if (self = [super initWithFromID:fromID toID:toID])
    {
        self.eventName          = eventName;
        self.sectionID          = sectionID;
        
        [self reSetAttribute];
        [self setBody];
    }
    
    return self;
}

-(instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithFromID:[PropertyDictionary  valueForKey:@"fromID"]
                                toID:[PropertyDictionary  valueForKey:@"toID"]])
    {
        self.eventName          = [PropertyDictionary  valueForKey:@"eventName"];
        self.sectionID          = [PropertyDictionary  valueForKey:@"sectionID"];
        
        [self reSetAttribute];
        [self setBody];
    }
    
    return self;
}


- (void)setFromID:(NSString *)fromID
{
    [super setFromID:fromID];
    [self reSetAttribute];
}


- (void)setToID:(NSString *)toID
{
    [super setToID:toID];
    [self reSetAttribute];
}


- (void)setEventName:(NSString *)eventName
{
    _eventName = eventName;
    [_bodyDic setValue:eventName forKey:@"eventName"];
    [self reSetBody];
}


- (void)setSectionID:(NSString *)sectionID
{
    _sectionID = sectionID;
    [_bodyDic setValue:sectionID forKey:@"sectionID"];
    [self reSetBody];
}


- (NSString *)getBodyString:(NSMutableDictionary *)bodyDic
{
    NSString *normalBodyString  = [bodyDic JSONSToSring];
    return normalBodyString;
}


- (void)setBody{
    
    NSXMLElement  *normalbody        = [NSXMLElement elementWithName:@"body"];
    
    _bodyDic = [NSMutableDictionary dictionary];
    [_bodyDic setValue:self.eventName    forKey:@"eventName"];
    [_bodyDic setValue:self.sectionID    forKey:@"sectionID"];
      
    NSString *normalBodyString  = [self getBodyString:_bodyDic];
    
    [normalbody setStringValue:normalBodyString];
    
    [self addChild:normalbody];
}


- (void)reSetBody{
    
    NSXMLElement *normalbody         = [self elementForName:@"body"];
    NSString  *new_normalBodyString  = [self getBodyString:_bodyDic];
    
    [normalbody setStringValue:new_normalBodyString];
}


- (void)propertyAddbody:(NSString *)property key:(NSString *)key
{
     [_bodyDic setValue:property forKey:key];
}



@end
