//
//  CustomWorkoutViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-12-12.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "CustomWorkoutViewController.h"

#import "Workout.h"
#import "TLCoreDataStack.h"

@implementation CustomWorkoutViewController {
    NSString *workoutName;
    NSSet *workoutTimeIntervals;
    CustomWorkoutNameTableViewController *customNameTableVC;
    CustomWorkoutIntervalTableViewController *customIntervalTableVC;
    
}

-(void)viewDidLoad {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"customWorkoutNameVC"]){
        
        customNameTableVC = (CustomWorkoutNameTableViewController *)segue.destinationViewController;
        
    }
    
    else if([segue.identifier isEqualToString:@"customTimeIntervalVC"]){
        
        customIntervalTableVC = (CustomWorkoutIntervalTableViewController *)segue.destinationViewController;
        
    }
    
}

-(void)donePressed:(id)sender {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    
    Workout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    workout.workoutName = [customNameTableVC getWorkoutName];
    workout.workoutType = @"custom";
    workout.machineType = @"treadmill";
    workout.numberOfRounds = @1;
    workout.dateCreated = [NSDate date];
    NSArray *timeIntervalArray = [customIntervalTableVC getCustomTimeIntervals];
    workout.timeIntervals = [NSSet setWithArray:timeIntervalArray];
    
    [coreDataStack saveContext];
    
}

@end
