//
//  WTProtoUserInfoIQ.h
//  WTProtocalKit
//
//  Created by Vilson on 2020/1/16.
//  Copyright © 2020 Vilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTProtoIQ;
@class WTProtoUser;
@class XMPPIQ;

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoUserInfoIQ : NSObject

+ (WTProtoIQ *)IQ_SearchUserInfoWithLocalUser:(WTProtoUser*)localUser
                                      KeyWord:(NSString *)key
                                      keyType:(NSString *)type
                              searchFromGroup:(BOOL)fromGroup;

+ (void)parse_IQ_SearchUserInfo:(XMPPIQ *)iq
                    parseResult:(void (^)(BOOL succeed, id Info))parseResult;


NS_ASSUME_NONNULL_END

@end


