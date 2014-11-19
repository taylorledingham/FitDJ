//
//  PlayWorkoutViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "PlayWorkoutViewController.h"
#import "MusicPickerViewController.h"

@interface PlayWorkoutViewController ()

@end

@implementation PlayWorkoutViewController {
    NSTimeInterval workoutDuration;
    NSDateFormatter *dateFormatter;
    UIGestureRecognizer *tapGesture;
    BOOL musicPicked;
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
    //MusicPickerViewController *musicPickerVC = [[MusicPickerViewController alloc]init];
    //[self presentViewController:musicPickerVC animated:NO completion:nil];

    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
   
    
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
    CABasicAnimation *animationWidth = [CABasicAnimation animation];
    animationWidth.keyPath = @"size.width";
    animationWidth.fromValue = @(self.startWorkoutButton.frame.size.width);
    animationWidth.toValue = @0;
    CABasicAnimation *animationHeight = [CABasicAnimation animation];
    animationHeight.keyPath = @"size.height";
    animationHeight.fromValue = @(self.startWorkoutButton.frame.size.height);
    animationHeight.toValue = @0;
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.animations = @[ animationWidth, animationHeight ];
    group.duration = 1.2;
    group.beginTime = 0.5;
    
    [self.startWorkoutButton.layer addAnimation:group forKey:@"shrink"];

    
    
    
    self.startWorkoutButton.hidden = YES;
}

- (IBAction)previousSelected:(id)sender {
}

- (IBAction)playPauseSelected:(id)sender {
}
- (IBAction)nextSelected:(id)sender {
}
@end
