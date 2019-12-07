//
//  WTProtoQueue.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/7.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface WTProtoQueue : NSObject


/**
    WTProtoQueue    初始化方法 (默认 SERIAL是串行队列)
    @param name     队列名
 */
- (instancetype)initWithName:(const char *)name;



/**
   WTProtoQueue          初始化方法 (默认 SERIAL是串行队列)
   @param name           队列名
   @param concurrent     是否为并发队列
*/
- (instancetype)initWithName:(const char *)name concurrent:(bool)concurrent;

/**
    WTProtoQueue 主队列获取方法
*/
+ (WTProtoQueue *)mainQueue;


/**
    WTProtoQueue 默认全局并发队列获取方法
*/
+ (WTProtoQueue *)concurrentDefaultQueue;

/**
    WTProtoQueue 默认全局并发队列获取方法
*/
+ (WTProtoQueue *)concurrentLowQueue;


/**
    WTProtoQueue 获取WTProtoQueue初始化的队列
*/
- (dispatch_queue_t)nativeQueue;

/**
    WTProtoQueue 是否为当前队列
*/
- (bool)isCurrentQueue;
    

/**
    
*/
- (void)dispatchOnQueue:(dispatch_block_t)block;

/**

*/
- (void)dispatchOnQueue:(dispatch_block_t)block synchronous:(bool)synchronous;

@end


