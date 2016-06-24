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

@interface ViewController () {

    ACCalendarViewController *_vc;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
}


- (IBAction)_calendarAction:(id)sender {
    
    if (_vc == nil) {
        _vc = [[ACCalendarViewController alloc] init];
        _vc.block = ^(ACCalendarModel *model){
            NSLog(@"%@",model.dateString);
        };
    }
    
    [self.navigationController pushViewController:_vc animated:YES];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

