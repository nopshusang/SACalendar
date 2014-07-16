//
//  ViewController.m
//  SACalendar
//
//  Created by Nop Shusang on 7/12/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import "ViewController.h"
#import "SACalendar.h"
#import "DateUtil.h"

@interface ViewController () <SACalendarDelegate>

@property (strong, nonatomic) IBOutlet UILabel *dateSelectedLabel;
@property (strong, nonatomic) IBOutlet UILabel *displayLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    SACalendar *calendar = [[SACalendar alloc]initWithFrame:CGRectMake(0, 20, 320, 400)
                                            scrollDirection:ScrollDirectionHorizontal
                                              pagingEnabled:YES];
    
    calendar.delegate = self;
    
    [self.view addSubview:calendar];
}

-(void) SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year
{
    _dateSelectedLabel.text = [NSString stringWithFormat:@"Date Selected :      %02i/%02i/%04i",day,month,year];
}

-(void) SACalendar:(SACalendar *)calendar didDisplayCalendarForMonth:(int)month year:(int)year{
    _dateSelectedLabel.text = @"Date Selected : ";
    _displayLabel.text = [NSString stringWithFormat:@"Displaying :            %@ %04i",[DateUtil getMonthString:month],year];
}

@end
