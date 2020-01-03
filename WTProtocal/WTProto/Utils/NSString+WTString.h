//
//  NSString+WTString.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (WTString)

- (nullable NSString *)base64EncodedString;

+ (nullable NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString;


@end

NS_ASSUME_NONNULL_END
