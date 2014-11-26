//
//  AddDistanceWorkoutTableViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-25.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import <ASValueTrackingSlider/ASValueTrackingSlider.h>
#import <ASValueTrackingSlider/ASValuePopUpView.h>

@interface AddDistanceWorkoutTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *workoutNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *distanceUnitsSegmentControl;

@property (weak, nonatomic) IBOutlet UITableViewCell *inclineCell;
@property (weak, nonatomic) IBOutlet UILabel *inclineLabel;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *inclineSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceInputLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UITextField *speedTextField;


- (IBAction)distanceUnitsChanged:(id)sender;


@end
