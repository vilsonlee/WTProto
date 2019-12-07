//
//  WTProtoTimer.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/8.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoTimer : NSObject

@property (nonatomic) NSTimeInterval timeoutDate;

- (id)initWithTimeout:(NSTimeInterval)timeout
               repeat:(bool)repeat
           completion:(dispatch_block_t)completion
                queue:(dispatch_queue_t)queue;

- (void)start;


- (void)fireAndInvalidate;


- (void)invalidate;


- (bool)isScheduled;


- (void)resetTimeout:(NSTimeInterval)timeout;


- (NSTimeInterval)remainingTime;


@end

NS_ASSUME_NONNULL_END
