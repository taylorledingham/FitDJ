//
//  WorkoutsCollectionViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "WorkoutsCollectionViewController.h"
#import "TLCoreDataStack.h"
#import "Workout.h"
#import "PlayWorkoutViewController.h"
#import "AddWorkoutCollectionViewCell.h"

@interface WorkoutsCollectionViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


@end

@implementation WorkoutsCollectionViewController {
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    UILongPressGestureRecognizer *longPress;
    UIButton *deleteButton;
    CFTimeInterval longPressTimeInterval;
    UITapGestureRecognizer *doubleTap;
    BOOL isEditing;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classe
    _objectChanges = [NSMutableArray array];

    deleteButton.imageView.image = [UIImage imageNamed:@"deleteX"];
    
    isEditing = NO;
    //[self.collectionView addGestureRecognizer:doubleTap];
    [self.fetchedResultsController performFetch:nil];

    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:NO];
    if(self.workoutToDisplay){
    
        [self performSegueWithIdentifier:@"playWorkout" sender:self.workoutToDisplay];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"playWorkout"]) {
        PlayWorkoutViewController *playWorkoutVC = (PlayWorkoutViewController *)segue.destinationViewController;
        self.workoutToDisplay = nil;
        if([sender isKindOfClass:[WorkoutTypeCollectionViewCell class]]){
        WorkoutTypeCollectionViewCell *cell = (WorkoutTypeCollectionViewCell *)sender;
        playWorkoutVC.workout = cell.workout;
        }
        else {
            playWorkoutVC.workout = (Workout *)sender;
        }
        
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"playWorkout"]) {
       // return NO;
    }
    
    return YES;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        
        AddWorkoutCollectionViewCell *cell = (AddWorkoutCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AddCell" forIndexPath:indexPath];
        
        return cell;
    }
    else {
    WorkoutTypeCollectionViewCell *cell = (WorkoutTypeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        Workout *workout;
        NSInteger row = indexPath.row -1;
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
        
        workout = [self.fetchedResultsController objectAtIndexPath:newPath];
        UIImage *workoutImage;
        if([workout.workoutType isEqualToString:@"interval"]){
            workoutImage = [UIImage imageNamed:@"intervalIcon"];
        }
        else if([workout.workoutType isEqualToString:@"timed"]){
            workoutImage = [UIImage imageNamed:@"timeIcon"];
        }
        else if([workout.workoutType isEqualToString:@"distance"]){
            workoutImage = [UIImage imageNamed:@"distanceIcon"];
        }
        else if([workout.workoutType isEqualToString:@"custom"]){
            workoutImage = [UIImage imageNamed:@"randomIcon"];
        }

        cell.workoutName.text = workout.workoutName;
        cell.workoutTypeImageView.image = workoutImage;
        float duration = [workout.workoutDuration floatValue];
        cell.workoutDuration.text = [NSString stringWithFormat:@"%.2f", duration];
        cell.workout = workout;
        if(isEditing){
            cell.deleteButton.hidden = NO;
        }
         else {
             cell.deleteButton.hidden = YES;
         }
        cell.delegate = self;
    
    return cell;
    }
}




-(BOOL)deleteWorkoutCell:(WorkoutTypeCollectionViewCell *)cell {
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSPredicate *deleteWorkoutPredicate = [NSPredicate predicateWithFormat:@"self == %@", cell.workout ];
    NSFetchRequest *request = [self workoutFetchRequest];
    [request setPredicate:deleteWorkoutPredicate];
    NSError *error = nil;
    
    NSArray *fetchedObjects = [coreDataStack.managedObjectContext executeFetchRequest:request error:&error];
    
    if(error){
        NSLog(@"error couldn't delete workout: %@", error);
        return  NO;
    }
    
    for( NSManagedObject * workout in fetchedObjects) {
        
        [[coreDataStack managedObjectContext] deleteObject:workout];
    
    }
    [coreDataStack saveContext];
    [self.collectionView reloadData];
    
    return YES;

    
}

-(void)deleteWorkout:(WorkoutTypeCollectionViewCell *)cell {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Workout?"
                                                                   message:[NSString stringWithFormat: @"Are you sure you want to delete this workout?"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * keepAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            
                                                            [self dismissViewControllerAnimated:alert completion:nil];
                                                        }];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self deleteWorkoutCell:cell];
                                                             [self dismissViewControllerAnimated:alert completion:nil];
                                                             
                                                             
                                                         }];
    
    [alert addAction:keepAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];


}

-(void)startEditing {
    
    if(isEditing == NO){
    
    isEditing = YES;
    }
    [self.collectionView reloadData];
    
    
}

-(void)doneEditing {
    isEditing = NO;
    [self.collectionView reloadData];
    
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark collection view cell layout / size
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self getCellSize:indexPath];  // will be w120xh100 or w190x100
    // if the width is higher, only one image will be shown in a line
}

-(CGSize)getCellSize:(NSIndexPath *)path {
    //return CGSizeMake(self.view.frame.size.width / 3 - 30, self.view.frame.size.width / 3 - 30);
    float width;
    if([UIScreen mainScreen].bounds.size.width < 375){
    width = 86;
    }
    else {
        width = 105;
    }
    return CGSizeMake(width, width);

}


#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    float right;
    float left;
    if([UIScreen mainScreen].bounds.size.width <375){
        right = 10;
        left = 15;
    }
    else {
        right = 40;
        left = 10;
    }

    return UIEdgeInsetsMake(-30, left, 0, right); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}


#pragma mark - NSFetchedResultController Delegate methods

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self workoutFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


-(NSFetchRequest *)workoutFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"workoutName" ascending:YES]];
    
    return fetchRequest;
}




- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        if (self.collectionView.window == nil) {
            
            [self.collectionView reloadData];
        } else {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        NSIndexPath *path = (NSIndexPath *)obj;
                        NSInteger row = path.row + 1;
                        NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:path.section];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[newPath]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[newPath]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}


@end
