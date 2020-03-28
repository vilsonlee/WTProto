//
//  WTProtoBlock.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/20.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WTProtoBlock;
@class WTProtoUser;
@class WTProtoBlocking;
@class WTProtoStream;
@class WTProtoQueue;

NS_ASSUME_NONNULL_BEGIN

@protocol WTProtoBlockDelegate

@optional
- (void)WTProtoBlock:(WTProtoBlock* )protoBlock changeBlockStatus_ResultWithSucceed:(BOOL)succeed info:(id)info;

@end


@interface WTProtoBlock : NSObject

@property (nonatomic, strong, readonly)WTProtoStream   *blockStream;
@property (nonatomic, strong, readonly)WTProtoBlocking *protoBlocking;


/**
* The default value is YES.
*/
@property (nonatomic, readwrite, assign) BOOL autoRetrieveBlockingListItems;


/**
* The default value is YES.
*/
@property (nonatomic, readwrite, assign) BOOL autoClearBlockingListInfo;


/**
 * Blocking dict
 */
@property (readonly, strong) NSMutableDictionary *blockingDict;

+ (void)dellocSelf;

+ (WTProtoQueue *)blockQueue;


+ (WTProtoBlock *)shareBlockWithProtoStream:(WTProtoStream *)protoStream
                                  interface:(NSString *)interface;


- (void)addProtoBlockDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoBlockDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeProtoBlockDelegate:(id)delegate;



//FIXME:以下当用到才实现

/**
 * Manual fetch of list names and rules, and manual control over when to clear stored info.
 **/
- (void)retrieveBlockingListItems;
- (void)clearBlockingListInfo;

/**
 * Returns the blocking list.
 *
 * The result is an array or blocking items (NSXMLElement's).
 **/
- (NSArray*)blockingList;

/**
 * Block JID.
 */
- (void)blockWUser:(WTProtoUser*)WUser;

/**
 * Unblock JID.
 */
- (void)unblockWUser:(WTProtoUser*)WUser;

/**
 * Return whether a jid is in blocking list or not.
 */
- (BOOL)containsWUser:(WTProtoUser*)WUser;

/**
 * Unblock all.
 */
- (void)unblockAll;

@end

NS_ASSUME_NONNULL_END
