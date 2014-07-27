//
//  PirepAlert.h
//  AerovieReports
//
//  Created by Bryan Heitman on 7/19/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface PirepAlert : UIViewController {
    Common *myCommon;
    mySingleton *singletonObject;
    
    BOOL set_portrait;
    
    UIAlertView *alert_disclaimer;

}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_altitude;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_miles;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_hour;

@property (weak, nonatomic) IBOutlet UILabel *label_time;


@property (weak, nonatomic) IBOutlet UIButton *button_stop;
@property (weak, nonatomic) IBOutlet UIButton *button_start;

@end
