//
//  NSData+WTData.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (WTData)

- (nullable NSString *)base64EncodedString;

+ (nullable NSData *)dataWithBase64EncodedString:(NSString *)base64EncodedString;

@end

NS_ASSUME_NONNULL_END
