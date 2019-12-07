//
//  WTProtoUser.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import <WTXMPPFramework/XMPPFramework.h>
#import "WTProtoUser.h"

@interface WTProtoUser ()
{

}

@end

@implementation WTProtoUser

- (instancetype)initProtoUserWithUserID:(NSString *)userID
                             domain:(NSString *)domain
                           resource:(NSString *)resource
                           userType:(WTProtoUserType)userType
                        phoneNumber:(NSString *)phoneNumber
                           password:(NSString *)password
                           deviceID:(NSString *)deviceID
                         verifiCode:(NSString *)verifiCode
                  verifiMsgLanguage:(NSString *)verifiMsgLanguage
                        loginSource:(NSString *)loginSource
                      loginAuthType:(WTProtoUserLoginAuthType)loginAuthTyp{
    
    
    if (self = [super initJidwithUser:userID
                               domain:domain
                             resource:resource]) {
        
        _userID                 = [self user];
        _phoneNumber            = phoneNumber;
        _password               = password;
        _deviceID               = deviceID;
        _verifiCode             = verifiCode;
        _verifiMsgLanguage      = verifiMsgLanguage;
        _loginSource            = loginSource;
        
        _userType               = [self getUserType:userType];
        _loginAuthType          = [self getLoginAuthTyp:loginAuthTyp];
    }
    return self;
}


-(NSString* )getUserType:(WTProtoUserType)userType
{
    NSString* userTpyeStr;
    switch (userType) {
          case WTProtoUserTypeUserID:
              userTpyeStr = @"jid";
              break;
          case WTProtoUserTypePhoneNumber:
              userTpyeStr = @"phone";
              break;
          default:
              break;
      }
    return userTpyeStr;
}


-(NSString* )getLoginAuthTyp:(WTProtoUserLoginAuthType)loginAuthTyp
{
    NSString* loginAuthTypStr;
    switch (loginAuthTyp) {
        case WTProtoUserLoginAuthTypeCheckUser:
            loginAuthTypStr = @"check";
            break;
        case WTProtoUserLoginAuthTypeGetVerifiCode:
            loginAuthTypStr = @"getmsg";
            break;
        case WTProtoUserLoginAuthTypeCheckVerifiCode:
            loginAuthTypStr = @"checkmsg";
            break;
          default:
              break;
      }
    return loginAuthTypStr;
}


-(WTProtoUserType)getEnumUserType{
    
    NSUInteger ProtoUserType = WTProtoUserTypeUserID;
    
    if([self.userType isEqualToString:@"phone"])
        ProtoUserType = WTProtoUserTypePhoneNumber;
    
    return ProtoUserType;
}



-(WTProtoUserLoginAuthType)getEnumLoginAuthTyp;
{
    NSUInteger ProtoUserLoginAuthType = 0;

    if([self.loginAuthType isEqualToString:@"check"]){
        ProtoUserLoginAuthType = WTProtoUserLoginAuthTypeCheckUser;
    }
    
    if ([self.loginAuthType isEqualToString:@"getmsg"]) {
        ProtoUserLoginAuthType = WTProtoUserLoginAuthTypeGetVerifiCode;
    }
    if ([self.loginAuthType isEqualToString:@"checkmsg"]) {
        ProtoUserLoginAuthType = WTProtoUserLoginAuthTypeCheckVerifiCode;
    }
    
    return ProtoUserLoginAuthType;
}



-(void)setUserID:(NSString *)userID{
    
    _userID = userID;
}

-(void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
}

-(void)setPassword:(NSString *)password
{
    _password = password;
}


-(void)setDeviceID:(NSString *)deviceID
{
    _deviceID = deviceID;
}


-(void)setVerifiCode:(NSString *)verifiCode
{
    _verifiCode = verifiCode;
}


-(void)setVerifiMsgLanguage:(NSString *)verifiMsgLanguage
{
    _verifiMsgLanguage = verifiMsgLanguage;
}


-(void)setLoginSource:(NSString *)loginSource
{
    _loginSource = loginSource;
}



-(void)setLoginAuthType:(WTProtoUserLoginAuthType)loginAuthType
{
    _loginAuthType = [self getLoginAuthTyp:loginAuthType];
}

-(void)setUserType:(WTProtoUserType)userType{
    
    _userType = [self getUserType:userType];
    
}


-(void)setCountriesCode:(NSString *)countriesCode
{
    _countriesCode = countriesCode;
}


-(void)setCountrieName:(NSString *)countrieName
{
    _countrieName = countrieName;
}


-(void)setPhoneCode:(NSString *)phoneCode
{
    _phoneCode = phoneCode;
}


-(void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
}


-(void)setDeviceToken:(NSString *)deviceToken
{
    _deviceToken = deviceToken;
}




-(NSString*)fullPhoneNumber
{
  return [NSString stringWithFormat:@"%@%@",self.phoneCode,self.phoneNumber];
}


- (NSString *)getSource{
    
    NSString *source = [[@"Water.IM" stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    source = [[source stringByReplacingOccurrencesOfString:@"." withString:@""] lowercaseString];
    
    return source;
}

@end
