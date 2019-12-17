//
//  WTProtoRegister.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/18.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoRegister.h"
#import "WTProtoStream.h"
#import "WTProtoUser.h"
#import "WTProtoQueue.h"
#import "WTProtoServerAddress.h"
#import "XMLDictionary.h"


static WTProtoRegister *protoRegister = nil;
static dispatch_once_t onceToken;

static WTProtoQueue *queue = nil;
static dispatch_once_t queueOnceToken;

@interface WTProtoRegister ()<WTProtoStreamDelegate>
{
    WTProtoQueue*  protoRegisterQueue;
    GCDMulticastDelegate <WTProtoRegisterDelegate> *protoRegisterMulticasDelegate;
}
@end


@implementation WTProtoRegister



+(WTProtoQueue*)registerQueue{
    
    dispatch_once(&queueOnceToken, ^
    {
        queue = [[WTProtoQueue alloc] initWithName:"org.wtproto.Queue:register"];
    });
    return queue;
    
}


+ (void)dellocSelf
{
    protoRegister = nil;
    onceToken = 0l;
    
    queue = nil;
    queueOnceToken = 0l;
}


+(WTProtoRegister*)shareRegisterWithProtoStream:(WTProtoStream *)protoStream interface:(NSString *)interface{
    
    dispatch_once(&onceToken, ^{
        
        protoRegister = [[WTProtoRegister alloc]initRegisterWithProtoStream:protoStream
                                                                  interface:interface];
    });
    return protoRegister;
}


- (instancetype )initRegisterWithProtoStream:(WTProtoStream *)protoStream
                                    interface:(NSString *)interface
{
    
    #ifdef DEBUG
        NSAssert(protoStream != nil, @"protoStream should not be nil");
    #endif

    if (self = [super init])
    {
        _registerStream     = protoStream;
        _registerUser       = protoStream.streamUser;
        _serverAddress      = protoStream.serverAddress;
        
        protoRegisterQueue = [WTProtoRegister registerQueue];
        
        protoRegisterMulticasDelegate = (GCDMulticastDelegate <WTProtoRegisterDelegate> *)[[GCDMulticastDelegate alloc] init];
        
        [_registerStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
        
    }

    return self;
    
}


-(void)addProtoRegisterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    
    [protoRegisterQueue dispatchOnQueue:^{

        [self->protoRegisterMulticasDelegate addDelegate:delegate delegateQueue:delegateQueue];

    } synchronous:NO];
}


- (void)removeProtoRegisterDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    
    [protoRegisterQueue dispatchOnQueue:^{

          [self->protoRegisterMulticasDelegate removeDelegate:delegate delegateQueue:delegateQueue];

      } synchronous:YES];
}


- (void)removeProtoRegisterDelegate:(id)delegate
{

    [protoRegisterQueue dispatchOnQueue:^{

          [self->protoRegisterMulticasDelegate removeDelegate:delegate];

      } synchronous:YES];
}


