//
//  BPMViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-26.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import <AVFoundation/AVFoundation.h>


@interface BPMViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *songArtworkImageView;
@property (strong, nonatomic) IBOutlet UIPickerView *bpmPickerView;

@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) Song *song;
- (IBAction)tapButtonTouchedDown:(id)sender;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)tapButtonPressed:(id)sender;

@end
