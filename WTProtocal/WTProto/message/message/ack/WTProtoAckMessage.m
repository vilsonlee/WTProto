//
//  WTProtoAckMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoAckMessage.h"
#import "WTProtoConversationMessage.h"
#import "WTProtoStream.h"

@implementation WTProtoAckMessage

+ (WTProtoAckMessage *)ackMessage:(XMPPMessage*)message WTProtoStream:(WTProtoStream *)stream
{
    
    NSXMLElement * delayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
    NSString * s                = [delayElement attributeStringValueForName:@"stamp"];
    

    NSXMLElement * ackElement   = [NSXMLElement  elementWithName:@"c" xmlns:@"ack"];
    
    BOOL isSingleChat           = [message.type isEqualToString:@"chat"];
    
    //判断是否是群聊
    if (isSingleChat == true) {
        [ackElement addAttributeWithName:@"j" stringValue:stream.myJID.bare];
    }
    else{
        [ackElement addAttributeWithName:@"j" stringValue:message.from.bare];
    }
    
    [ackElement addAttributeWithName:@"t" stringValue:s];
    
    //ack用自增ID
    NSString * increment_id = [[message elementForName:@"increment_id"] stringValue];

    NSString* rece_ack = @"1";
    NSString* i_string = @"";
    
    //阅读回执的r_ack i和r的值都为”“
    if ([message elementForName:@"rece_ack"])
    {
        [ackElement addAttributeWithName:@"m" stringValue:@"rece_ack"];
        
        //只处理单聊
        if (increment_id && isSingleChat)
        {
            i_string = increment_id;
        }
        
    }else{//普通消息的r_ack  先区分系统（server_msg）消息（不处理）还是普通消息处理，普通消息分（单、群聊处理）
        
        [ackElement addAttributeWithName:@"m" stringValue:isSingleChat ? @"c" : @"g"];
 
        if (increment_id)
        {
            if (!isSingleChat)
            {
                //群聊，最后一条消息是撤回，删除类型的操作消息
                i_string = increment_id;
                
            }
            else
            {
                i_string = [NSString stringWithFormat:@"%@%@",message.from.bare,increment_id];
            }
        }
    }

        if (i_string) {
            [ackElement addAttributeWithName:@"i" stringValue:i_string];
            [ackElement addAttributeWithName:@"r" stringValue:rece_ack];

            NSLog(@"ack == %@", ackElement.compactXMLString);
        }
    
    return [[WTProtoAckMessage alloc]initWithXMLString:ackElement.compactXMLString error:nil];
}





@end
