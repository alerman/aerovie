//
//  Settings.h
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 1/27/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Page.h"

@class Page;


@interface Settings : UIViewController {
    Common *myCommon;
    mySingleton *singletonObject;

    BOOL set_portrait;
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UISwitch *switch_pilot;
@property (weak, nonatomic) IBOutlet UISwitch *switch_high;


@property (weak, nonatomic) IBOutlet UILabel *label_version;


@end
