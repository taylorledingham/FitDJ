//
//  InterfaceController.h
//  DJFit WatchKit Extension
//
//  Created by Taylor Ledingham on 2014-11-28.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
- (IBAction)nextButtonPressed;
- (IBAction)prevButtonPressed;
- (IBAction)playPauseButtonPressed;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *workoutTimer;


@property (weak, nonatomic) IBOutlet WKInterfaceButton *playPauseButton;

@end
