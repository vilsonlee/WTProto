//
//  NSObject+JSONTool.h
//  wChatDemo
//
//  Created by Vilson on 2018/6/6.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "xmppManager.h"

@interface NSObject (JSONTool)
/**
 *  对象转换为JSONData
 *
 *  @return NSData
 */
- (nullable NSData *)JSONData;

/**
 *  对象转换为JSONString
 *
 *  @return NSString
 */
- (nullable NSString *)JSONSToSring;


- (nullable NSString *)JSONSToSringNOSpace;


/**
 *  将JSONString转换为对象
 *
 *  @param jsonString json字符串
 *
 *  @return 对象
 */
+ (nullable id)objectFromJSONString:(nullable NSString *)jsonString;

/**
 *  将JSONString转换为对象
 *
 *  @param jsonData j
 *
 *  @return 对象
 */
+ (nullable id)objectFromJSONData:(nullable NSData *)jsonData;








//通过对象返回一个NSDictionary，键是属性名称，值是属性值。

+ (NSDictionary*)getObjectData:(id)obj;



//将getObjectData方法返回的NSDictionary转化成JSON

+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;



//直接通过NSLog输出getObjectData方法返回的NSDictionary

+ (void)print:(id)obj;


+ (NSDictionary*)parsingMessageBody:(NSString* )messageBody;


@end
