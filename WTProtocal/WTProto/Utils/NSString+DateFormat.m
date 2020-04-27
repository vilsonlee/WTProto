//
//  NSString+DateFormat.m
//  wChatDemo
//
//  Created by Mark on 2018/6/15.
//  Copyright © 2018年 VilsonLee.Saura.cn. All rights reserved.
//

#import "NSString+DateFormat.h"

@implementation NSString (DateFormat)

///判断是否同一天
- (BOOL)isEqualToTimeString:(NSString *)otherTimeStr
{
    //FIXME: 添加断言保证
    
    NSString *cmp1 = [[NSString getTimeFromTimesTamp:otherTimeStr] substringToIndex:10];
    NSString *cmp2 = [[NSString getTimeFromTimesTamp:self] substringToIndex:10];
    
    return [cmp1 isEqualToString:cmp2];
}


- (NSString *)transformDateWithHHMM
{
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * cdate = [dateformat dateFromString:self];
    
    NSDateFormatter * hhmmformatter = [[NSDateFormatter alloc] init];
    hhmmformatter.dateFormat = @"HH:mm";
    NSString *time = [hhmmformatter stringFromDate:cdate];
    
    return time;
}


//时间戳转格式化时间：yyyy-MM-dd HH:mm:ss
+ (NSString *)getTimeFromTimesTamp:(NSString *)timeStr
{
    double time = [timeStr doubleValue];
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //将时间转换为字符串
    NSString *timeS = [formatter stringFromDate:myDate];
    return timeS;
    
}

+(NSString *)getTimeFromTimesTamp:(NSString *)timeStr format:(NSString *)format
{
    if (timeStr.length == 16) {
        timeStr = [timeStr substringToIndex:13];
    }
    if (timeStr.length == 10) {
        timeStr = [timeStr stringByAppendingString:@"000"];
    }
    double time = [timeStr doubleValue];
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:format];
    
    //将时间转换为字符串
    NSString *timeS = [formatter stringFromDate:myDate];
    return timeS;
}


//对比两个时间是否同年同月
+ (BOOL)isSameYearAndMonthFromFirstTimeString:(NSString *)firstTimeStr twoTimeStr:(NSString *)twoTimeStr
{
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *fdate = [dateformat dateFromString:[NSString getTimeFromTimesTamp:firstTimeStr]];
    NSDate *tdate = [dateformat dateFromString:[NSString getTimeFromTimesTamp:twoTimeStr]];
    
    NSCalendar * calendar = [NSCalendar currentCalendar];

    NSDateComponents * fComps = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday ) fromDate:fdate];
    
    NSDateComponents * tComps = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday ) fromDate:tdate];
    
    if (fComps.year == tComps.year) {
        if (fComps.month == tComps.month) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)dateFormatterWithDate:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setLocale:[NSLocale currentLocale]];

    NSString * dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

//将格式化的时间转换为时间戳
+(NSString *)getTimestampFromTime:(NSString *)timeStr format:(NSString *)format
{
    //转换为时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    NSDate* dateTodo = [formatter dateFromString:timeStr];
    
    NSTimeInterval time=[dateTodo timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", time];
    
    return timeSp;
}

+(NSDate *)cTimestampFromString:(NSString *)theTime{
 
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* dateTodo = [formatter dateFromString:theTime];
    
    return dateTodo;
}

+(NSString *)getCurrentTimestamp
{
    NSDate * date           = [[NSDate date] dateByAddingTimeInterval:-0];//当前正确时间
    NSTimeInterval time     = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString    = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}



@end
