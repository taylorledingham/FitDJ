//
//  Workout.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist, TimeInterval;

@interface Workout : NSManagedObject

@property (nonatomic, retain) NSNumber * numberOfRounds;
@property (nonatomic, retain) NSNumber * workoutDuration;
@property (nonatomic, retain) NSString * workoutName;
@property (nonatomic, retain) NSString * workoutType;
@property (nonatomic, retain) Playlist *playlist;
@property (nonatomic, retain) NSSet *timeIntervals;
@property (nonatomic, retain) NSDate *dateCreated;


@end

@interface Workout (CoreDataGeneratedAccessors)

- (void)addTimeIntervalsObject:(TimeInterval *)value;
- (void)removeTimeIntervalsObject:(TimeInterval *)value;
- (void)addTimeIntervals:(NSSet *)values;
- (void)removeTimeIntervals:(NSSet *)values;

@end
