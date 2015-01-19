//
//  Workout.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "Workout.h"
#import "Playlist.h"
#import "TimeInterval.h"

NSString *const kTimeWorkout = @"timed";
NSString *const kDistanceWorkout = @"distance";
NSString *const kIntervalWorkout = @"interval";
NSString *const kCustomWorkout = @"custom";
NSString *const kTypeTreadmill = @"treadmill";
NSString *const kTypeBike = @"bike";

@implementation Workout

@dynamic numberOfRounds;
@dynamic workoutDuration;
@dynamic workoutName;
@dynamic workoutType;
@dynamic machineType;
@dynamic playlist;
@dynamic timeIntervals;
@dynamic dateCreated;

@end
