//
//  WTProtoServerAddress.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/7.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <netinet/in.h>

#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoServerAddress : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, strong, readonly) NSString *ip;
@property (nonatomic, readonly) uint16_t port;

- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port;

- (BOOL)isEqualToAddress:(WTProtoServerAddress *)other;

- (BOOL)isIpv6;

@end

NS_ASSUME_NONNULL_END
