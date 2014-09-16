//
//  SACalendar.m
//  SACalendarExample
//
//  Created by Nop Shusang on 7/10/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import "SACalendar.h"
#import "SACalendarCell.h"
#import "DMLazyScrollView.h"
#import "DateUtil.h"

@interface SACalendar () <UICollectionViewDataSource, UICollectionViewDelegate>{
    DMLazyScrollView* scrollView;
    NSMutableDictionary *controllers;
    NSMutableDictionary *calendars;
    NSMutableDictionary *monthLabels;
    
    int year, month;
    int prev_year, prev_month;
    int next_year, next_month;
    int current_date, current_month, current_year;
    
    int state, scroll_state;
    int previousIndex;
    BOOL scrollLeft;
    
    int firstDay;
    NSArray *daysInWeeks;
    CGSize cellSize;
    
    int selectedRow;
    int headerSize;
}

@end

@implementation SACalendar

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame month:0 year:0 scrollDirection:ScrollDirectionHorizontal pagingEnabled:YES];
}

- (id)initWithFrame:(CGRect)frame month:(int)m year:(int)y
{
    return [self initWithFrame:frame month:m year:y scrollDirection:ScrollDirectionHorizontal pagingEnabled:YES];
}

-(id)initWithFrame:(CGRect)frame
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging
{
    return [self initWithFrame:frame month:0 year:0 scrollDirection:direction pagingEnabled:paging];
}

