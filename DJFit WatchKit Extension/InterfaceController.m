//
//  InterfaceController.m
//  DJFit WatchKit Extension
//
//  Created by Taylor Ledingham on 2014-11-28.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@property (strong, nonatomic) NSArray *songArray;

@end


@implementation InterfaceController {
    NSTimer *myWorkoutTimer;
    double finishedTime;
    double timeInMilliseconds;
    NSInteger songIndex;
    BOOL isPlaying;
}

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
        
        self.songArray = @[@"Daylight", @"Shake it Off", @"Bounce", @"Stronger", @"Talk A Walk", @"Love The Way You Lie", @"Chocolate", @"Love Me Again", @"It's Time"];
        songIndex = 0;
        [self.songTitleLabel setText:[self.songArray objectAtIndex:songIndex]];
                timeInMilliseconds = 0;
        finishedTime = 60 * 60 * 1000;
        isPlaying = NO;
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
}


-(void)workoutTimer:(NSTimer *)timer{
    
    [timer invalidate];
    [self.workoutTimer stop];
    
    
    
}
- (IBAction)nextButtonPressed {
    if(songIndex == self.songArray.count - 1){
        songIndex = 0;
        
    }
    else{
        songIndex++;
    }
    [self.songTitleLabel setText:[self.songArray objectAtIndex:songIndex]];

}

- (IBAction)prevButtonPressed {
    if(songIndex == 0){
        songIndex = self.songArray.count -1;

    }
    else {
        songIndex--;
    }
    [self.songTitleLabel setText:[self.songArray objectAtIndex:songIndex]];

}

- (IBAction)playPauseButtonPressed {
    
       myWorkoutTimer = [NSTimer timerWithTimeInterval:1200 target:self selector:@selector(workoutTimer:) userInfo:nil repeats:NO];
   
    NSDate *currentDate = [NSDate date];
    NSDate *datePlusOneMinute = [currentDate dateByAddingTimeInterval:1200];
    [self.workoutTimer setDate:datePlusOneMinute];
        isPlaying = YES;
    [self.workoutTimer start];
   
    
}
@end



