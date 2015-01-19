//
//  CustomTimeIntervalCell.h
//  
//
//  Created by Taylor Ledingham on 2014-12-20.
//
//

#import <UIKit/UIKit.h>
#import "TimeInterval.h"
#import "TLCoreDataStack.h"

@class CustomTimeIntervalCell;

@protocol deleteTimeInterval <NSObject>

-(void)deleteTimeIntervalCell:(CustomTimeIntervalCell *)cell;

@end

@interface CustomTimeIntervalCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *speedTextField;
@property (strong, nonatomic) IBOutlet UITextField *durationTextField;
@property (strong, nonatomic) IBOutlet UITextField *inclineTextField;
@property (strong, nonatomic) TimeInterval *timeInterval;
@property (weak, nonatomic) id <deleteTimeInterval> delegate;

- (IBAction)deleteIntervalPressed:(id)sender;

@end
