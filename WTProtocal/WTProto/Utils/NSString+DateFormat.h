//
//  NSString+DateFormat.h
//  wChatDemo
//
//  Created by Mark on 2018/6/15.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateFormat)


///格式化务 HH:mm 如：(18:03)
- (NSString *)transformDateWithHHMM;

///日期格式都要是yyyy-MM-dd
- (BOOL)isEqualToTimeString:(NSString *)otherTimeStr;

//对比两个时间是否同年同月
+ (BOOL)isSameYearAndMonthFromFirstTimeString:(NSString *)firstTimeStr twoTimeStr:(NSString *)twoTimeStr;


///返回所要的格式化后的时间
+ (NSString *)dateFormatterWithDate:(NSDate *)date format:(NSString *)format;


//时间戳转格式化时间：yyyy-MM-dd HH:mm:ss
+(NSString *)getTimeFromTimesTamp:(NSString *)timeStr;
//时间戳转格式化时间：yyyy-MM-dd HH:mm:ss(自定义格式)
+(NSString *)getTimeFromTimesTamp:(NSString *)timeStr format:(NSString *)format;
//将格式化的时间转换为时间戳
+(NSString *)getTimestampFromTime:(NSString *)timeStr format:(NSString *)format;

+(NSString *)getCurrentTimestamp;

+(NSDate *)cTimestampFromString:(NSString *)theTime;


@end
