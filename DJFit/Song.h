//
//  Song.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSNumber * bpm;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * songURL;
@property (nonatomic, retain) NSSet *playlist;
@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addPlaylistObject:(Playlist *)value;
- (void)removePlaylistObject:(Playlist *)value;
- (void)addPlaylist:(NSSet *)values;
- (void)removePlaylist:(NSSet *)values;

@end
