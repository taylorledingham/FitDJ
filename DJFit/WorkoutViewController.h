//
//  WorkoutViewController.h
//  
//
//  Created by Taylor Ledingham on 2014-11-17.
//
//

#import <UIKit/UIKit.h>

@protocol doneEditingDelegate <NSObject>

-(void)doneEditing;

@end

@interface WorkoutViewController : UIViewController

@property (weak, nonatomic) id <doneEditingDelegate> delegate;
- (IBAction)gearButtonPressed:(id)sender;


@end
