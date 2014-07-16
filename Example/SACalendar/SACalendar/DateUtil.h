//
//  DateUtil.h
//  SACalendarExample
//
//  Helper class to simplify getting simple calendar information such as date
//
//  Created by Nop Shusang on 7/11/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

/**
 *  get the current calendar date (1-31)
 *
 *  @return current date in string format
 */
+(NSString*)getCurrentDate;

/**
 *  get the current month (1-12)
 *
 *  @return current month in string format
 */
+(NSString*)getCurrentMonth;

/**
 *  get the current year
 *
 *  @return current year in string format
 */
+(NSString*)getCurrentYear;

/**
 *  get the current day of week (Sunday-Monday)
 *
 *  @return current day of week
 */
+(NSString*)getCurrentDay;

/**
 *  get the complete date string, e.g. 4/1/2012
 *
 *  @return a complete date string
 */
+(NSString*)getCurrentDateString;

/**
 *  get the month string corresponding to the month number e.g. March is 3
 *
 *  @param index of month
 *
 *  @return month's name in string
 */
+(NSString*)getMonthString:(int)index;

/**
 *  get day of week, Sunday is 0 and Saturday is 6
 *
 *  @param index of week day
 *
 *  @return day's name string
 */
+(NSString*)getDayString:(int)index;

/**
 *  get how many days there are in a specific month and year. 
 *  gap years considered
 *
 *  @param month
 *  @param year
 *
 *  @return number of days in that specific month
 */
+(int)getDaysInMonth:(int)month year:(int)year;

/**
 *  get day of week (Sunday-Monday) of a specific date
 *
 *  @param date
 *  @param month
 *  @param year
 *
 *  @return day of week corresponding to a specific date
 */
+(NSString*)getDayOfDate:(int)date month:(int)month year:(int)year;


@end
