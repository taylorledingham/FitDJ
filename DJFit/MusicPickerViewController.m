//
//  MusicPickerViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "MusicPickerViewController.h"
#import "bass.h"
#import "bassfx.h"
#import "Song.h"
#import "Playlist.h"
#import <LLARingSpinnerView/LLARingSpinnerView.h>
#import "PlayWorkoutViewController.h"
#import "Workout.h"
#import "WorkoutViewController.h"
#import "WorkoutsCollectionViewController.h"


@interface MusicPickerViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSArray* songsArray;
@property (strong, nonatomic) MPMediaItemCollection *items;
@property (strong, nonatomic) NSMutableArray *pathArray;
@property (strong, nonatomic) NSMutableArray *avPlayerItemsArray;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


@end

@implementation MusicPickerViewController {

    MPMediaPickerController *picker;
    Playlist *playlist;
    NSMutableSet *songs;
    NSFileManager *fileManager;
    LLARingSpinnerView *spinnerView;
    BOOL musicDone;
    NSUInteger index;
    UILabel *waiting ;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    songs = [[NSMutableSet alloc]init];
    [self showMediaPicker];
    [self.fetchedResultsController performFetch:nil];
    self.view.backgroundColor = [UIColor colorWithRed:0.808f green:0.808f blue:0.808f alpha:1.00f];
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *playlistRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
    NSError *error;
    NSArray *result = [coreDataStack.managedObjectContext executeFetchRequest:playlistRequest error:&error];
    playlist = (Playlist *)result.firstObject;
    if(result.count == 0){
    playlist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:coreDataStack.managedObjectContext];
    }
   playlist.playlistName = @"playlist";
    self.workout.playlist = playlist;
    songs = [NSMutableSet setWithSet: playlist.playlistSongs];
    [coreDataStack saveContext];
    fileManager = [NSFileManager defaultManager];
    waiting = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.center.y, self.view.frame.size.width, 100)];
    waiting.numberOfLines = 2;
    waiting.textColor = [UIColor colorWithRed:0.537f green:0.220f blue:0.714f alpha:1.00f];
    waiting.text = @"Calculating BPM...";
    waiting.textAlignment = NSTextAlignmentCenter;
    waiting.font = [UIFont fontWithName:@"Avenir-Black" size:30];
    
    spinnerView = [[LLARingSpinnerView alloc] initWithFrame:CGRectMake(self.view.center.x-20, self.view.center.y-80, 40, 40)];
    // Optionally set the current progress
    spinnerView.lineWidth = 1.5f;
    spinnerView.hidden = YES;
    // Optionally change the tint color
    spinnerView.tintColor = [UIColor colorWithRed:0.537f green:0.220f blue:0.714f alpha:1.00f];
    [self.view addSubview:spinnerView];
    

    
}

-(void)viewWillAppear:(BOOL)animated {
    musicDone = NO;
}

- (void) showMediaPicker
{
    picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    [[picker view] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.537f green:0.220f blue:0.714f alpha:1.00f]];
    picker.delegate  = self;
    picker.allowsPickingMultipleItems = YES;
    picker.showsCloudItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection
{
    spinnerView.hidden = NO;
   [self dismissViewControllerAnimated:YES completion:nil];
    self.songsArray = [collection items] ;
    self.items = collection;
    [self.view addSubview:waiting];
    [self loadPlaylistWithSongs];
    [spinnerView startAnimating];

    
    
}

- (void)loadPlaylistWithSongs {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    index = self.songsArray.count;
    
    for(int i=0; i<self.songsArray.count; i++){
        
        MPMediaItem *item = self.songsArray[i];

        [self convertMediaItem:item ];
    }
    
    
    musicDone = YES;

    }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(Song *)doesSongExist:(NSNumber *)mediaID {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *songRequest = [[NSFetchRequest alloc]initWithEntityName:@"Song"];
    NSPredicate *songIDPredicate = [NSPredicate predicateWithFormat:@"persistentID == %@ AND bpm!=0" , mediaID];
    songRequest.predicate = songIDPredicate;
    NSError *error;
    NSArray *result = [coreDataStack.managedObjectContext executeFetchRequest:songRequest error:&error];
    if(result.count == 0){
        return nil;
    }
    NSLog(@"line 147: index: %lu", (unsigned long)index);
    return result.firstObject;
}

#pragma mark - convert media item AVURLAsset

