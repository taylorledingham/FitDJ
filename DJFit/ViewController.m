//
//  ViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "ViewController.h"
#import "ProfileDetailsViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    
    ProfileDetailsViewController *profileVC = [[ProfileDetailsViewController alloc]init];
   // profileVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.view.alpha = 0.5;
    [self presentViewController:profileVC animated:YES completion:nil];

    
}

@end
