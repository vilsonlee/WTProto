//
//  WTProtoServerAddressSet.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/7.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "WTProtoServerAddressSet.h"

#import "WTProtoServerAddress.h"

@implementation WTProtoServerAddressSet


-(instancetype)initWithAddressList:(NSArray *)addressList{
    
    self = [super init];
    
    if (self != nil)
    {
        _addressList = addressList;
    }
    
    return self;
}


- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self != nil)
    {
       _addressList = [aDecoder decodeObjectForKey:@"addressList"];
    }
    
    return self;
}


- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    [aCoder encodeObject:_addressList forKey:@"addressList"];
    
}


- (BOOL)isEqual:(WTProtoServerAddressSet *)another
{
    if (![another isKindOfClass:[WTProtoServerAddressSet class]])
        return false;
    
    if (_addressList.count != another.addressList.count)
        return false;
    
    for (NSUInteger i = 0; i < _addressList.count; i++)
    {
        if (![_addressList[i] isEqual:another.addressList[i]])
            return false;
    }
    
    return true;
}


- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [string appendString:@"["];
    
    for (WTProtoServerAddressSet *address in _addressList)
    {
        if (string.length != 1)
            [string appendString:@", "];
        [string appendString:[address description]];
    }
    
    [string appendString:@"]"];
    
    return string;
}

- (WTProtoServerAddressSet *)firstAddress
{
    
    return _addressList.count == 0 ? nil : _addressList[0];
    
}







@end
