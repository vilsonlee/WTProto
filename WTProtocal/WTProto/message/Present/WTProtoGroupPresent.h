//
//  WTProtoGroupPresent.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/23.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoPresence;
@class WTProtoUser;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoGroupPresent : NSObject

+ (WTProtoPresence *)presenceGroupWithRoomID:(WTProtoUser *)roomID;

@end

NS_ASSUME_NONNULL_END
