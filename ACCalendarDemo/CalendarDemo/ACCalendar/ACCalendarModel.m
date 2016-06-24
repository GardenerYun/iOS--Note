//
//  ACCalendarModel.m
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/24.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import "ACCalendarModel.h"
#import "NSDate+DateTools.h"
#import "NSDate+LunarCalendar.h"
@implementation ACCalendarModel

+ (instancetype)initWithDate:(NSDate *)date {

    ACCalendarModel *model = [[ACCalendarModel alloc] init];
    
    model.date = date;
    model.year = date.year;
    model.month = date.month;
    model.day = date.day;
    model.lunarDay = date.lunarLongDay;
    model.lunarSolarTerms = date.lunarSolarTerms;
    
    [model markSpecialDays];

    return model;
}

- (NSString *)dateString {
    return [self.date formattedDateWithFormat:@"yyyy-MM-dd"];
}

- (NSString *)lunarMonth {
    return self.date.lunarLongMonth;
}

- (void)markSpecialDays {

    if (self.date.lunarShortMonth == 1 && self.date.lunarShortDay == 1) {
        self.holiday = @"春节";   // 正月初一
    } else if (self.date.lunarShortMonth == 1 && self.date.lunarShortDay == 15) {
        self.holiday = @"元宵";   // 正月十五
    } else if (self.date.lunarShortMonth == 2 && self.date.lunarShortDay == 2) {
        self.holiday = @"龙抬头"; // 二月初二
    } else if (self.date.lunarShortMonth == 5 && self.date.lunarShortDay == 5) {
        self.holiday = @"端午";   // 五月初五
    } else if (self.date.lunarShortMonth == 7 && self.date.lunarShortDay == 7) {
        self.holiday = @"七夕";   // 七月初七
    } else if (self.date.lunarShortMonth == 8 && self.date.lunarShortDay == 15) {
        self.holiday = @"中秋";   // 八月十五
    } else if (self.date.lunarShortMonth == 9 && self.date.lunarShortDay == 9) {
        self.holiday = @"重阳";   // 九月初九
    } else if (self.date.lunarShortMonth == 12 && self.date.lunarShortDay == 30) {
        self.holiday = @"除夕";   // 腊月三十
    }
    
}



@end
