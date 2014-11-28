//
//  PlaylistsTableViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-20.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "PlaylistsTableViewController.h"
#import "TLCoreDataStack.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SongTableViewCell.h"
#import "BPMViewController.h"

@interface PlaylistsTableViewController ()  <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PlaylistsTableViewController {
    MPMusicPlayerController* musicPlayer;
    MPMediaQuery *songQuery;
    NSArray *songArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    songArray = [[NSArray alloc]init];
    songQuery = [[MPMediaQuery alloc] init];
    //musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self.fetchedResultsController performFetch:nil];

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
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongTableViewCell *cell = (SongTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.songTitleLabel.text = song.songTitle;
    cell.songBPMLabel.text = [NSString stringWithFormat:@"%.1f", [song.bpm floatValue]];
    cell.song = song;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaItemArtwork* artwork ;
            // try album artwork
            MPMediaQuery*   mediaQuery = [MPMediaQuery songsQuery];
            MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue:song.persistentID forProperty:MPMediaItemPropertyPersistentID];
            [mediaQuery addFilterPredicate:predicate];
            NSArray* arrMediaItems = [mediaQuery items];
            if ( [arrMediaItems count] > 0 ) {
                artwork = [[arrMediaItems objectAtIndex:0] valueForProperty:MPMediaItemPropertyArtwork];
            }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ( artwork != nil) {
                cell.songImageView.image =  [artwork imageWithSize:CGSizeMake (cell.songImageView.frame.size.width, cell.songImageView.frame.size.width)];
            }
            else {
                //cell.imageView.image = [UIImage imageNamed:@"musicNote"];
            }
       });
    });
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
     SongTableViewCell *cell = (SongTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
     [self deleteSong:cell];
     
 
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 

-(void)deleteSong:(SongTableViewCell *)cell {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSPredicate *deleteSongPredicate = [NSPredicate predicateWithFormat:@"self == %@", cell.song ];
    NSFetchRequest *request = [self entryListFetchRequest];
    [request setPredicate:deleteSongPredicate];
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

-(void)donePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)reloadSongs {
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath * indexPath = [self.tableView indexPathsForSelectedRows].firstObject;
    SongTableViewCell *cell = (SongTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    BPMViewController *bpmVC = (BPMViewController *)segue.destinationViewController;
    [bpmVC view];
    bpmVC.songTitleLabel.text = cell.songTitleLabel.text;
    bpmVC.songArtworkImageView.image = cell.songImageView.image;
    bpmVC.song = cell.song;
    bpmVC.delegate = self;
    [bpmVC.bpmPickerView selectRow:[cell.songBPMLabel.text integerValue ] inComponent:0 animated:YES];
    
}


@end