-(void)convertMediaItem:(MPMediaItem *)song {
    
    Song *mySong = [self doesSongExist:[song valueForProperty:MPMediaItemPropertyPersistentID]];
    if (mySong != nil){
        NSArray *songArray = @[@"", mySong];
        [songs addObject:mySong];
        [self done:songArray];
    }
    else {
        TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
        Song *newSong = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:coreDataStack.managedObjectContext];
        newSong.persistentID = [song valueForProperty:MPMediaItemPropertyPersistentID];
        newSong.songURL = [NSString stringWithFormat:@"%@",[song valueForKey:MPMediaItemPropertyAssetURL]];
        newSong.songTitle = song.title;
        [songs addObject:newSong];
        
        NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
        AVPlayerItem *avItem = [[AVPlayerItem alloc] initWithURL:assetURL];
        BOOL isDRM = avItem.asset.hasProtectedContent;
        if(isDRM == YES  || assetURL == nil){
            index = index - 1;
            [self calculateBPMWithPathString:@"" andSong:newSong];
            
        }
        else {

        NSString *pathStr = [[NSString alloc]init];
        pathStr = [NSString stringWithFormat:@"%@.wav", [song valueForProperty:MPMediaItemPropertyPersistentID]];
    
   
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSError *assetError = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                               error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil]
    ;
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    [assetReader addOutput: assetReaderOutput];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", pathStr]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                          fileType:AVFileTypeWAVE
                                                             error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         // NSLog (@"top of block");
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 //				NSLog (@"appended a buffer (%d bytes)",
                 //					   CMSampleBufferGetTotalSampleSize (nextBuffer));
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 // oops, no
                 // sizeLabel.text = [NSString stringWithFormat: @"%ld bytes converted", convertedByteCount];
                 
                // NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];

             } else {
                 // done!
                 [assetWriterInput markAsFinished];
                 // [assetWriter finishWriting];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:exportPath
                                                       error:nil];
                 NSLog (@"done. file size is %llu",
                        [outputFileAttributes fileSize]);
                // NSNumber *doneFileSize = [NSNumber numberWithLong:[outputFileAttributes fileSize]];
                 NSArray *pathAndSong = @[exportPath, newSong];
                  [self performSelectorOnMainThread:@selector(done:)
                                       withObject:pathAndSong
                                   waitUntilDone:YES];
                 
                 break;
             }
         }
         
     }];
    }
    }

}

-(void)done:(NSArray *)pathAndSong {
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    if(![pathAndSong[0]  isEqual: @""]){
    [self calculateBPMWithPathString:pathAndSong[0] andSong:pathAndSong[1]];
    }
    NSSet *songSet = songs;
    playlist.playlistSongs = songSet;
    self.workout.playlist = playlist;
    index = index - 1;
    NSLog(@"index: %lu", (unsigned long)index);
    if(index <= self.songsArray.count){
        WorkoutViewController *rootController =
        (WorkoutViewController *)
        [self.navigationController.viewControllers objectAtIndex: 0];
        WorkoutsCollectionViewController *collectionVC = rootController.collectionVC;
        collectionVC.workoutToDisplay = self.workout;

        [self.navigationController popToRootViewControllerAnimated:NO];

        [spinnerView stopAnimating];
        [coreDataStack saveContext];


   }


    
}

-(void)calculateBPMWithPathString:(NSString *)pathStr andSong:(Song *)song {
    
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    int device = -1; // Default device
    int freq = 44100; // Sample rate
    
    BASS_Init(device, freq, 0, 0, NULL);
    
    if(!(BASS_StreamCreateFile(FALSE,[pathStr UTF8String],0,0,BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE))) {
        NSLog(@"BPM CHAN FAILED %d", BASS_ErrorGetCode());
        
    }
    
    else {
    
    
    HSTREAM mainStream = BASS_StreamCreateFile(FALSE,[pathStr UTF8String],0,0,BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE);
    
    float playBackDuration=BASS_ChannelBytes2Seconds(mainStream, BASS_ChannelGetLength(mainStream, BASS_POS_BYTE));
    
    HSTREAM  bpmStream=BASS_StreamCreateFile(FALSE, [pathStr UTF8String], 0, 0, BASS_STREAM_PRESCAN|BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
    
    float BpmValue= BASS_FX_BPM_DecodeGet(
                                          bpmStream,
                                          0.00,
                                          playBackDuration,
                                          MAKELONG(45,200),
                                          BASS_FX_BPM_MULT2,
                                          NULL,
                                          NULL);
    
    
    
    
    //Check if BpmValue have any value or not.
    //If it haven't any value then set default value to 128.
    if(BpmValue<=0)
        BpmValue = 128.00;
    
    song.bpm = [NSNumber numberWithFloat:BpmValue];
    [coreDataStack saveContext];
    NSError *error;
    [fileManager removeItemAtPath:pathStr error:&error];
    if(error){
        NSLog(@"couldnt delete: %@", pathStr);
    }
    
    NSLog(@"%@: %f", pathStr, BpmValue);
    
    }
    
    
    
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if (musicDone == NO) {
        return false;
    }
    
    return true;
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"showWorkoutPlayer"]){
        PlayWorkoutViewController *playVC = (PlayWorkoutViewController *)segue.destinationViewController;
        playVC.workout = self.workout;
        
    }
    
}


@end
