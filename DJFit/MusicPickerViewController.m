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

#define EXPORT_NAME @"exported.wav"

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
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showMediaPicker];
    [self.fetchedResultsController performFetch:nil];
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    playlist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:coreDataStack.managedObjectContext];
   playlist.playlistName = @"playlist";
    [coreDataStack saveContext];
    
}

- (void) showMediaPicker
{
    picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    [[picker view] setFrame:CGRectMake(0, 0, 320, 480)];
    
    picker.delegate  = self;
    picker.allowsPickingMultipleItems = YES;
    picker.prompt      = NSLocalizedString (@"AddSongsPrompt", @"Prompt to user to choose some songs to play");
    picker.showsCloudItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.songsArray = [collection items] ;
    self.items = collection;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)doesSongExist:(NSNumber *)mediaID {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *songRequest = [[NSFetchRequest alloc]initWithEntityName:@"Song"];
    NSPredicate *songIDPredicate = [NSPredicate predicateWithFormat:@"persistentID == %@", mediaID];
    songRequest.predicate = songIDPredicate;
    NSError *error;
    NSArray *result = [coreDataStack.managedObjectContext executeFetchRequest:songRequest error:&error];
    if(result.count == 0){
        return NO;
    }
    
    return YES;
}

#pragma mark - convert media item AVURLAsset

-(void)convertMediaItem:(MPMediaItem *)song {
    
    if ([self doesSongExist:[song valueForProperty:MPMediaItemPropertyPersistentID]] == NO){
        
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    Song *newSong = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:coreDataStack.managedObjectContext];
        newSong.persistentID = [song valueForProperty:MPMediaItemPropertyPersistentID];
        newSong.songURL = [song valueForKey:MPMediaItemPropertyAssetURL];
        [songs addObject:newSong];
    
    NSString *pathStr = [NSString stringWithFormat:@"%@.wav", [song valueForProperty:MPMediaItemPropertyPersistentID]];
    
    NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
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
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"music/%@", pathStr]];
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
                 
                 NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];

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
                 NSNumber *doneFileSize = [NSNumber numberWithLong:[outputFileAttributes fileSize]];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self calculateBPMWithPathString:exportPath andSong:newSong];
                 });
                  [self performSelectorOnMainThread:@selector(done:)
                                       withObject:exportPath
                                   waitUntilDone:YES];
                 
                 break;
             }
         }
         
     }];
    }
    
}

-(void)done:(NSString *)file {
    //[self calculateBPMWithPathString:file];
    
    
}

-(float)calculateBPMWithPathString:(NSString *)pathStr andSong:(Song *)song {
    
    
    DWORD chan1;
    int device = -1; // Default device
    int freq = 44100; // Sample rate
    
    BASS_Init(device, freq, 0, 0, NULL);
    
    if(!(chan1=BASS_StreamCreateFile(FALSE, [pathStr UTF8String], 0, 0, BASS_SAMPLE_LOOP))) {
        NSLog(@"BPM CHAN FAILED %d", BASS_ErrorGetCode());
        
    }
    
    
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
    
    
    NSLog(@"%@: %f", pathStr, BpmValue);
    
    return BpmValue;
    
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
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"persistentID" ascending:NO]];
    
    return fetchRequest;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
