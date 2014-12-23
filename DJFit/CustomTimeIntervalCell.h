//
//  CustomTimeIntervalCell.h
//  
//
//  Created by Taylor Ledingham on 2014-12-20.
//
//

#import <UIKit/UIKit.h>
#import "TimeInterval.h"

@interface CustomTimeIntervalCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *speedTextField;
@property (strong, nonatomic) IBOutlet UITextField *durationTextField;
@property (strong, nonatomic) IBOutlet UITextField *inclineTextField;
@property (strong, nonatomic) TimeInterval *timeInterval;

- (IBAction)deleteIntervalPressed:(id)sender;

@end
