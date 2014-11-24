//
//  WorkoutCollectionViewFlowLayout.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-23.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "WorkoutCollectionViewFlowLayout.h"

@implementation WorkoutCollectionViewFlowLayout

- (instancetype)init {
    
    self = [super init];
    self.itemSize = CGSizeMake(110.0, 110.0);
    self.minimumInteritemSpacing = 1.0;
    self.minimumLineSpacing = 1.0;

    return self;
}

@end
