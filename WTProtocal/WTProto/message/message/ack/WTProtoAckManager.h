//
//  WTProtoAckManager.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPMessage;
@class WTProtoStream;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoAckManager : NSObject


/*
 ackManager 单例方法
 */
+ (WTProtoAckManager*)shareAckManagerWith:(WTProtoStream*)ackStream;

+ (void)dellocSelf;

-(void)ack:(XMPPMessage *)message;

-(void)readAckToID:(NSString *)toID incrementID:(NSInteger)incrementID;


@end

NS_ASSUME_NONNULL_END
