//
//  PlayWorkoutViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import "TLCoreDataStack.h"

@interface PlayWorkoutViewController : UIViewController

@property (strong, nonatomic) Workout *workout;

@property (weak, nonatomic) IBOutlet UIButton *startWorkoutButton;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *inclineLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;


- (IBAction)startWorkoutPressed:(id)sender;
- (IBAction)previousSelected:(id)sender;
- (IBAction)playPauseSelected:(id)sender;

- (IBAction)nextSelected:(id)sender;



@end