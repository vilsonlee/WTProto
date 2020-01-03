//
//  WTProtoMediaImageMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaImageMessage.h"

@interface WTProtoMediaImageMessage()

@end

@implementation WTProtoMediaImageMessage

- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device
                     mediaPath:(NSString *)mediaPath
                         width:(float)width
                        height:(float)height
                   orientation:(int64_t)orientation
{
    if (self = [super initWithFromID:fromID
                            fromName:fromName
                                toID:toID
                              toName:toName
                          createTime:createTime
                               msgID:msgID
                             msgType:WTProtoConversationMessage_IMAGE
                     destructionTime:destructionTime
                              device:device
                           mediaPath:mediaPath])
    {
        self.width          = width;
        self.height         = height;
        self.orientation    = orientation;
        
        [self reSetBody];
    }
    
    return self;
}

- (instancetype)initWithPropertyDictionary:(NSDictionary*)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.msgType = WTProtoConversationMessage_IMAGE;
        
        self.width          = [[PropertyDictionary valueForKey:@"width"]        floatValue];
        self.height         = [[PropertyDictionary valueForKey:@"height"]       floatValue];
        self.orientation    = [[PropertyDictionary valueForKey:@"orientation"]  longLongValue];;

        [self reSetBody];
    }
    
    return self;
}




-(void)setWidth:(float)width
{
    _width = width;
    [self reSetBody];
}
-(void)setHeight:(float)height
{
    _height = height;
    [self reSetBody];
}
-(void)setOrientation:(int64_t)orientation
{
    _orientation = orientation;
    [self reSetBody];
}
@end
