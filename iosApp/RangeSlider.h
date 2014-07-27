//
//  RangeSlider.h
//  AerovieReports
//
//  Created by Bryan Heitman on 7/17/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RangeSlider : UIViewController {
    @public
    
    UIView *my_view;
    
    float minimum_value;
    float maximum_value;
    float current_value_1;
    float current_value_2;
    
    UIImageView *knob1;
    UIImageView *knob2;
    
    float master_min;
    float master_max;
    
    UILabel *label_min;
    UILabel *label_max;
    
    NSString *description;
}

-(UIView *) setup_range:(CGRect) rect min:(float) min max:(float) max value1:(float) value1 value2:(float) value2 desc:(NSString *) desc;

@end
