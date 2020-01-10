//
//  WTProtoMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoConversationMessage.h"

@interface WTProtoConversationMessage ()

@end

@implementation WTProtoConversationMessage

-(instancetype)initWithFromID:(NSString *)fromID
                     fromName:(NSString *)fromName
                         toID:(NSString *)toID
                       toName:(NSString *)toName
                   createTime:(NSString *)createTime
                        msgID:(NSString *)msgID
                      msgType:(WTProtoConversationMessageType)msgType
              destructionTime:(int64_t)destructionTime
                       device:(int64_t)device
{
    if (self = [super initWithFromID:fromID toID:toID])
    {
        self.fromName           = fromName;
        self.toName             = toName;
        self.createTime         = createTime;
        self.msgID              = msgID;
        self.msgType            = msgType;
        self.destructionTime    = destructionTime;
        self.device             = device;
    
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
        
        self.fromName           = [PropertyDictionary  valueForKey:@"fromName"];
        self.toID               = [PropertyDictionary  valueForKey:@"toID"];
        self.toName             = [PropertyDictionary  valueForKey:@"toName"];
        self.createTime         = [PropertyDictionary  valueForKey:@"createTime"];
        self.msgID              = [PropertyDictionary  valueForKey:@"msgID"];
        self.msgType            = [[PropertyDictionary valueForKey:@"msgType"] longLongValue];
        self.destructionTime    = [[PropertyDictionary valueForKey:@"destructionTime"] longLongValue];
        self.device             = [[PropertyDictionary valueForKey:@"device"] longLongValue];
                
        [self reSetAttribute];
        [self setBody];
    }
    
    return self;
}


-(void)setFromID:(NSString *)fromID
{
    [super  setFromID:fromID];
    [self   reSetBody];
    [self   reSetAttribute];
}


-(void)setToID:(NSString *)toID
{
    [super  setToID:toID];
    [self   reSetBody];
    [self   reSetAttribute];
}


-(void)setFromName:(NSString *)fromName
{
    _fromName = fromName;
    [self reSetBody];
}


-(void)setToName:(NSString *)toName
{
    _toName = toName;
    [self reSetBody];
}

-(void)setCreateTime:(NSString *)createTime
{
    _createTime = createTime;
    [self reSetBody];
}


-(void)setMsgID:(NSString *)msgID
{
    _msgID = msgID;
    [self reSetBody];
    [self reSetAttribute];
}


-(void)setMsgType:(WTProtoConversationMessageType)msgType
{
    _msgType = msgType;
    [self reSetBody];
}


-(void)setDestructionTime:(int64_t)destructionTime
{
    _destructionTime = destructionTime;
    [self reSetBody];
}


-(void)setDevice:(int64_t)device
{
    _device = device;
    [self reSetBody];
}


-(NSString *)getBodyString:(WTProtoConversationMessage*)protoMessage
{
    NSData   *normalBodyData    = [WTProtoConversationMessage getJSON:protoMessage
                                                           superClass:[WTProtoMessage class]
                                                              options:kNilOptions error:nil];

    NSString *normalBodyString  = [[NSString alloc] initWithData:normalBodyData
                                                        encoding:NSUTF8StringEncoding];
    
    return normalBodyString;
}


-(void)setBody
{
    NSXMLElement  *normalbody        = [NSXMLElement elementWithName:@"body"];
    NSString      *normalBodyString  = [self getBodyString:self];
    [normalbody setStringValue:normalBodyString];
    
    NSXMLElement  *markElement       = [NSXMLElement elementWithName:@"conversation"];
    
    [self addChild:normalbody];
    [self addChild:markElement];
}



-(void)reSetBody{
    
    NSXMLElement  *normalbody            = [self elementForName:@"body"];
    NSString      *new_normalBodyString  = [self getBodyString:self];
    
    [normalbody setStringValue:new_normalBodyString];
}


-(void)reSetAttribute{
    
    [super reSetAttribute];
    
    DDXMLNode * id_XMLNode   = [self attributeForName:@"id"];

    NSString *id_Value = self.msgID;

    if ([ self.toID hasPrefix:@"gc_"])
        id_Value = [NSString stringWithFormat:@"groupChatFromID:%@_%@",self.fromID,self.msgID];
    
    if (!id_XMLNode)
        [self addAttributeWithName:@"id" stringValue:id_Value];
    else
        [id_XMLNode     setStringValue:id_Value];
}


@end
