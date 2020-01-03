//
//  WTProtoFileMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoFileMessage.h"


@interface WTProtoFileMessage()

@end

@implementation WTProtoFileMessage


-(instancetype)initWithFromID:(NSString *)fromID
                     fromName:(NSString *)fromName
                         toID:(NSString *)toID
                       toName:(NSString *)toName
                   createTime:(NSString *)createTime
                        msgID:(NSString *)msgID
                   msgContent:(NSString *)msgContent
                    mediaPath:(NSString *)mediaPath
                fileExtension:(NSString *)fileExtension
                     fileSize:(NSString *)fileSize
              destructionTime:(int64_t)destructionTime
                       device:(int64_t)device
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                             msgType:WTProtoConversationMessage_FILE
                     destructionTime:destructionTime
                              device:device
                           mediaPath:mediaPath])
    {
        self.msgContent     = msgContent;
        self.fileExtension  = fileExtension;
        self.fileSize       = fileSize;
        
        [self reSetBody];
    }
    
    return self;
    
}

- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.msgContent     =  [PropertyDictionary valueForKey:@"msgContent"];
        self.fileExtension  =  [PropertyDictionary valueForKey:@"fileExtension"];
        self.fileSize       =  [PropertyDictionary valueForKey:@"fileSize"];
        
        [self reSetBody];
    }
    
    return self;
}



-(void)setMsgContent:(NSString *)msgContent
{
    _msgContent = msgContent;
    [self reSetBody];
}

-(void)setFileExtension:(NSString *)fileExtension
{
    _fileExtension = fileExtension;
    [self reSetBody];
}

-(void)setFileSize:(NSString *)fileSize
{
    _fileSize = fileSize;
    [self reSetBody];
    
}

@end
