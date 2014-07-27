//
//  Settings.m
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 1/27/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import "Settings.h"

@interface Settings ()

@end

@implementation Settings

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

    
    _name.text = [mySession objectForKey:@"name"];
    NSString *is_pilot = [mySession objectForKey:@"pilot"];
    if([is_pilot isEqualToString:@"yes"])
        [_switch_pilot setOn:true];
    else
        [_switch_pilot setOn:false];
    
    
    
    NSString *high_altitude = [mySession objectForKey:@"high_altitude"];
    if([high_altitude isEqualToString:@"yes"])
        [_switch_high setOn:true];
    else
        [_switch_high setOn:false];
    
    _label_version.text = [NSString stringWithFormat:@"v. %.2f",MASTER_VERSION];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)save:(id)sender {
    [self.view endEditing:YES];

    [mySession setObject:_name.text forKey:@"name"];
    
    if([_switch_pilot isOn]) {
        [mySession setObject:@"yes" forKey:@"pilot"];
    }else{
        [mySession setObject:@"no" forKey:@"pilot"];
    }
    
    if([_switch_high isOn]) {
        [mySession setObject:@"yes" forKey:@"high_altitude"];
    }else{
        [mySession setObject:@"no" forKey:@"high_altitude"];
    }

    [myCommon writeSession];
    
    NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    [requestData setObject:@"save_name" forKey:@"request" ];
    [requestData setObject:_name.text forKey:@"name" ];
    [requestData setObject:[mySession objectForKey:@"pilot"] forKey:@"pilot" ];
    [requestData setObject:@"check_auth" forKey:@"connection_description" ];
    [requestData setObject:[mySession objectForKey:@"session_id"] forKey:@"session_id" ];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    
    [myCommon apiRequest:requestData];

    
    
    
    UIViewController *p = self.parentViewController;
    [p viewDidAppear:true];
    
    [singletonObject remove_gray];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    
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


- (IBAction)button_logout:(id)sender {
    
    NSLog(@"BUTTON LOGOUT");
    Page *blah = (Page *)self.parentViewController;
    [blah button_logout:nil];
}




- (void)myNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
