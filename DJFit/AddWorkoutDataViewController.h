//
//  AddWorkoutDataViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLCoreDataStack.h"
#import "Workout.h"


@interface AddWorkoutDataViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *workoutDurationTextField;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UILabel *inclineLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UISlider *inclineSlider;
@property (weak, nonatomic) IBOutlet UITextField *workoutNameTextField;

- (IBAction)donePressed:(id)sender;
- (IBAction)speedSliderChanged:(id)sender;
- (IBAction)inclineSliderChanged:(id)sender;
@end
