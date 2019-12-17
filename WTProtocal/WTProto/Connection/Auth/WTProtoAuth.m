//
//  WTProtoAuth.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoAuth.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoQueue.h"
#import "WTProtoServerAddress.h"

static WTProtoAuth *protoAuth = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *queue = nil;
static dispatch_once_t queueOnceToken;

@interface WTProtoAuth ()<WTProtoStreamDelegate>
{
    WTProtoQueue*  protoAuthQueue;
    GCDMulticastDelegate <WTProtoAuthDelegate> *protoAuthMulticasDelegate;
}
@end


@implementation WTProtoAuth


+(WTProtoQueue*)authQueue{
    
    dispatch_once(&queueOnceToken, ^
    {
        queue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:auth"];
    });
    return queue;
    
}


+ (void)dellocSelf
{
    protoAuth = nil;
    onceToken = 0l;
    
    queue = nil;
    queueOnceToken  = 0l;
    
}


+(WTProtoAuth *)shareAuthWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface
{
    dispatch_once(&onceToken, ^{
        
        protoAuth = [[WTProtoAuth alloc]initAuthWithProtoStream:protoStream
                                                      interface:interface];
        

        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return protoAuth;
}


- (instancetype )initAuthWithProtoStream:(WTProtoStream *)protoStream
                               interface:(NSString *)interface
{
    #ifdef DEBUG
         NSAssert(protoStream != nil, @"protoStream should not be nil");
     #endif

     if (self = [super init])
     {
         _authStream    = protoStream;
         _authUser      = protoStream.streamUser;
         _serverAddress = protoStream.serverAddress;
         
         protoAuthQueue = [WTProtoAuth authQueue];
         
         protoAuthMulticasDelegate = (GCDMulticastDelegate <WTProtoAuthDelegate> *)[[GCDMulticastDelegate alloc] init];
         
         [_authStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
         
     }

     return self;
}


-(void)addProtoAuthDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoAuthQueue dispatchOnQueue:^{

        [self->protoAuthMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}


- (void)removeProtoAuthDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{

    [protoAuthQueue dispatchOnQueue:^{

          [self->protoAuthMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

      } synchronous:YES];
}


- (void)removeProtoAuthDelegate:(id)delegate
{

    [protoAuthQueue dispatchOnQueue:^{

          [self->protoAuthMulticasDelegate removeDelegate:delegate];

      } synchronous:YES];
}


-(void)resetAuthStream:(WTProtoStream*)protoStream
{
    
    [_authStream removeDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
    _authStream    = protoStream;
    _authUser      = protoStream.streamUser;
    _serverAddress = protoStream.serverAddress;
    
    [_authStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
}


- (BOOL)authenticateWithError:(NSError **)errPtr
{
    
    if (![_authStream.serverAddress.host isEqualToString:_serverAddress.host]) {
        return NO;
    }
    
    BOOL result = NO;
        
    result = [_authStream authenticateWithPassword:_authStream.streamUser.password error:errPtr];
    
    [protoAuthMulticasDelegate WTProtoAuth:self AuthenticateState:WTProtoUserAuthenticatStart                                                                          withError:nil];
    
    if (result && !errPtr) {
        result = YES;
    }else{
        result = NO;
    }
    return result;
    
}


-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidAuthenticate");
    
    [protoAuthMulticasDelegate WTProtoAuth:self AuthenticateState:WTProtoUserAuthenticated withError:nil];
    
}



-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    //    if ([error.xmlns isEqualToString:@"urn:ietf:params:xml:ns:xmpp-sasl"]) {}
    NSError* Error;
    NSUInteger authState = WTProtoUserAuthenticateFail;
            
    NSXMLElement * errorElement = [error elementForName:@"text"];
    NSString* errorMessage      = [errorElement stringValue];
    
    NSUInteger LoginAuthTyp  = [self.authStream.streamUser getEnumLoginAuthTyp];
    
    if (LoginAuthTyp == WTProtoUserLoginAuthTypeGetVerifiCode)
    {
        
        if ([errorMessage isEqualToString:@"gmsuccess"])
        {
            authState = WTProtoUserAuthenticatGetVerifiCodeSuccess;
        }
        if ([errorMessage isEqualToString:@"seclimit"])
        {
            authState = WTProtoUserAuthenticatGetVerifiCodeSeclimit;
        }
        if ([errorMessage isEqualToString:@"daylimit"])
        {
            authState = WTProtoUserAuthenticatGetVerifiCodeDaylimit;
            
        }if ([errorMessage isEqualToString:@"usernotfound"])
        {
            authState = WTProtoUserAuthenticatGetVerifiCodeNoTFound;
        }
        if ([errorMessage isEqualToString:@"msgerror"])
        {
            authState = WTProtoUserAuthenticatGetVerifiCodeError;
        }
    }
    
    if (LoginAuthTyp == WTProtoUserLoginAuthTypeCheckVerifiCode)
    {
        if ([errorMessage isEqualToString:@"cmfailure"])
        {
            authState = WTProtoUserAuthenticatCheckVerifiCodeFail;
        }
        else if ([errorMessage isEqualToString:@"expire"])
        {
            authState = WTProtoUserAuthenticatCheckVerifiCodeExpire;
        }
        else if ([errorMessage isEqualToString:@"usernotfound"])
        {
            authState = WTProtoUserAuthenticatCheckUserNotFound;
        }
        else if ([errorMessage isEqualToString:@"notfound"])
        {
            authState = WTProtoUserAuthenticatCheckVerifiCodeNotFound;
        }
        else if ([errorMessage isEqualToString:@"updateerror"])
        {
            authState = WTProtoUserAuthenticatCheckVerifiCodeUpdateError;
        }
        else if ([errorMessage isEqualToString:@"Unsupported mechanism"])
        {
            authState = WTProtoUserAuthenticatCheckUnsupportedMechanism;
        }
        else
        {
            authState = WTProtoUserAuthenticatCheckVerifiCodeSuccess;
        }
    }
    
    if (LoginAuthTyp == WTProtoUserLoginAuthTypeCheckUser)
    {
        if ([errorMessage isEqualToString:@"needupgrade"])
        {
            authState = WTProtoUserAuthenticateNeedUpgrade;
        }
        if ([errorMessage isEqualToString:@"needmsg"])
        {
            authState = WTProtoUserAuthenticateNeedVerifiCode;
        }
        if ([errorMessage isEqualToString:@"Invalid username or password"])
        {
            authState = WTProtoUserAuthenticateInvalidUser;
        }
    }
    
    NSString *const ErrorDomain = @"WTProtoAuthErrorDomain";
     
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                         forKey:NSLocalizedDescriptionKey];
    
    Error = [[NSError alloc]initWithDomain:ErrorDomain code:3 userInfo:userInfo];
        
    [protoAuthMulticasDelegate WTProtoAuth:self AuthenticateState:authState withError:Error];
    
}


@end
