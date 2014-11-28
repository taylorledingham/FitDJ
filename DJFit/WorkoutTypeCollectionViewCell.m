//
//  WorkoutTypeCollectionViewCell.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "WorkoutTypeCollectionViewCell.h"

@implementation WorkoutTypeCollectionViewCell

- (IBAction)deleteButtonPressed:(id)sender {
    
    
    [self.delegate deleteWorkout:self];
}
@end
