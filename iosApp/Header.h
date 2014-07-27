//
//  Header.h
//  Aerovie
//
//  Created by Bryan Heitman on 10/6/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class Common;
@class mySingleton;
//@class Dashboard;

@interface Header : UIViewController {
    Common *myCommon;
    mySingleton *singletonObject;
    
}

@property (weak, nonatomic) IBOutlet UIButton *image_record;
@property (weak, nonatomic) IBOutlet UIImageView *image_gps;


@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UIButton *image_pause;

@property (weak, nonatomic) IBOutlet UIButton *image_stop;

@property (weak, nonatomic) IBOutlet UILabel *label_gps_debug;

- (void) setup_gps_header;
@end
