//
//  Playlist.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Song.h"

@class Workout;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSString * playlistName;
@property (nonatomic, retain) NSSet *playlistSongs;
@property (nonatomic, retain) Workout *workout;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addPlaylistSongsObject:(NSManagedObject *)value;
- (void)removePlaylistSongsObject:(NSManagedObject *)value;
- (void)addPlaylistSongs:(NSSet *)values;
- (void)removePlaylistSongs:(NSSet *)values;
-(void)addSongToPlaylistSongs:(Song *)song;

- (void)addWorkoutObject:(Workout *)value;
- (void)removeWorkoutObject:(Workout *)value;
- (void)addWorkout:(NSSet *)values;
- (void)removeWorkout:(NSSet *)values;

@end
