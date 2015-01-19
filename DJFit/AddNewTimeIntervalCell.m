//
//  AddNewTimeIntervalCell.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-12-20.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "AddNewTimeIntervalCell.h"

@implementation AddNewTimeIntervalCell

- (IBAction)addNewTimeRow:(id)sender {
    [self.delegate makeNewRow];
}

@end
