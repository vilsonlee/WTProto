//
//  WTProtoUser.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/12.
//  Copyright © 2019 Vilson. All rights reserved.
//  38996484723921   0Aeykd7w
//  3a6c35d4c1c2b88fbfd9c37ed2adbfd9bca35f58
/***
 iphoneName = VilsonX
 systemName = iOS
 systemVersion = 12.2
 deviceModel = iPhone
 */

#import <WTXMPPFramework/XMPPFramework.h>



typedef NS_ENUM(NSInteger, WTProtoUserType) {
    
    WTProtoUserTypeUserID           = 0,
    WTProtoUserTypePhoneNumber      
};


typedef NS_ENUM(NSInteger, WTProtoUserLoginAuthType) {
    
    WTProtoUserLoginAuthTypeCheckUser       = 0,
    WTProtoUserLoginAuthTypeGetVerifiCode,
    WTProtoUserLoginAuthTypeCheckVerifiCode
};


NS_ASSUME_NONNULL_BEGIN

@interface WTProtoUser : XMPPJID

@property (nonatomic, copy, readonly)NSString *userID;              //用户ID             (JID user)
@property (nonatomic, copy, readonly)NSString *userType;            //登录类型            (jid/phone）
@property (nonatomic, copy, readonly)NSString *phoneNumber;         //手机号码
@property (nonatomic, copy, readonly)NSString *password;            //密码
@property (nonatomic, copy, readonly)NSString *deviceID;            //设备OPEN_UUID      (换设备)
@property (nonatomic, copy, readonly)NSString *verifiCode;          //验证码
@property (nonatomic, copy, readonly)NSString *verifiMsgLanguage;   //app显示语言         (决定验证码短讯的语言)
@property (nonatomic, copy, readonly)NSString *loginSource;         //来源哪个APP
@property (nonatomic, copy, readonly)NSString *loginAuthType;       //验证登录类型         (check/getmsg/checkmsg)

@property (nonatomic, copy, readonly)NSString *countriesCode;       //国家对应的地区码
@property (nonatomic, copy, readonly)NSString *countrieName;        //国家名称
@property (nonatomic, copy, readonly)NSString *phoneCode;           //国家对应的号码区号
@property (nonatomic, copy, readonly)NSString *nickName;            //昵称
@property (nonatomic, copy, readonly)NSString *deviceToken;         //设备Tokekn 用于推送

@property (nonatomic, copy, readonly)NSString *currentDeviceName;   //用户当前操作系统
@property (nonatomic, copy, readonly)NSString *currentAPPVersion;   //用户当前APP版本
@property (nonatomic, copy, readonly)NSString *currentDeviceOS;     //用户当前操作系统


- (instancetype)initProtoUserWithUserID:(NSString *)userID
                                 domain:(NSString *)domain
                               resource:(NSString *)resource
                               userType:(WTProtoUserType)userType
                            phoneNumber:(NSString *)phoneNumber
                              phoneCode:(NSString *)phoneCode
                               password:(NSString *)password
                               deviceID:(NSString *)deviceID
                            deviceToken:(NSString *)deviceToken
                             verifiCode:(NSString *)verifiCode
                      verifiMsgLanguage:(NSString *)verifiMsgLanguage
                            loginSource:(NSString *)loginSource
                          loginAuthType:(WTProtoUserLoginAuthType)loginAuthType
                      currentDeviceName:(NSString *)currentDeviceName
                      currentAPPVersion:(NSString *)currentAPPVersion
                        currentDeviceOS:(NSString *)currentDeviceOS;



- (void)setUserID:(NSString * _Nonnull)userID;
- (void)setPhoneNumber:(NSString * _Nonnull)phoneNumber;
- (void)setPassword:(NSString * _Nonnull)password;
- (void)setDeviceID:(NSString * _Nonnull)deviceID;
- (void)setVerifiCode:(NSString * _Nonnull)verifiCode;
- (void)setVerifiMsgLanguage:(NSString * _Nonnull)verifiMsgLanguage;
- (void)setLoginSource:(NSString * _Nonnull)loginSource;

- (void)setUserType:(WTProtoUserType)userType;
- (void)setLoginAuthType:(WTProtoUserLoginAuthType)loginAuthType;


- (void)setCountriesCode:(NSString * _Nonnull)countriesCode;
- (void)setCountrieName:(NSString * _Nonnull)countrieName;
- (void)setPhoneCode:(NSString * _Nonnull)phoneCode;
- (void)setNickName:(NSString * _Nonnull)nickName;
- (void)setDeviceToken:(NSString * _Nonnull)deviceToken;

- (void)setCurrentDeviceName:(NSString * _Nonnull)currentDeviceName;
- (void)setCurrentAPPVersion:(NSString * _Nonnull)currentAPPVersion;
- (void)setCurrentDeviceOS:(NSString * _Nonnull)currentDeviceOS;

- (WTProtoUserLoginAuthType)getEnumLoginAuthTyp;
- (WTProtoUserType)getEnumUserType;
- (NSString*)fullPhoneNumber;


@end

NS_ASSUME_NONNULL_END
