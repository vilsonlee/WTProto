//
//  WTProtoStream.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/1.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoStream.h"
#import "WTProtoServerAddress.h"
#import "WTProtoQueue.h"
#import "WTProtoUser.h"

@interface WTProtoStream()
{
    
    WTProtoQueue* protoSteamQueue;
    GCDMulticastDelegate <WTProtoStreamDelegate> *protoStreamMulticasDelegate;
    
}

@end

@implementation WTProtoStream


-(instancetype)initWithProtoUser:(WTProtoUser *)user
                   ServerAddress:(WTProtoServerAddress *)serverAddress
                  StartTLSPolicy:(WTProtoStreamStartTLSPolicy)startTLSPolicy
           StreamCompressionMode:(WTProtoStreamCompressionMode)streamCompressionMode{
    
    #ifdef DEBUG
        NSAssert(serverAddress != nil, @"address should not be nil");
    #endif
        
    self = [super init];
    if (self != nil)
    {
        [self commonProtoSteamInitWithProtoUser:user
                                  ServerAddress:serverAddress
                                 StartTLSPolicy:startTLSPolicy
                          StreamCompressionMode:streamCompressionMode];
    }
    
    return self;

}


-(void)commonProtoSteamInitWithProtoUser:(WTProtoUser *)user
                           ServerAddress:(WTProtoServerAddress *)serverAddress
                          StartTLSPolicy:(WTProtoStreamStartTLSPolicy)startTLSPolicy
                   StreamCompressionMode:(WTProtoStreamCompressionMode)streamCompressionMode{
    
    
    protoSteamQueue = [[WTProtoQueue alloc]initWithName:@"org.wtproto.Queue:stram"];
    
    protoStreamMulticasDelegate = (GCDMulticastDelegate <WTProtoStreamDelegate> *)[[GCDMulticastDelegate alloc] init];
    
    _streamUser                  = user;
    _serverAddress               = serverAddress;
    
    self.hostName                = serverAddress.host;
    self.hostPort                = serverAddress.port;
    self.startTLSPolicy          = [self initStreamStartTLSPolicy:startTLSPolicy];
    self.streamCompressionMode   = [self initStreamCompressionMode:streamCompressionMode];
    self.openStreamCompress      = [self initStreamCompressionMode:streamCompressionMode];
    
    self.myJID                   = user;
    
    self.deviceID                = user.deviceID;
    self.deviceToken             = user.deviceToken;
    self.userType                = user.userType;
    self.password                = user.password;
    self.verifiCode              = user.verifiCode;
    self.verifiMsgLanguage       = user.verifiMsgLanguage;
    self.loginSource             = user.loginSource;
    self.loginAuthType           = user.loginAuthType;
    
    self.currentDeviceName       = user.currentDeviceName;
    self.currentAPPVersion       = user.currentAPPVersion;
    self.currentDeviceOS         = user.currentDeviceOS;
}

-(void)resetStreamUser:(WTProtoUser*)user
{
    _streamUser                  = user;
    self.myJID                   = user;
    self.deviceID                = user.deviceID;
    self.deviceToken             = user.deviceToken;
    self.userType                = user.userType;
    self.password                = user.password;
    self.verifiCode              = user.verifiCode;
    self.verifiMsgLanguage       = user.verifiMsgLanguage;
    self.loginSource             = user.loginSource;
    self.loginAuthType           = user.loginAuthType;
       
    self.currentDeviceName       = user.currentDeviceName;
    self.currentAPPVersion       = user.currentAPPVersion;
    self.currentDeviceOS         = user.currentDeviceOS;
}


-(XMPPStreamStartTLSPolicy)initStreamStartTLSPolicy:(WTProtoStreamStartTLSPolicy)startTLSPolicy{

    
    NSUInteger xmppStartTLSPolicy;
    
    switch (startTLSPolicy) {
        case WTProtoStreamStartTLSPolicyAllowed:
            xmppStartTLSPolicy = XMPPStreamStartTLSPolicyAllowed;
            break;
        case WTProtoStreamStartTLSPolicyPreferred:
            xmppStartTLSPolicy = XMPPStreamStartTLSPolicyPreferred;
            break;
        case WTProtoStreamStartTLSPolicyRequired:
            xmppStartTLSPolicy = XMPPStreamStartTLSPolicyRequired;
            break;
        default:
            break;
    }
    
    return xmppStartTLSPolicy;
}



-(XMPPStreamCompressionMode)initStreamCompressionMode:(WTProtoStreamCompressionMode)streamCompressionMode{
    
    NSUInteger xmppCompressionMode;
    
    switch (streamCompressionMode) {
        case WTProtoStreamCompressionNoneMode:
            xmppCompressionMode = XMPPStreamCompressionNoneMode;
            break;
        case WTProtoStreamCompressionBestCompression:
            xmppCompressionMode = XMPPStreamCompressionBestCompression;
            break;
        case WTProtoStreamCompressionBestSpeed:
            xmppCompressionMode = XMPPStreamCompressionBestSpeed;
            break;
        case WTProtoStreamCompressionDefaultCompression:
            xmppCompressionMode = XMPPStreamCompressionDefaultCompression;
            break;
        default:
            break;
    }
    
    return xmppCompressionMode;
}




-(void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    
    [super addDelegate:delegate delegateQueue:delegateQueue];
    
    [protoSteamQueue dispatchOnQueue:^{
    
        [self->protoStreamMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];
        
    } synchronous:NO];
    
}



-(void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue{
    
    [super removeDelegate:delegate delegateQueue:delegateQueue];
    
    [protoSteamQueue dispatchOnQueue:^{
        
        [self->protoStreamMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];
        
    } synchronous:YES];
    
}



-(void)removeDelegate:(id)delegate{
    
    [super removeDelegate:delegate];
    
    [protoSteamQueue dispatchOnQueue:^{
        
        [self->protoStreamMulticasDelegate removeDelegate:delegate];
        
    } synchronous:YES];
}


@end
