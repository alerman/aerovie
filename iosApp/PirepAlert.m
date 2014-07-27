//
//  PirepAlert.m
//  AerovieReports
//
//  Created by Bryan Heitman on 7/19/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import "PirepAlert.h"

@interface PirepAlert ()

@end

@implementation PirepAlert

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
    
    myCommon = [[Common alloc] init];
    singletonObject = [mySingleton sharedInstance];
    [singletonObject add_gray:self.parentViewController.view];
    [self didRotateFromInterfaceOrientation:self];
    
    
    
    [self reset_view];
    
}

-(void) reset_view {
    if(singletonObject->is_pirep_monitoring) {
        _label_time.hidden = false;
        float time_remaining = (singletonObject->monitor_expire_time - [[NSDate date] timeIntervalSince1970]) / 60;
        if(time_remaining > 60)
            _label_time.text = [NSString stringWithFormat:@"%.1f hours remaining",time_remaining/60];
        else
            _label_time.text = [NSString stringWithFormat:@"%.0f minutes remaining",time_remaining];
        
        
        _button_start.enabled = false;
        _segment_altitude.enabled = false;
        _segment_miles.enabled = false;
        _segment_hour.enabled = false;
        
        _button_stop.hidden = false;
    }else{
        _label_time.hidden = true;
        
        _button_stop.hidden = true;
        
        _button_start.enabled = true;
        _segment_altitude.enabled = true;
        _segment_miles.enabled = true;
        _segment_hour.enabled = true;
        
    }

}
- (IBAction)close:(id)sender {
    [singletonObject remove_gray];
    
    [self.parentViewController  viewDidAppear:true];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView == alert_disclaimer) {
        if(buttonIndex == 0) {
            return;
        }else{
            [mySession setObject:@"1" forKey:@"disclaimer_alert"];
            [myCommon writeSession];
            [self start:nil];
        }
    }
}

- (IBAction)start:(id)sender {
    
    if(![mySession objectForKey:@"disclaimer_alert"]) {
        alert_disclaimer = [[UIAlertView alloc]
                        initWithTitle:@"I understand PIREP alerts are transmitted on a best efforts basis and is dependent upon a network data connection. No guarantee of accurate or complete information is assumed. For latest information I agree to contact flight service."
                        message:nil
                        delegate:self
                        cancelButtonTitle:@"CANCEL"
                        otherButtonTitles:@"I AGREE", nil];
        [alert_disclaimer show];
        return;
    }
    
    
    float miles = [[_segment_miles titleForSegmentAtIndex:_segment_miles.selectedSegmentIndex] floatValue];
    float hours = [[_segment_hour titleForSegmentAtIndex:_segment_hour.selectedSegmentIndex] floatValue];
    float max_alt = [[_segment_altitude titleForSegmentAtIndex:_segment_altitude.selectedSegmentIndex] floatValue];
    
    
    if([[_segment_altitude titleForSegmentAtIndex:_segment_altitude.selectedSegmentIndex] isEqualToString:@"Unrestricted"])
        max_alt = 0;
    if([[_segment_altitude titleForSegmentAtIndex:_segment_altitude.selectedSegmentIndex] isEqualToString:@"Any"])
        max_alt = 0;
    
    
    [singletonObject start_pirep_monitor:miles hours:hours max_alt:max_alt];
    
    [self close:nil];
    
}


- (IBAction)stop:(id)sender {
    singletonObject->is_pirep_monitoring = false;
    [singletonObject->monitor_timer invalidate];
    [self reset_view];
}

//did rotate...
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    //    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        singletonObject->portrait = true;
        //SET PORTRAIT STUFF HERE
        
    }else{
        singletonObject->portrait = false;
    }
    [self set_orientation];
}

-(void) set_orientation {
    if(singletonObject->portrait == true) {
        set_portrait = true;
        //        [myCommon change_frame:_button_facebook x:-123 y:0];
        
    }else if(set_portrait == true) {
        set_portrait = false;
        //        [myCommon change_frame:_button_facebook x:123 y:0];
    }
    [singletonObject adjust_gray];
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
