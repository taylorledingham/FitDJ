//
//  SongTableViewCell.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-25.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@interface SongTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *songImageView;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *songBPMLabel;
@property (strong, nonatomic) Song *song;

@end
