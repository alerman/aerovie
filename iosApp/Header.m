//
//  Header.m
//  Aerovie
//
//  Created by Bryan Heitman on 10/6/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import "Header.h"

@interface Header ()

@end

@implementation Header

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
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(record_tap:)];
    [_image_record addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stop_tap:)];
    [_image_stop addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pause_tap:)];
    [_image_pause addGestureRecognizer:tap3];
}
- (void) viewDidAppear:(BOOL)animated {
   // singletonObject->last_header = self;
    
    [self setup_gps_header];
}

-(IBAction)stop_tap:(id)sender {
    [singletonObject gps_stop];
}
-(IBAction)pause_tap:(id)sender {
    [singletonObject gps_pause];
}
- (void) setup_gps_header {
    if(singletonObject->active_flight_id > 0) {
        //active
        _image_record.hidden = true;
        _image_pause.hidden = false;
        _image_stop.hidden = false;
        _label_time.hidden = false;
        _label_gps_debug.hidden = false;
    }else{
        //inactive
        _image_record.hidden = false;
        _image_pause.hidden = true;
        _image_stop.hidden = true;
        _label_time.hidden = true;
        _label_gps_debug.hidden = true;
    }
}


-(IBAction)record_tap:(id)sender {
    NSLog(@"record tap");
//    Dashboard *my_parent = (Dashboard *)self.parentViewController;
//    my_parent.container_record.hidden = false;
    /*UIView *incoming_phone_view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
     incoming_phone_view.frame = CGRectMake( 36, 150, 264, 133); // set exact
     incoming_phone_view.backgroundColor = [UIColor redColor];
     incoming_phone_view.alpha = 1;
     */
    /*
     RecordView *child = [my_parent.storyboard instantiateViewControllerWithIdentifier:@"record_view"];
     child.view.frame = CGRectMake( 100, 100, 500, 500); // set exact
     
     [my_parent addChildViewController:child];
     [my_parent.view addSubview:child.view];
     [child didMoveToParentViewController:my_parent];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
