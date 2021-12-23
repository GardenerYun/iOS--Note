//
//  ViewController.m
//  CalendarDemo
//
//  Created by Zhangziyun on 16/5/19.
//  Copyright © 2016年 章子云. All rights reserved.
//

#import "ViewController.h"
#import "NSDate+DateTools.h"
#import "ACCalendarViewController.h"
#import "NSDate+LunarCalendar.h"
#import "ACCalendarModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.title = @"日历";
}


- (IBAction)_calendarAction:(id)sender {
    
    ACCalendarViewController *vc = [[ACCalendarViewController alloc] init];
    vc.block = ^(ACCalendarModel *model){
        NSLog(@"%@",model.dateString);
    };

    [self.navigationController pushViewController:vc animated:YES];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

