//
//  Testing.m
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 2/7/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import "Testing.h"

@interface Testing ()

@end

@implementation Testing

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    self.view.frame = self.view.bounds;
    CGRect b = self.view.frame;
    float x = b.size.width;
    float y = b.size.height;
    
    CGSize screen = self.view.bounds.size;
    float m = screen.width;
    float  n = screen.height;
    
    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
        //SET PORTRAIT STUFF HERE
    }else{
        //RESET TO NON PORTRAIT
        

    }
    
    
    
    
    
    
    
}

- (IBAction)grow:(id)sender {
   // _my_view.frame = CGRectMake(10, 10, 700, 500);
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    view.frame = CGRectMake(300, 700, 150, 50);
    [self.view addSubview:view];
    
    /*
     NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f constant:0.0f];
     [view.superview addConstraint:constraint];
*/
//    [self add_center_constraint:view];
}



@end
