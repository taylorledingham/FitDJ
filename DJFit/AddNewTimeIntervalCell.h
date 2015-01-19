//
//  AddNewTimeIntervalCell.h
//  DJFit
//
//  Created by Taylor Ledingham on 2014-12-20.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddNewTimeIntervalCell;

@protocol addNewTime <NSObject>

-(void)makeNewRow;
-(void)saveNewRow:(AddNewTimeIntervalCell *)cell;

@end

@interface AddNewTimeIntervalCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIButton * addButton;

@property (weak, nonatomic) id <addNewTime> delegate;

- (IBAction)addNewTimeRow:(id)sender;

@end
