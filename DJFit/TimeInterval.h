//
//  TimeInterval.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Workout;

@interface TimeInterval : NSManagedObject

@property (nonatomic, retain) NSNumber * end;
@property (nonatomic, retain) NSNumber * incline;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) Workout *workout;

@end
