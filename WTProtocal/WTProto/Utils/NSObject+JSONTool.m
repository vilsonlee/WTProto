//
//  NSObject+JSONTool.m
//  wChatDemo
//
//  Created by Vilson on 2018/6/6.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import "NSObject+JSONTool.h"
#import <objc/runtime.h>
#import "NSString+AES.h"
#import "NSString+Convert.h"

@implementation NSObject (JSONTool)

- (NSData *)JSONData{
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}

- (NSString *)JSONSToSring{
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return @"";
    }
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
}


-(NSString *)JSONSToSringNOSpace{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
    
}



+ (id)objectFromJSONString:(NSString *)jsonString{
    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

+ (nullable id)objectFromJSONData:(nullable NSData *)jsonData{
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
}







+ (NSDictionary*)getObjectData:(id)obj{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    unsigned int propsCount;
    
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    
    for(int i = 0;i < propsCount; i++){
        
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        
        if(value == nil){
            value = @"";//[NSNull null];
        }else{
            value = [self getObjectInternal:value];
        }
        
        [dic setObject:value forKey:propName];
    }
    return dic;
}


+ (NSDictionary*)getObjectData:(id)obj endOfSuperObject:(Class)superClass
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    Class cls = [obj class];
    unsigned int count;
    while (cls!=[NSObject class])
    {
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        for (int i = 0; i<count; i++)
        {
            objc_property_t property = properties[i];
            
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
               
            id value = [obj valueForKey:propertyName];
            if(value == nil)
            {
                value = @"";//[NSNull null];
            }else{
                value = [self getObjectInternal:value];
            }
            [dic setObject:value forKey:propertyName];
        }
       if (properties)
       {
           //要释放
          free(properties);
       }
        
        if (cls == superClass) {
            return dic;
        }
            //得到父类的信息
       cls = class_getSuperclass(cls);
    }
    return dic;
}





+ (void)print:(id)obj{
    NSLog(@"%@", [self getObjectData:obj]);
}





+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error{
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj] options:options error:error];
}


+ (NSData*)getJSON:(id)obj superClass:(Class)superClass options:(NSJSONWritingOptions)options error:(NSError**)error{
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj endOfSuperObject:superClass] options:options error:error];
}


+ (id)getObjectInternal:(id)obj{
    
    if([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSNull class]]){
        return obj;
    }

    if([obj isKindOfClass:[NSArray class]]){
        
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++){
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }

    if([obj isKindOfClass:[NSDictionary class]]){
        
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys){
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
    
}


+ (NSDictionary*)parsingMessageBody:(NSString* )messageBody{
    NSString * msgJsonStr = [NSString convertHTMLCharactorWithString:messageBody];
    NSData *jsonData = [msgJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *messageDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&err];
    return messageDic;
}



@end
