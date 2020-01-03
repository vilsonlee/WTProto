//
//  WTProtoWebRTCSignalReAnswerMessage.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoWebRTCSignalReAnswerMessage.h"

@implementation WTProtoWebRTCSignalReAnswerMessage

-(instancetype)initWithFromID:(NSString *)fromID
                         toID:(NSString *)toID
                    sectionID:(NSString *)sectionID
                     fromName:(nonnull NSString *)fromName
                      isVideo:(nonnull NSString *)isVideo
                         data:(nonnull NSString *)data
{
    self = [super initWithFromID:fromID toID:toID sectionID:sectionID fromName:fromName isVideo:isVideo data:data];
    
    if (self) {
        [self setEventName:@"__reanswer"];
        [self reSetBody];
    }
    
    return self;
}


@end
