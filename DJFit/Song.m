//
//  Song.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "Song.h"
#import "Playlist.h"


@implementation Song

@dynamic bpm;
@dynamic persistentID;
@dynamic songURL;
@dynamic songTitle;
@dynamic playlist;


+(double)lookUpBPMForSpeed:(double)speed andWorkoutType:(NSString *)type {
    
    if([type isEqualToString: @"treadmill"]){
        NSArray *newArray = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TreadmillBPMTable" ofType:@"plist"]];
        int i=0;
        for (id object in newArray) {
            
            if([object[@"speed"] doubleValue] == speed){
                return [object[@"bpm"] doubleValue];
            }
            
            else if([object[@"speed"] doubleValue] > speed) {
                
                id last = newArray[i-1];
                 return [last[@"bpm"] doubleValue];
            }
                
           i++;
        }
        
    
    }
    return 1.0;
}
    
    

@end
    
    
