//
//  ProfileDetailsViewController.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentControl;

- (IBAction)genderSegmentChanged:(id)sender;
- (IBAction)donePressed:(id)sender;
@end
