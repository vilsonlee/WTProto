//
//  WTProtoMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/27.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMessage.h"

@implementation WTProtoMessage

-(instancetype)initWithFromID:(NSString *)fromID
                         toID:(NSString *)toID
{
    if (self = [super init])
    {
        self.fromID             = fromID;
        self.toID               = toID;
        
        [self setAttribute];
    }
    
    return self;
}


-(instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super init])
    {
        self.fromID             = [PropertyDictionary  valueForKey:@"fromID"];
        self.toID               = [PropertyDictionary  valueForKey:@"toID"];
        
        [self setAttribute];
    }
    return self;
}


-(void)setFromID:(NSString *)fromID
{
    _fromID = fromID;
}


-(void)setToID:(NSString *)toID
{
    _toID = toID;
}


-(void)setAttribute{
    
    NSString* type   = [ self.toID hasPrefix:@"gc_"] ? @"groupchat" : @"chat";
       
    [self addAttributeWithName:@"type" stringValue:type];
    [self addAttributeWithName:@"from" stringValue:self.fromID];
    [self addAttributeWithName:@"to"   stringValue:self.toID];
}

-(void)reSetAttribute{
    
    DDXMLNode *from_XMLNode  = [self attributeForName:@"from"];
    [from_XMLNode   setStringValue:self.fromID];
    
    DDXMLNode *to_XMLNode    = [self attributeForName:@"to"];
    [to_XMLNode     setStringValue:self.toID];
    
    
    NSString* type           = [self.toID hasPrefix:@"gc_"] ? @"groupchat" : @"chat";
    DDXMLNode *type_XMLNode  = [self attributeForName:@"type"];
    [type_XMLNode   setStringValue:type];
}


@end
