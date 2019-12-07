//
//  NSString+pyFirstLetter.m
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/25.
//  Copyright © 2019 Vilson. All rights reserved.
//

#import "NSString+pyFirstLetter.h"

@implementation NSString (pyFirstLetter)

+ (NSString *)pyFirstLetter:(NSString*)hanzi
{
    NSLog(@"%@",hanzi);

    if (hanzi.length == 0 || hanzi == nil) {
        return @"#";
    }
    
    NSMutableString *mutableString = [NSMutableString stringWithString:hanzi];
    
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, NO);
    
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    
    NSString *pinYin = [mutableString substringToIndex:1];
    NSInteger keyInt = [pinYin characterAtIndex:0];
     
    if (keyInt >= 97 && keyInt <= 122) {
        return [pinYin uppercaseString];
    }
    if (keyInt >= 65 && keyInt <= 90) {
        return [pinYin uppercaseString];
    }
    
    return @"#";
}


@end
