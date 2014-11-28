//
//  PlaylistsTableViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-20.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Playlist.h"
#import "Song.h"

@protocol reloadSongsDelegate <NSObject>

-(void)reloadSongs;

@end


@interface PlaylistsTableViewController : UITableViewController <reloadSongsDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *songImageView;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *songBPMLabel;

@end
