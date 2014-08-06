//
//  DateUtil.m
//  SACalendarExample
//
//  Created by Nop Shusang on 7/11/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import "DateUtil.h"

@implementation DateUtil

+(NSString*)getCurrentDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    [formatter setCalendar:gregorianCalendar];
    [formatter setDateFormat:@"dd"];
    return [formatter stringFromDate:[NSDate date]];
}

+(NSString*)getCurrentMonth
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    [formatter setCalendar:gregorianCalendar];
    [formatter setDateFormat:@"MM"];
    return [formatter stringFromDate:[NSDate date]];
}

+(NSString*)getCurrentYear
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    [formatter setCalendar:gregorianCalendar];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

+(NSString*)getCurrentDay
{
    NSDateFormatter* theDateFormatter = [[NSDateFormatter alloc] init];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [theDateFormatter setCalendar:gregorianCalendar];
    
    [theDateFormatter setDateFormat:@"EEEE"];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [theDateFormatter setLocale:usLocale];
    
    NSString *weekDay =  [theDateFormatter stringFromDate:[NSDate date]];
    return weekDay;
}

+(NSString*)getCurrentDateString
{
    return [NSString stringWithFormat:@"%@/%@/%@",[self getCurrentMonth],[self getCurrentDate],[self getCurrentYear]];
}


+(NSString*)getMonthString:(int)index
{
    NSArray *months = [[NSArray alloc]initWithObjects:@"January",@"Febuary",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December", nil];
    return [months objectAtIndex:index-1];
}

+(NSString*)getDayString:(int)index
{
    NSArray *daysInWeeks = [[NSArray alloc]initWithObjects:@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday", nil];
    return [daysInWeeks objectAtIndex:index];
}


+(int)getDaysInMonth:(int)month year:(int)year
{
    int daysInFeb = 28;
    if (year%4 == 0) {
        daysInFeb = 29;
    }
    int daysInMonth [12] = {31,daysInFeb,31,30,31,30,31,31,30,31,30,31};
    return daysInMonth[month-1];
}

+(NSString*)getDayOfDate:(int)date month:(int)month year:(int)year
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setCalendar:gregorianCalendar];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    NSDate *capturedStartDate = [dateFormatter dateFromString: [NSString stringWithFormat:@"%04i-%02i-%02i",year,month,date]];
    
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setLocale:usLocale];
    
    [weekday setDateFormat: @"EEEE"];
    
    return [weekday stringFromDate:capturedStartDate];
}
@end
