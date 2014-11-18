//
//  PlayWorkoutViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "PlayWorkoutViewController.h"

@interface PlayWorkoutViewController ()

@end

@implementation PlayWorkoutViewController {
    NSTimeInterval workoutDuration;
    NSDateFormatter *dateFormatter;
    UIGestureRecognizer *tapGesture;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    
    NSNumber *time = [NSNumber numberWithDouble:([self.workout.workoutDuration doubleValue] - 60)];
    workoutDuration = [time doubleValue];
    NSDate *online = [NSDate date];
    online = [NSDate dateWithTimeIntervalSince1970:workoutDuration];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    self.durationLabel.text = [NSString stringWithFormat: @"Time: %@", [dateFormatter stringFromDate:online]];
    
    
}

-(void)loadMusicPicker {
    
    
    
}

-(void)setWorkoutDetails {
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startWorkoutPressed:(id)sender {
    
    self.view.alpha = 1.0;
    self.startWorkoutButton.hidden = YES;
}

- (IBAction)previousSelected:(id)sender {
}

- (IBAction)playPauseSelected:(id)sender {
}
- (IBAction)nextSelected:(id)sender {
}
@end
