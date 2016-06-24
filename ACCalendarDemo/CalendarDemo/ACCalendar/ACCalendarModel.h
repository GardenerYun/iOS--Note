//
//  ACCalendarModel.h
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/24.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+DateTools.h"

typedef NS_ENUM(NSInteger, ACCalendarCellType) {
    ACCalendarCellTypeNone,    //不显示
    ACCalendarCellTypeDefault, //默认正常的样式
    ACCalendarCellTypeGray,    //置灰不可选择的样式
    ACCalendarCellTypeWeek,    //周末
    ACCalendarCellTypeSelect   //被点击的日期
};

@interface ACCalendarModel : NSObject

@property (nonatomic, assign) ACCalendarCellType type;

@property (nonatomic, assign) NSInteger year;   //年
@property (nonatomic, assign) NSInteger month;  //月
@property (nonatomic, assign) NSInteger day;    //天

@property (nonatomic, copy  ) NSString  *lunarDay;// 农历 日
@property (nonatomic, copy  ) NSString  *holiday;   // 节日
@property (nonatomic, copy  ) NSString  *weekString;// 星期几
@property (nonatomic, strong) NSDate    *date;      // 日期NSDate对象
@property (nonatomic, copy  ) NSString  *lunarSolarTerms;

@property (nonatomic, copy, readonly) NSString *lunarMonth; // 农历 月
@property (nonatomic, copy, readonly) NSString *dateString;   // 日期string格式, 2016-05-24

+ (instancetype)initWithDate:(NSDate *)date;

@end
