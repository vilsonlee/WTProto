//
//  WTProtoWebRTCSignalAnswerMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalAnswerMessage.h"

@implementation WTProtoWebRTCSignalAnswerMessage

- (instancetype)initWithFromID:(NSString *)fromID
                          toID:(NSString *)toID
                     sectionID:(NSString *)sectionID
                      fromName:(NSString *)fromName
                       isVideo:(NSString *)isVideo
                          data:(NSString *)data
{
    if (self = [super initWithFromID:fromID
                                toID:toID
                           sectionID:sectionID
                          signalType:WTProtoWebRTCSignal_ANSWER
                                data:data])
    {
        [self propertyAddbody:fromName  key:@"fromName"];
        [self propertyAddbody:isVideo   key:@"isVideo"];
        [self reSetBody];
    }
    
    return self;
}


-(instancetype)initWithPropertyDictionary:(NSDictionary *)PropertyDictionary
{
    if (self = [super initWithPropertyDictionary:PropertyDictionary])
    {
        self.fromName       = [PropertyDictionary  valueForKey:@"fromName"];
        self.isVideo        = [PropertyDictionary  valueForKey:@"isVideo"];
    }
    
    return self;
}


-(void)setFromName:(NSString *)fromName
{
    _fromName = fromName;
    [self propertyAddbody:fromName key:@"fromName"];
    [self reSetBody];
}

-(void)setIsVideo:(NSString *)isVideo
{
    _isVideo = isVideo;
    [self propertyAddbody:isVideo key:@"isVideo"];
    [self reSetBody];
}


@end
