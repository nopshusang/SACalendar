SACalendar
==========

<p align="center">
  <img src="https://raw.githubusercontent.com/nopshusang/SACalendar/master/Screenshots/demo.png" alt="sample"/>
</p>

Introducing **SACalendar** - Easy to use and customizable iOS 7 Calendar

Only need 3 lines of code to set up. Every view customizable to fit your need.

This project uses the customized version of DMLazyScrollView (https://github.com/malcommac/DMLazyScrollView)

Installation
==========

- Add the **SACalendar** folder into your project. 
Make sure the "copy items into destination group's folder" box is checked

- Done

Basic Usage
==========
Import the class header
```objective-c
#import "SACalendar.h"
```

Initialize your calendar with the appropriate frame. The calendar will scale to fit your frame automatically.
```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    SACalendar *calendar = [[SACalendar alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
    
    calendar.delegate = self;
    
    [self.view addSubview:calendar];
}
```

Delegate (optional)
==========
SACalendar provides two delegate methods. didSelectDate gets called when a user click on a specific date. didDisplayCalendarForMonth gets called when the user swipe the calendar to a different month. To use it, implement the delegate in your view controller.
```objective-c
@interface ViewController () <SACalendarDelegate>
```
Then implement the optional delegate functions
```objective-c
// Prints out the selected date
-(void) SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year
{
    NSLog(@"%02i/%02/%i",month,year);
}

// Prints out the month and year displaying on the calendar
-(void) SACalendar:(SACalendar *)calendar didDisplayCalendarForMonth:(int)month year:(int)year{
    NSLog(@"%02/%i",month,year);
}
```

Customize
==========
- To customize the view properties such as cell size, font, colors, please see the class

```objective-c
SACalendarConstants.h
```
All ratio and UI constants are defined in this class. Change them to support your need.

- To customize the logic behind what's being displayed in the cells (i.e. red circle at selected date), see this function in SACalendar.m

```objective-c
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
```

- To customize the components (subviews) of the cell or to add some views to the cell, please see this function in SACalendarCell.m

```objective-c
- (id)initWithFrame:(CGRect)frame
```











