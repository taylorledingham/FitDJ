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
#import <ASValueTrackingSlider/ASValueTrackingSlider.h>
#import <ASValueTrackingSlider/ASValuePopUpView.h>

@interface AddWorkoutDataViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *numberOfRoundsSlider;
@property (weak, nonatomic) IBOutlet UILabel *inclineLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UITextField *workoutNameTextField;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *speedTextField;
@property (strong, nonatomic) IBOutletCollection(ASValueTrackingSlider) NSArray *inclineSliders;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *cellTimeLabel;

- (IBAction)speedTextViewDidBeginEditing:(id)sender;
- (IBAction)donePressed:(id)sender;
@end
