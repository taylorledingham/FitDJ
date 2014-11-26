//
//  AddTimeWorkoutTableViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-22.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import <ASValueTrackingSlider/ASValueTrackingSlider.h>
#import <ASValueTrackingSlider/ASValuePopUpView.h>

@interface AddTimeWorkoutTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *workoutNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *speedTextField;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *inclineSlider;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end
