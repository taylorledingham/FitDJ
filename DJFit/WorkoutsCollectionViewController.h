//
//  WorkoutsCollectionViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WorkoutTypeCollectionViewCell.h"
#import "WorkoutViewController.h"


@interface WorkoutsCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, deleteWorkoutDelegate, doneEditingDelegate>

-(void)startEditing ;

@end
