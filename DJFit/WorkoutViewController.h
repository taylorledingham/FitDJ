//
//  WorkoutViewController.h
//  
//
//  Created by Taylor Ledingham on 2014-11-17.
//
//

#import <UIKit/UIKit.h>

@class WorkoutsCollectionViewController;

@protocol doneEditingDelegate <NSObject>

-(void)doneEditing;

@end

@interface WorkoutViewController : UIViewController

@property (weak, nonatomic) id <doneEditingDelegate> delegate;
@property (strong, nonatomic) WorkoutsCollectionViewController *collectionVC;

- (IBAction)gearButtonPressed:(id)sender;


@end
