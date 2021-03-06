//
//  WorkoutTypeCollectionViewCell.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"

@class WorkoutTypeCollectionViewCell;

@protocol deleteWorkoutDelegate <NSObject>

-(void)deleteWorkout:(WorkoutTypeCollectionViewCell *)cell;

@end

@interface WorkoutTypeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *workoutName;
@property (weak, nonatomic) IBOutlet UILabel *workoutDuration;
@property (weak, nonatomic) IBOutlet UIImageView *workoutTypeImageView;
@property (weak, nonatomic) Workout *workout;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) id <deleteWorkoutDelegate> delegate;

- (IBAction)deleteButtonPressed:(id)sender;


@end
