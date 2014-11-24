//
//  WorkoutTypeCollectionViewCell.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutTypeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *workoutName;
@property (weak, nonatomic) IBOutlet UILabel *workoutDuration;
@property (weak, nonatomic) IBOutlet UIImageView *workoutTypeImageView;

@end
