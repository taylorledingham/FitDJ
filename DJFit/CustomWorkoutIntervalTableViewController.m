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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    timeIntervals = [[NSMutableArray alloc]init];
    
    
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
        
    
    AddNewTimeIntervalCell *cell = (AddNewTimeIntervalCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCell" forIndexPath:indexPath];
    return cell;
}

else {
    

    CustomTimeIntervalCell *cell = (CustomTimeIntervalCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    TimeInterval *timeInterval = [timeIntervals objectAtIndex:indexPath.row-1];
    cell.timeInterval = timeInterval;
    cell.speedTextField.text = [timeInterval.speed stringValue];
    cell.durationTextField.text = [timeInterval.start stringValue];
    cell.inclineTextField.text = [timeInterval.incline stringValue];
    
    return cell;
}
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    return 80;
//}





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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}







-(void)makeNewRow {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    
    TimeInterval *newTime = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
    

    
}
-(void)saveNewRow:(AddNewTimeIntervalCell *)cell {
    
}



@end
