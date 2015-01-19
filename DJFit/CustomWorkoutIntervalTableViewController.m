//
//  CustomWorkoutIntervalTableViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-12-12.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "CustomWorkoutIntervalTableViewController.h"
#import "AddNewTimeIntervalCell.h"


@interface CustomWorkoutIntervalTableViewController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


@end

@implementation CustomWorkoutIntervalTableViewController {
    Workout *workout;
    NSMutableArray *timeIntervals;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    
    timeIntervals = [[NSMutableArray alloc]init];
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    
    TimeInterval *newTime = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
    [timeIntervals addObject:newTime];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return timeIntervals.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        
   // [self.tableView registerClass:[AddNewTimeIntervalCell class] forCellReuseIdentifier:@"AddCell"];
    AddNewTimeIntervalCell *cell = (AddNewTimeIntervalCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCell" forIndexPath:indexPath];
        cell.delegate = self;
    return cell;
}

else {
    
   // [self.tableView registerClass:[CustomTimeIntervalCell class] forCellReuseIdentifier:@"CustomCell"];
    CustomTimeIntervalCell *cell = (CustomTimeIntervalCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    TimeInterval *timeInterval = [timeIntervals objectAtIndex:indexPath.row-1];
    cell.timeInterval = timeInterval;
    cell.speedTextField.text = [timeInterval.speed stringValue];
    if(timeInterval.start.floatValue == 0){
         cell.durationTextField.text = @"00:00";
    }
    else {
        cell.durationTextField.text = [self convertSecondsToTimeString:timeInterval.start.floatValue];
    }
    cell.inclineTextField.text = [timeInterval.incline stringValue];
    cell.speedTextField.delegate = cell;
    cell.durationTextField.delegate = cell;
    cell.inclineTextField.delegate = cell;
    
    cell.delegate = self;
    
    return cell;
}
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        [self makeNewRow];
    }
    
}


-(void)deleteSong:(CustomTimeIntervalCell *)cell {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
   // NSPredicate *deleteSongPredicate = [NSPredicate predicateWithFormat:@"self == %@", cell.song ];
    NSFetchRequest *request = [self entryListFetchRequest];
   // [request setPredicate:deleteSongPredicate];
    NSError *error = nil;
    
    NSArray *fetchedObjects = [coreDataStack.managedObjectContext executeFetchRequest:request error:&error];
    
    
    for( NSManagedObject * song in fetchedObjects) {
        
        [[coreDataStack managedObjectContext] deleteObject:song];
        
    }
    [coreDataStack saveContext];
    [self.tableView reloadData];
    
    
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self entryListFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


-(NSFetchRequest *)entryListFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"songTitle" ascending:NO]];
    
    return fetchRequest;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}



-(void)makeNewRow {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    [self saveTimeIntervals];


    [self.tableView beginUpdates];

    TimeInterval *newTime = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
    [timeIntervals addObject:newTime];

    NSIndexPath *path = [NSIndexPath indexPathForRow:timeIntervals.count inSection:0];
    [coreDataStack saveContext];
    NSArray *paths = [[NSArray alloc]initWithObjects:path, nil];
    [self.tableView insertRowsAtIndexPaths:(NSArray *) paths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView reloadData];

    
}
-(void)saveNewRow:(AddNewTimeIntervalCell *)cell {
    
}

-(void)deleteTimeIntervalCell:(CustomTimeIntervalCell *)cell {
    [timeIntervals removeObject:cell.timeInterval];
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    [[coreDataStack managedObjectContext] deleteObject:cell.timeInterval];
    [coreDataStack saveContext];
    
     NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *paths = [[NSArray alloc]initWithObjects:indexPath, nil];
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView reloadData];

    
}

-(void)saveTimeIntervals {
    
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:1 inSection:0];
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];

    
    for (TimeInterval *intervals in timeIntervals) {
        
        CustomTimeIntervalCell *cell = (CustomTimeIntervalCell *)[self.tableView cellForRowAtIndexPath:newPath];
        float speed, roundedSpeed, roundedIncline;
        newPath = [NSIndexPath indexPathForRow:(newPath.row + 1) inSection:0];
        if(![cell.speedTextField.text  isEqual: @"0"]){
        speed = [cell.speedTextField.text floatValue];
        roundedSpeed = speed < 0.5f ? 0.5f : floorf(speed * 2) / 2;
        }
        else {
            roundedSpeed = 0;
        }
        if(![cell.inclineTextField.text  isEqual: @"0"]){
        roundedIncline = [cell.inclineTextField.text floatValue] < 0.5f ? 0.5f : floorf([cell.inclineTextField.text floatValue] * 2) / 2;

        }
        else {
            roundedIncline = 0;
        }
        intervals.start = [NSNumber numberWithFloat:[self convertTimeStringToSeconds:cell.durationTextField.text]];
        intervals.speed = [NSNumber numberWithFloat:roundedSpeed];
        intervals.incline = [NSNumber numberWithFloat:roundedIncline];
        
    }
    [coreDataStack saveContext];
}

-(NSArray *)getCustomTimeIntervals {
    
    NSMutableArray *savedTimeIntervals = [[NSMutableArray alloc]init];
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    for (TimeInterval *intervals in timeIntervals) {
        
    CustomTimeIntervalCell *cell = (CustomTimeIntervalCell *)[self.tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:newPath];
        
        
        newPath = [NSIndexPath indexPathForRow:(newPath.row+1) inSection:0];
        
    }
    
    [coreDataStack saveContext];
    return savedTimeIntervals;
}

-(NSString *)convertSecondsToTimeString:(float)timeInSeconds {
    float minutes = timeInSeconds / 60;
    float seconds = fmodf(timeInSeconds, 60);
    minutes = minutes - (seconds/60);
    NSString *lengthString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutes, seconds];
    return lengthString;
}

-(float)convertTimeStringToSeconds:(NSString *)timeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"mm:ss";
    NSDate *timeDate = [formatter dateFromString:timeString];
    
    formatter.dateFormat = @"mm";
    int minutes = [[formatter stringFromDate:timeDate] intValue];
    formatter.dateFormat = @"ss";
    int seconds = [[formatter stringFromDate:timeDate] intValue];
    
    float timeInSeconds = seconds + minutes * 60;
    
    return timeInSeconds;
}


@end
