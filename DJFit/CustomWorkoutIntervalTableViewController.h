//
//  CustomWorkoutIntervalTableViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-12-12.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddNewTimeIntervalCell.h"
#import <CoreData/CoreData.h>
#import "CustomTimeIntervalCell.h"
#import "TLCoreDataStack.h"
#import "Workout.h"
#import "TimeInterval.h"

@interface CustomWorkoutIntervalTableViewController : UITableViewController <addNewTime, deleteTimeInterval>

-(NSArray *)getCustomTimeIntervals;

@end
