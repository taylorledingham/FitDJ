//
//  AddWorkoutDataViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "AddWorkoutDataViewController.h"
#import "TLCoreDataStack.h"
#import "PlayWorkoutViewController.h"

@interface AddWorkoutDataViewController ()

@end

@implementation AddWorkoutDataViewController {
    
    Workout *workout;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.workoutDurationTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"startWorkout"]){
        
        PlayWorkoutViewController *playVC = (PlayWorkoutViewController *)segue.destinationViewController;
        playVC.view.layer.opacity = 0.5;
        playVC.startWorkoutButton.layer.opacity = 1.0;
        playVC.workout = workout;
        [playVC.navigationController setNavigationBarHidden:YES animated:YES];
        
        
    }
    
}


#pragma mark - text field delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // do whatever you have to do
    [textField resignFirstResponder];
    
    
    return YES;
}

- (IBAction)donePressed:(id)sender {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:coreDataStack.managedObjectContext];
    workout.workoutName = self.workoutNameTextField.text;
    NSNumber *duration = [NSNumber numberWithDouble:[self.workoutDurationTextField.text doubleValue]];
    workout.workoutDuration = duration;
    workout.workoutType = @"time";
    workout.numberOfRounds = 0;
    [coreDataStack saveContext];

}

- (IBAction)speedSliderChanged:(id)sender {
    self.speedLabel.text = [NSString stringWithFormat:@"Speed (MPH): %0.1f", self.speedSlider.value];
    
    
}

- (IBAction)inclineSliderChanged:(id)sender {
    self.inclineLabel.text = [NSString stringWithFormat:@"Incline %%: %0.1f", self.inclineSlider.value];

}
@end
