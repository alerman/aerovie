//
//  RangeSlider.m
//  AerovieReports
//
//  Created by Bryan Heitman on 7/17/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import "RangeSlider.h"

@interface RangeSlider ()

@end

@implementation RangeSlider

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(UIView *) setup_range:(CGRect) rect min:(float) min max:(float) max value1:(float) value1 value2:(float) value2 desc:(NSString *) desc{
    minimum_value = min;
    maximum_value = max;
    current_value_1 = value1;
    current_value_2 = value2;
    description = desc;
    
    
    my_view = [[UIView alloc] init];
    my_view.frame = rect;
    my_view.backgroundColor = [UIColor clearColor];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithRed:1/255.0 green:112/255.0 blue:184/255.0 alpha:1];
    line.frame = CGRectMake(10, 35, my_view.frame.size.width-20, 2);
    [my_view addSubview:line];
    line.clipsToBounds = true;
    line.layer.cornerRadius = 2;
    
    
    knob1 = [[UIImageView alloc] init];
    knob1.image = [UIImage imageNamed:@"slider_knob.png"];
    knob1.frame = CGRectMake(5, 35-20, 42, 41);

    knob2 = [[UIImageView alloc] init];
    knob2.image = [UIImage imageNamed:@"slider_knob.png"];
    knob2.frame = CGRectMake(my_view.frame.size.width-20-15, 35-20, 42, 41);
    

    [my_view addSubview:knob1];
    [my_view addSubview:knob2];
    
    knob1.userInteractionEnabled = true;
    knob2.userInteractionEnabled = true;

    knob1.restorationIdentifier = @"1";
    knob2.restorationIdentifier = @"2";
    
    master_min = knob1.center.x;
    master_max = knob2.center.x;
    
    
    label_min = [[UILabel alloc] init];
    label_max = [[UILabel alloc] init];
    label_min.frame = CGRectMake(10, 0, 100, 20);
    label_max.frame = CGRectMake(my_view.frame.size.width-20-15-5-35, 0, 100, 20);

    [my_view addSubview:label_min];
    [my_view addSubview:label_max];
    label_min.font = [UIFont systemFontOfSize:12];
    label_max.font = [UIFont systemFontOfSize:12];
    label_max.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
    label_min.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [knob1 addGestureRecognizer:panRecognizer];
    
    UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [knob2 addGestureRecognizer:panRecognizer2];

    [self setup_label];
    
    return my_view;
}

- (IBAction)pan:(UIPanGestureRecognizer *)gesture {
    static CGPoint originalCenter;
    static float min_x;
    static float max_x;
    static BOOL first;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"POS1 %@",gesture.view.restorationIdentifier);
        
        originalCenter = gesture.view.center;
        min_x = knob1.center.x;
        max_x = knob2.center.x;
        
        if([gesture.view.restorationIdentifier isEqualToString:@"2"])
            first = false;
        else
            first = true;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translate = [gesture translationInView:gesture.view.superview];
        
        float this_x = originalCenter.x  + translate.x;
        
        if(first) {
            if(this_x > max_x)
                this_x = max_x;
            if(this_x < master_min)
                this_x = master_min;
        }else{
            if(this_x > master_max)
                this_x = master_max;
            if(this_x < min_x)
                this_x = min_x;
        }
        gesture.view.center = CGPointMake(this_x, originalCenter.y);
        
        [self setup_label];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateFailed ||
             gesture.state == UIGestureRecognizerStateCancelled)
    {
        NSLog(@"POS3");

        [self resumeLayer:gesture.view.layer];
    }
    
}

-(void) setup_label {
    float diff = master_max - master_min;
    float per_pixel = (maximum_value - minimum_value)/diff;
    
    float x_min = knob1.center.x - master_min;
    float x_max = knob2.center.x - master_min;

    //NSLog(@"x_min: %f x_max: %f",x_min,x_max);
    NSString *extra1_zero = @"";
    NSString *extra2_zero = @"";
    
    float min_value = lroundf(x_min * per_pixel);
    float max_value = lroundf(x_max * per_pixel);

    if(min_value < 10)
        extra1_zero = @"00";
    else if(min_value < 100)
        extra1_zero = @"0";

    if(max_value < 10)
        extra2_zero = @"00";
    else if(max_value < 100)
        extra2_zero = @"0";
    
    //NSLog(@"value: =%.0f= extra1_zero: =%@=",x_min * per_pixel,extra1_zero);
    
    label_min.text = [NSString stringWithFormat:@"FL%@%.0f",extra1_zero,x_min * per_pixel];
    label_max.text = [NSString stringWithFormat:@"FL%@%.0f",extra2_zero,x_max * per_pixel];

    
    if(min_value == minimum_value)
        label_min.text = [NSString stringWithFormat:@"%@ BASES",description];
    if(max_value == maximum_value)
        label_max.text = [NSString stringWithFormat:@"%@ TOPS",description];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
