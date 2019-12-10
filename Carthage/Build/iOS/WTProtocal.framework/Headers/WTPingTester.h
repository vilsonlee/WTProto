//
//  WTPingTester.h
//  BigVPN
//
//  Created by Vilson on 2019/11/1.
//  Copyright © 2019 Vilson. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SimplePing.h"

@protocol WTPingDelegate <NSObject>
@optional
- (void) didPingSucccessWithTime:(float)time hostName:(NSString *)hostName withError:(NSError*) error;
@end


@interface WTPingTester : NSObject<SimplePingDelegate>
@property (nonatomic, weak, readwrite) id<WTPingDelegate> delegate;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;
    
- (void) startPing;
- (void) stopPing;
@end

typedef NS_ENUM(NSUInteger, WTPingStatus){
    WTPingStatusSending = 0 << 0,
    WTPingStatusTimeout = 1 << 1,
    WTPingStatusSended = 2 << 2,
};

@interface WTPingItem : NSObject
//@property(nonatomic, assign) WTPingStatus status;
@property(nonatomic, assign) uint16_t sequence;

@end



