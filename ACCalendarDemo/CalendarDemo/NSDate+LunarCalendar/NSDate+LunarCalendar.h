

//  GitHub: https://github.com/GardenerYun
//
//  Email: gardeneryun@foxmail.com
//
//  简书博客地址: http://www.jianshu.com/users/8489e70e237d/latest_articles
//
//  如有问题或建议请联系我，我会马上解决问题~ (ง •̀_•́)ง**

#import <Foundation/Foundation.h>

/**
 *  中国农历
 */

@interface NSDate (LunarCalendar)

/**
 * 例如 : 2016丙申年四月初一
 */

- (NSInteger)lunarShortYear;  // 农历年份,数字表示  2016

- (NSString *)lunarLongYear;  // 农历年份,干支表示  丙申年

- (NSInteger)lunarShortMonth; // 农历月份,数字表示  4

- (NSString *)lunarLongMonth; // 农历月份,汉字表示  四月

- (NSInteger)lunarShortDay;   // 农历日期,数字表示  1

- (NSString *)lunarLongDay;   // 农历日期,汉字表示  初一

- (NSString *)lunarSolarTerms;// 农历节气 (立春 雨水 惊蛰 春分...)

/** 传入阳历的年月日返回当天的农历节气 */
+ (NSString *)getLunarSolarTermsWithYear:(int)iYear Month:(int)iMonth Day:(int)iDay;

@end
