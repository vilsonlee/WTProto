//
//  WTProtoServerAddress.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/7.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoServerAddress.h"

@implementation WTProtoServerAddress


-(instancetype)initWithHost:(NSString *)host port:(uint16_t)port{
    
    self = [super init];
    if (self != nil)
    {
        _host = host;
        _port = port;
        _ip   = [WTProtoServerAddress getIPAddressByHostName:_host];

    }
    return self;
}

- (BOOL)isEqualToAddress:(WTProtoServerAddress *)other
{
    if (![other isKindOfClass:[WTProtoServerAddress class]])
        return false;
    
    if (![_ip isEqualToString:other.ip])
        return false;
    
    if (_port != other.port)
        return false;
    
    return true;
}


- (BOOL)isIpv6
{
    const char *utf8 = [_ip UTF8String];
    int success;
    
    struct in6_addr dst6;
    success = inet_pton(AF_INET6, utf8, &dst6);
    
    return success == 1;
}



- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    [aCoder encodeObject:_ip    forKey:@"ip"];
    [aCoder encodeObject:_host  forKey:@"host"];
    [aCoder encodeInt:_port     forKey:@"port"];
}



- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self != nil)
    {
        _ip     =           [aDecoder   decodeObjectForKey:@"ip"];
        _host   =           [aDecoder   decodeObjectForKey:@"host"];
        _port   = (uint16_t)[aDecoder   decodeIntForKey:@"port"];
    }
    return self;
}



+ (NSString *)realmToIP:(NSString *)host{

     const char *Host = [host UTF8String];
     // Get host entry info for given host
     struct hostent *remoteHostEnt = gethostbyname(Host);

     // Get address info from host entry
     struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];

     // Convert numeric addr to ASCII string
     char *sRemoteInAddr = inet_ntoa(*remoteInAddr);

     return [NSString stringWithFormat:@"%s",sRemoteInAddr];

 }

 + (NSString*)parsingIPAddress:(NSString*)host
 {
     const char* szname = [host UTF8String];
     struct hostent* phot ;
     @try
     {
         phot = gethostbyname(szname);
     }
     @catch (NSException * e)
     {
         return nil;
     }

     struct in_addr ip_addr;
     memcpy(&ip_addr,phot->h_addr_list[0],4);

     char ip[20] = {0};
     inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));

     NSString* strIPAddress = [NSString stringWithUTF8String:ip];

     return strIPAddress;
}


+ (NSString*)getIPAddressByHostName:(NSString*)host{

    Boolean result,bResolved;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;

    const char * hostAdd = [host UTF8String];

    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, hostAdd, kCFStringEncodingASCII);

    hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);

    result  = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
    if (result == TRUE) {
     addresses = CFHostGetAddressing(hostRef, &result);
     
    }

    bResolved = result == TRUE ? true : false;

    if(bResolved)
    {
     struct sockaddr_in* remoteAddr;
     for(int i = 0; i < CFArrayGetCount(addresses); i++)
     {
         CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
         remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);

         if(remoteAddr != NULL)
         {
             //get IP Address
             char ip[16];
             strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
             return [NSString stringWithUTF8String:ip];
         }
     }
    }
    
    CFRelease(hostNameRef);
    CFRelease(hostRef);
    
    return nil;
    
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@:%d", _ip == nil ? _host : _ip, (int)_port];
}


@end
