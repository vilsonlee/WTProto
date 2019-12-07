//
//  NSObject+PerformSelector.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/26.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PerformSelector)

- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects;

@end

NS_ASSUME_NONNULL_END