-(id)initWithFrame:(CGRect)frame
             month:(int)m year:(int)y
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging
{
    self = [super initWithFrame:frame];
    if (self) {
        
        controllers = [NSMutableDictionary dictionary];
        calendars = [NSMutableDictionary dictionary];
        monthLabels = [NSMutableDictionary dictionary];
        
        daysInWeeks = [[NSArray alloc]initWithObjects:@"Sunday",@"Monday",@"Tuesday",
                       @"Wednesday",@"Thursday",@"Friday",@"Saturday", nil];
        
        state = LOADSTATESTART;
        scroll_state = SCROLLSTATE_120;
        selectedRow = -1;
        
        current_date = [[DateUtil getCurrentDate]intValue];
        current_month = [[DateUtil getCurrentMonth]intValue];
        current_year = [[DateUtil getCurrentYear]intValue];
        
        if (m == 0 && y == 0) {
            month = current_month;
            year = current_year;
        }
        else{
            month = m;
            year = y;
        }
        
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        scrollView = [[DMLazyScrollView alloc] initWithFrameAndDirection:rect direction:direction circularScroll:YES paging:paging];
        
        self.backgroundColor = viewBackgroundColor;
        
        [self addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    scrollView.dataSource = ^(NSUInteger index) {
        return [weakSelf controllerAtIndex:index];
    };
    scrollView.numberOfPages = 3;
    [self addSubview:scrollView];
    
    return self;
    
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (nil != _delegate && [_delegate respondsToSelector:@selector(SACalendar:didDisplayCalendarForMonth:year:)]) {
        [_delegate SACalendar:self didDisplayCalendarForMonth:month year:year];
    }
}


#pragma SCROLL VIEW DELEGATE

- (UIViewController *) controllerAtIndex:(NSInteger) index {
    /*
     * Handle right scroll
     */
    if (index == previousIndex && state == LOADSTATEPREVIOUS) {
        if (++month > MAX_MONTH) {
            month = MIN_MONTH;
            year ++;
        }
        scrollLeft = NO;
        selectedRow = DESELECT_ROW;
    }
    
    /*
     * Handle left scroll
     */
    else if(state == LOADSTATEPREVIOUS){
        if (--month < MIN_MONTH) {
            month = MAX_MONTH;
            year--;
        }
        scrollLeft = YES;
        selectedRow = DESELECT_ROW;
    }
    
    previousIndex = (int)index;
    
    UIViewController *contr = [[UIViewController alloc] init];
    contr.view.backgroundColor = scrollViewBackgroundColor;
    
    if (state  <= LOADSTATEPREVIOUS ) {
        state = LOADSTATENEXT;
    }
    else if(state == LOADSTATENEXT){
        prev_month = month - 1;
        prev_year = year;
        if (prev_month < MIN_MONTH) {
            prev_month = MAX_MONTH;
            prev_year--;
        }
        state = LOADSTATECURRENT;
    }
    else{
        next_month = month + 1;
        next_year = year;
        if (next_month > MAX_MONTH) {
            next_month = MIN_MONTH;
            next_year++;
        }
        
        if (scrollLeft) {
            if (--scroll_state < SCROLLSTATE_120) {
                scroll_state = SCROLLSTATE_012;
            }
        }
        else{
            scroll_state++;
            if (scroll_state > SCROLLSTATE_012) {
                scroll_state = SCROLLSTATE_120;
            }
        }
        state = LOADSTATEPREVIOUS;
        
        if (nil != _delegate && [_delegate respondsToSelector:@selector(SACalendar:didDisplayCalendarForMonth:year:)]) {
            [_delegate SACalendar:self didDisplayCalendarForMonth:month year:year];
        }
    }
    
    /*
     * if already exists, reload the calendar with new values
     */
    UICollectionView *calendar = [calendars objectForKey:[NSString stringWithFormat:@"%li",(long)index]];
    [calendar reloadData];
    
    /*
     * create new view controller and add it to a dictionary for caching
     */
    if (![controllers objectForKey:[NSString stringWithFormat:@"%li",(long)index]]) {
        UIViewController *contr = [[UIViewController alloc] init];
        contr.view.backgroundColor = scrollViewBackgroundColor;
        
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = self.frame.size;
        
        headerSize = self.frame.size.height / calendarToHeaderRatio;
        
        CGRect rect = CGRectMake(0, headerSize, self.frame.size.width, self.frame.size.height - headerSize);
        UICollectionView *calendar = [[UICollectionView alloc]initWithFrame:rect collectionViewLayout:flowLayout];
        calendar.dataSource = self;
        calendar.delegate = self;
        calendar.scrollEnabled = NO;
        [calendar registerClass:[SACalendarCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [calendar setBackgroundColor:calendarBackgroundColor];
        calendar.tag = index;
        
        NSString *string = @"STRING";
        CGSize size = [string sizeWithAttributes:
                       @{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        float pointsPerPixel = 12.0 / size.height;
        float desiredFontSize = headerSize * pointsPerPixel;
        
        UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, headerSize)];
        monthLabel.font = [UIFont systemFontOfSize: desiredFontSize * headerFontRatio];
        monthLabel.textAlignment = NSTextAlignmentCenter;
        monthLabel.text = [NSString stringWithFormat:@"%@ %04i",[DateUtil getMonthString:month],year];
        monthLabel.textColor = headerTextColor;
        
        [contr.view addSubview:monthLabel];
        [contr.view addSubview:calendar];
        
        [calendars setObject:calendar forKey:[NSString stringWithFormat:@"%li",(long)index]];
        [controllers setObject:contr forKey:[NSString stringWithFormat:@"%li",(long)index]];
        [monthLabels setObject:monthLabel forKey:[NSString stringWithFormat:@"%li",(long)index]];
        
        return contr;
    }
    else{
        return [controllers objectForKey:[NSString stringWithFormat:@"%li",(long)index]];
    }
    
}

/**
 *  Get the month corresponding to the collection view
 *
 *  @param tag of the collection view
 *
 *  @return month that the collection view should load
 */
-(int)monthToLoad:(int)tag
{
    if (scroll_state == SCROLLSTATE_120) {
        if (tag == 0) return next_month;
        else if(tag == 1) return prev_month;
        else return month;
    }
    else if(scroll_state == SCROLLSTATE_201){
        if (tag == 0) return month;
        else if(tag == 1) return next_month;
        else return prev_month;
    }
    else{
        if (tag == 0) return prev_month;
        else if(tag == 1) return month;
        else return next_month;
    }
}

/**
 *  Get the year corresponding to the collection view
 *
 *  @param tag of the collection view
 *
 *  @return year that the collection view should load
 */
-(int)yearToLoad:(int)tag
{
    if (scroll_state == SCROLLSTATE_120) {
        if (tag == 0) return next_year;
        else if(tag == 1) return prev_year;
        else return year;
    }
    else if(scroll_state == SCROLLSTATE_201){
        if (tag == 0) return year;
        else if(tag == 1) return next_year;
        else return prev_year;
    }
    else{
        if (tag == 0) return prev_year;
        else if(tag == 1) return year;
        else return next_year;
    }
}

#pragma COLLECTION VIEW DELEGATE

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int monthToLoad = [self monthToLoad:(int)collectionView.tag];
    int yearToLoad = [self yearToLoad:(int)collectionView.tag];
    
    firstDay = (int)[daysInWeeks indexOfObject:[DateUtil getDayOfDate:1 month:monthToLoad year:yearToLoad]];
    
    UILabel *monthLabel = [monthLabels objectForKey:[NSString stringWithFormat:@"%li",(long)collectionView.tag]];
    monthLabel.text = [NSString stringWithFormat:@"%@ %04i",[DateUtil getMonthString:monthToLoad],yearToLoad];
    
    return MAX_CELL;
}

/**
 *  Controls what gets displayed in each cell
 *  Edit this function for customized calendar logic
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SACalendarCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    int monthToLoad = [self monthToLoad:(int)collectionView.tag];
    int yearToLoad = [self yearToLoad:(int)collectionView.tag];
    
    // number of days in the month we are loading
    int daysInMonth = (int)[DateUtil getDaysInMonth:monthToLoad year:yearToLoad];
    
    // if cell is out of the month, do not show
    if (indexPath.row < firstDay || indexPath.row >= firstDay + daysInMonth) {
        cell.topLineView.hidden = cell.dateLabel.hidden = cell.circleView.hidden = cell.selectedView.hidden = YES;
    }
    else{
        cell.topLineView.hidden = cell.dateLabel.hidden = NO;
        cell.circleView.hidden = YES;
        
        // get appropriate font size
        NSString *string = @"STRING";
        
        CGSize size = [string sizeWithAttributes:
                       @{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        float pointsPerPixel = 12.0 / size.height;
        float desiredFontSize = cellSize.height * pointsPerPixel;
        
        UIFont *font = cellFont;
        UIFont *boldFont = cellBoldFont;
        
        // if the cell is the current date, display the red circle
        BOOL isToday = NO;
        if (indexPath.row - firstDay + 1 == current_date
            && monthToLoad == current_month
            && yearToLoad == current_year)
        {
            cell.circleView.hidden = NO;
            
            cell.dateLabel.textColor = currentDateTextColor;
            
            cell.dateLabel.font = boldFont;
            
            isToday = YES;
        }
        else{
            cell.dateLabel.font = font;
            cell.dateLabel.textColor = dateTextColor;
        }
        
        // if the cell is selected, display the black circle
        if (indexPath.row == selectedRow) {
            cell.selectedView.hidden = NO;
            cell.dateLabel.textColor = selectedDateTextColor;
            cell.dateLabel.font = boldFont;
        }
        else{
            cell.selectedView.hidden = YES;
            if (!isToday) {
                cell.dateLabel.font = font;
                cell.dateLabel.textColor = dateTextColor;
            }
        }
        
        // set the appropriate date for the cell
        cell.dateLabel.text = [NSString stringWithFormat:@"%i",(int)indexPath.row - firstDay + 1];
    }
    
    return cell;
}

/*
 * Scale the collection view size to fit the frame
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int width = self.frame.size.width;
    int height = self.frame.size.height - headerSize;
    cellSize = CGSizeMake(width/DAYS_IN_WEEKS, height / MAX_WEEK);
    return CGSizeMake(width/DAYS_IN_WEEKS, height / MAX_WEEK);
}

/*
 * Set all spaces between the cells to zero
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

/*
 * If the width of the calendar cannot be divided by 7, add offset to each side to fit the calendar in
 */
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    int width = self.frame.size.width;
    int offset = (width % DAYS_IN_WEEKS) / 4;
    // top, left, bottom, right
    return UIEdgeInsetsMake(0,offset,0,offset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    int daysInMonth = (int)[DateUtil getDaysInMonth:[self monthToLoad:(int)collectionView.tag] year:[self yearToLoad:(int)collectionView.tag]];
    if (!(indexPath.row < firstDay || indexPath.row >= firstDay + daysInMonth)) {
        
        int dateSelected = (int)indexPath.row - firstDay + 1;
        
        if (nil != _delegate && [_delegate respondsToSelector:@selector(SACalendar:didSelectDate:month:year:)]) {
            [_delegate SACalendar:self didSelectDate:dateSelected month:month year:year];
        }
        
        selectedRow = (int)indexPath.row;
    }
    else{
        selectedRow = DESELECT_ROW;
    }
    [collectionView reloadData];
}

/**
 *  Clean up
 */
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"delegate"];
}


@end