-(void)resetRegisterStream:(WTProtoStream*)protoStream
{
    
    [_registerStream removeDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
    
    _registerStream     = protoStream;
    _registerUser       = protoStream.streamUser;
    _serverAddress      = protoStream.serverAddress;
    
    [_registerStream addDelegate:self delegateQueue:[[WTProtoQueue mainQueue] nativeQueue]];
}



-(BOOL)checkRegister
{
    NSMutableArray *elements = [self createDefaultFieldElement];
    
    [elements addObject:[self createFieldElementWithStringValue:@"true"
                                               fieldElementType:nil
                                                      varString:@"checkexists"]];
    
    BOOL result = [self.registerStream registerWithElements:elements error:nil];

    [protoRegisterMulticasDelegate WTProtoRegister:self RegisterStatus:WTProtoUserRegisterCheck withError:nil];
    
    return result;
}


-(BOOL)registerWithError:(NSError *__autoreleasing  _Nullable *)errPtr
{
    NSMutableArray *elements = [self createDefaultFieldElement];
    
    [elements addObject:[self createFieldElementWithStringValue:self.registerUser.nickName
                                               fieldElementType:nil
                                                      varString:@"nickname"]];

    [elements addObject:[self createFieldElementWithStringValue:self.registerUser.countrieName
                                               fieldElementType:nil
                                                      varString:@"city"]];

    [elements addObject:[self createFieldElementWithStringValue:self.registerUser.deviceID
                                               fieldElementType:nil
                                                      varString:@"deviceid"]];
    
    [elements addObject:[self createFieldElementWithStringValue:self.registerUser.deviceToken
                                               fieldElementType:nil
                                                      varString:@"token"]];
    
    [elements addObject:[self createFieldElementWithStringValue:@"i"
                                               fieldElementType:nil
                                                      varString:@"platform"]];
    
    BOOL result = [self.registerStream registerWithElements:elements error:nil];
    
    [protoRegisterMulticasDelegate WTProtoRegister:self RegisterStatus:WTProtoUserRegisterStart withError:nil];

    return result;
    
}



-(NSMutableArray* )createDefaultFieldElement{
    
    NSString* FieldElementString =  [NSString stringWithFormat:@"%@%@",self.registerUser.phoneCode,
                                                                       self.registerUser.userID];
    
    NSMutableArray *elements = [NSMutableArray array];
    
    [elements addObject:[self createFieldElementWithStringValue:FieldElementString
                                               fieldElementType:nil
                                                      varString:@"phone"]];
    
    return elements;
}




- (NSXMLElement *)createFieldElementWithStringValue:(NSString *)value fieldElementType:(NSString *)type varString:(NSString *)var
{
    if (type.length == 0 || type == nil)
    {
        type = @"text-single";
    }
    
    NSXMLElement *fieldElement = [NSXMLElement elementWithName:@"field"];
    [fieldElement addAttributeWithName:@"type" stringValue:type];
    [fieldElement addAttributeWithName:@"var" stringValue:var];
    [fieldElement addChild:[NSXMLElement elementWithName:@"value" stringValue:value]];
    
    return fieldElement;
}





-(void)xmppStreamDidRegister:(XMPPStream *)sender response:(DDXMLElement *)response
{
    NSInteger registerState = WTProtoUserRegisterNone;
    
    NSXMLElement * queryElement = [response elementForName:@"query" xmlns:@"jabber:iq:register"];
    
    if (queryElement) {
        
        registerState = WTProtoUserRegisterSuccess;
        
        NSString *outgoingStr = [response compactXMLString];
        NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLString:outgoingStr];
        
        NSString *password = [[xmlDict valueForKey:@"query"] valueForKey:@"password"];
        NSString *userID = [[xmlDict valueForKey:@"query"] valueForKey:@"username"];
        
        [self.registerUser setUserID:userID];
        [self.registerUser setPassword:password];
        
    }
    
    [protoRegisterMulticasDelegate WTProtoRegister:self RegisterStatus:registerState withError:nil];
}



-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    
    NSError* Error;
    NSInteger registerState;
    
    NSInteger errorCode = [[[[error elementForName:@"error"] attributeForName:@"code"] stringValue] integerValue];
    NSString* errorMessage;
    
    if (errorCode == 409)
    {
        errorMessage = @"user already exists";
        registerState = WTProtoUserRegisterAlready;
    }
    else
    {
        registerState = WTProtoUserRegisterFail;
        errorMessage = @"User registration failed";
    }
    
    NSString *const ErrorDomain = @"GCDAsyncSocketErrorDomain";
   
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
   
    Error = [[NSError alloc]initWithDomain:ErrorDomain code:3 userInfo:userInfo];

    [protoRegisterMulticasDelegate WTProtoRegister:self RegisterStatus:registerState withError:Error];
    
}



@end
