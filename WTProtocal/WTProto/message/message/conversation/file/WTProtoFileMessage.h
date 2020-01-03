//
//  WTProtoFileMessage.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/12/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoMediaMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTProtoFileMessage : WTProtoMediaMessage

@property(nonatomic,copy)NSString *msgContent;
@property(nonatomic,copy)NSString *fileExtension;
@property(nonatomic,copy)NSString *fileSize;


- (instancetype)initWithFromID:(NSString *)fromID
                      fromName:(NSString *)fromName
                          toID:(NSString *)toID
                        toName:(NSString *)toName
                    createTime:(NSString *)createTime
                         msgID:(NSString *)msgID
                    msgContent:(NSString *)msgContent
                     mediaPath:(NSString *)mediaPath
                 fileExtension:(NSString *)fileExtension
                      fileSize:(NSString *)fileSize
               destructionTime:(int64_t)destructionTime
                        device:(int64_t)device;


-(void)setMsgContent:(NSString * _Nonnull)msgContent;
-(void)setFileExtension:(NSString * _Nonnull)fileExtension;
-(void)setFileSize:(NSString * _Nonnull)fileSize;


@end

NS_ASSUME_NONNULL_END
