//
//  WTProtoVCardMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoVCardMessage.h"
#import "NSObject+JSONTool.h"


@interface WTProtoVCardMessage()
{
    NSMutableDictionary* _msgCardDic;
}
@end

@implementation WTProtoVCardMessage

-(instancetype)initWithFromID:(NSString *)fromID
                     fromName:(NSString *)fromName
                         toID:(NSString *)toID
                       toName:(NSString *)toName
                   createTime:(NSString *)createTime
                        msgID:(NSString *)msgID
                   msgContent:(NSString *)msgContent
                       jidStr:(NSString *)jidStr
                     nickName:(NSString *)nickName
                          sex:(int64_t)sex
                    signature:(NSString *)signature
                   userAvatar:(NSString *)userAvatar
                      wchatid:(NSString *)wchatid
              destructionTime:(int64_t)destructionTime
                       device:(int64_t)device
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                             msgType:WTProtoConversationMessage_VCARD
                     destructionTime:destructionTime
                              device:device])
    {
        
        _msgCardDic = [NSMutableDictionary dictionary];
        [_msgCardDic setValue:jidStr             forKey:@"jidStr"];
        [_msgCardDic setValue:nickName           forKey:@"nickName"];
        [_msgCardDic setValue:signature          forKey:@"signature"];
        [_msgCardDic setValue:userAvatar         forKey:@"userAvatar"];
        [_msgCardDic setValue:wchatid            forKey:@"wchatid"];
        [_msgCardDic setValue:[NSNumber numberWithUnsignedLongLong:sex]  forKey:@"sex"];
        
        self.msgCard        = [_msgCardDic JSONSToSring];
        self.msgContent     = msgContent;
        
        [self reSetBody];
    }
    
    return self;
    
}

- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.msgContent     = [PropertyDictionary valueForKey:@"msgContent"];
        
        self.msgCard        = [NSDictionary objectFromJSONString:[PropertyDictionary valueForKey:@"msgCard"]];
        
        [self reSetBody];
    }
    
    return self;
}





-(void)setMsgContent:(NSString * _Nonnull)msgContent
{
    _msgContent = msgContent;
    [self reSetBody];
}


-(void)setJidStr:(NSString * _Nonnull)jidStr
{
    [_msgCardDic setValue:jidStr forKey:@"jidStr"];
    self.msgCard = [_msgCardDic JSONSToSring];
    [self reSetBody];
}


-(void)setNickName:(NSString * _Nonnull)nickName
{
    [_msgCardDic setValue:nickName forKey:@"nickName"];
    self.msgCard = [_msgCardDic JSONSToSring];
    [self reSetBody];
}


-(void)setSex:(int64_t)sex
{
    [_msgCardDic setValue:[NSNumber numberWithUnsignedLongLong:sex] forKey:@"sex"];
    self.msgCard = [_msgCardDic JSONSToSring];
    [self reSetBody];
}


-(void)setSignature:(NSString * _Nonnull)signature
{
    [_msgCardDic setValue:signature forKey:@"signature"];
    self.msgCard = [_msgCardDic JSONSToSring];
    [self reSetBody];
}


-(void)setUserAvatar:(NSString * _Nonnull)userAvatar
{
    [_msgCardDic setValue:userAvatar forKey:@"userAvatar"];
    self.msgCard = [_msgCardDic JSONSToSring];
    [self reSetBody];
}


-(void)setWchatid:(NSString * _Nonnull)wchatid
{
    [_msgCardDic setValue:wchatid forKey:@"wchatid"];
    self.msgCard = [_msgCardDic JSONSToSring];
    [self reSetBody];
}

-(NSString *) jidStr
{
    return [_msgCardDic valueForKey:@"jidStr"];
}


-(NSString *) nickName
{
    return [_msgCardDic valueForKey:@"nickName"];
    
}


-(int64_t ) sex
{
    return [[_msgCardDic valueForKey:@"sex"] longLongValue];
    
}


-(NSString *) signature
{
    return [_msgCardDic valueForKey:@"signature"];
    
}


-(NSString *) userAvatar
{
    return [_msgCardDic valueForKey:@"userAvatar"];
    
}

-(NSString *) wchatid
{
    return [_msgCardDic valueForKey:@"wchatid"];
}


@end
