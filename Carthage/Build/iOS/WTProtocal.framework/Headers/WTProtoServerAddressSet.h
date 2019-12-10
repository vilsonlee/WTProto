//
//  WTProtoServerAddressSet.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/7.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoServerAddress;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoServerAddressSet : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSArray *addressList;


- (instancetype)initWithAddressList:(NSArray *)addressList;

- (WTProtoServerAddress *)firstAddress;

@end

NS_ASSUME_NONNULL_END
