//
//  WTProtoStream.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/1.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <WTXMPPFramework/XMPPFramework.h>


typedef NS_ENUM(NSUInteger, WTProtoStreamCompressionMode) {
    WTProtoStreamCompressionNoneMode,              //NO_COMPRESSION
    WTProtoStreamCompressionBestSpeed,             //BEST_SPEED
    WTProtoStreamCompressionBestCompression,       //BEST_COMPRESSION
    WTProtoStreamCompressionDefaultCompression,    //DEFAULT_COMPRESSION
};

typedef NS_ENUM(NSUInteger, WTProtoStreamStartTLSPolicy) {
    WTProtoStreamStartTLSPolicyAllowed,   // TLS will be used if the server requires it
    WTProtoStreamStartTLSPolicyPreferred, // TLS will be used if the server offers it
    WTProtoStreamStartTLSPolicyRequired   // TLS will be used if the server offers it, else the stream won't connect
};


@class WTProtoUser;

@class WTProtoServerAddress;

@protocol WTProtoStreamDelegate <NSObject,XMPPStreamDelegate>


@end


NS_ASSUME_NONNULL_BEGIN

@interface WTProtoStream : XMPPStream


@property (nonatomic, strong,readonly)WTProtoUser* streamUser;

@property (nonatomic, strong,readonly)WTProtoServerAddress* serverAddress;


-(instancetype)initWithProtoUser:(WTProtoUser *)user
                   ServerAddress:(WTProtoServerAddress *)serverAddress
                  StartTLSPolicy:(WTProtoStreamStartTLSPolicy)startTLSPolicy
           StreamCompressionMode:(WTProtoStreamCompressionMode)streamCompressionMode;


-(void)resetStreamUser:(WTProtoUser*)user;

@end

NS_ASSUME_NONNULL_END
