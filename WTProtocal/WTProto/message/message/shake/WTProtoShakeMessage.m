//
//  WTProtoShakeMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/27.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoShakeMessage.h"

@interface WTProtoShakeMessage ()

@end

@implementation WTProtoShakeMessage


-(instancetype)initWithFromID:(NSString *)fromID
                         toID:(NSString *)toID
                   createTime:(NSString *)createTime
              sendShakeUserID:(NSString *)sendShakeUserID
            sendShakeUserName:(NSString *)sendShakeUserName
                        msgID:(NSString *)msgID
                   msgContent:(NSString *)msgContent
                     groupName:(NSString *)groupName
{
    if (self = [super initWithFromID:fromID toID:toID])
    {
        self.sendShakeUserID    = sendShakeUserID;
        self.sendShakeUserName  = sendShakeUserName;
        self.msgID              = msgID;
        self.msgContent         = msgContent;
        self.groupName          = groupName;
        self.createTime         = createTime;
        
        [self reSetAttribute];
        [self reSetBody];
    }
    
    return self;
}



-(void)setBody
{
    NSXMLElement  *shockBody        = [NSXMLElement elementWithName:@"shake"];
    
    [shockBody addAttributeWithName:@"jid"      stringValue:self.sendShakeUserID];
    [shockBody addAttributeWithName:@"nickname" stringValue:self.sendShakeUserName];
    
    if ([ self.toID hasPrefix:@"gc_"]) {
        [shockBody addAttributeWithName:@"groupname" stringValue:self.groupName];
    }

    [shockBody setStringValue:self.msgContent];
    
    [self addChild:shockBody];

}

-(void)reSetBody
{
    NSXMLElement *shockBody         = [self elementForName:@"shake"];
    
    if (!shockBody) {
        
        shockBody = [NSXMLElement elementWithName:@"shake"];
        [shockBody addAttributeWithName:@"jid"      stringValue:self.sendShakeUserID];
        [shockBody addAttributeWithName:@"nickname" stringValue:self.sendShakeUserName];
        [self addChild:shockBody];
        
    }else{
        
        DDXMLNode * sendShakeUserID_XMLNode     = [shockBody attributeForName:@"jid"];
        DDXMLNode * nickname_XMLNode            = [shockBody attributeForName:@"nickname"];
        
        [sendShakeUserID_XMLNode        setStringValue:self.sendShakeUserID];
        [nickname_XMLNode               setStringValue:self.sendShakeUserName];
    }
    
    
    if ([ self.toID hasPrefix:@"gc_"]) {
        
        DDXMLNode * groupName_XMLNode   = [shockBody attributeForName:@"groupname"];
        
        if (!groupName_XMLNode) {
            [shockBody addAttributeWithName:@"groupname" stringValue:self.groupName];
        }else{
            [groupName_XMLNode setStringValue:self.groupName];
        }
    }
    
    [shockBody setStringValue:self.msgContent];
}


-(void)setFromID:(NSString *)fromID
{
    [super setFromID:fromID];
    [self reSetAttribute];
}


-(void)setToID:(NSString *)toID
{
    [super setToID:toID];
    [self reSetAttribute];
}


-(void)setSendShakeUserID:(NSString *)sendShakeUserID
{
    _sendShakeUserID = sendShakeUserID;
    [self reSetBody];
}


-(void)setSendShakeUserName:(NSString *)sendShakeUserName
{
    _sendShakeUserName = sendShakeUserName;
    [self reSetBody];
}


-(void)setMsgID:(NSString *)msgID
{
    _msgID = msgID;
    [self reSetAttribute];
}


-(void)setMsgContent:(NSString *)msgContent
{
    _msgContent = msgContent;
    [self reSetBody];
}


-(void)setGroupName:(NSString *)groupName
{
    _groupName = groupName;
    [self reSetBody];
}


-(void)setCreateTime:(NSString *)createTime{
    _createTime = createTime;
}


-(void)reSetAttribute
{
    
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
