//
//  PlayWorkoutViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "PlayWorkoutViewController.h"
#import "MusicPickerViewController.h"
#import "WorkoutViewController.h"
#import "Playlist.h"
#import "AVQueuePlayerPrevious.h"

@interface PlayWorkoutViewController ()

@property (strong, nonatomic) AVQueuePlayerPrevious *queuePlayer;

@end

@implementation PlayWorkoutViewController {
    NSTimeInterval workoutDuration;
    NSDateFormatter *dateFormatter;
    UIGestureRecognizer *tapGesture;
    BOOL musicPicked;
    double timeInMilliSeconds;
    double startTimeInMilliSeconds;
    NSTimer *workoutTimer;
    NSNumberFormatter *formatter;
    BOOL timerHasStarted;
    NSMutableArray *avPlayerItemsArray;
    BOOL playerIsPlaying;
    double currentSongRate;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    timeInMilliSeconds = ([self.workout.workoutDuration doubleValue] * 60 * 1000);
    startTimeInMilliSeconds = timeInMilliSeconds;
     formatter = [[NSNumberFormatter alloc] init];
    timerHasStarted = NO;
    playerIsPlaying = NO;
    avPlayerItemsArray = [[NSMutableArray alloc]init];
    self.queuePlayer = [[AVQueuePlayerPrevious alloc]initWithItems:avPlayerItemsArray];
    [self.queuePlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self displayTime:timeInMilliSeconds];
    [self loadPlaylist];
    currentSongRate = 1.0;
    //MusicPickerViewController *musicPickerVC = [[MusicPickerViewController alloc]init];
    //[self presentViewController:musicPickerVC animated:NO completion:nil];
    [self setWorkoutDetails];
    NSLog(@"playlist: %@", self.workout.playlist.playlistName);
    
    
    
}

-(void)displayTime:(double)milliseconds {

   double seconds = milliseconds/1000;
    
 
    NSUInteger h = seconds / 3600;
    NSUInteger m = (int)(seconds / 60) % 60;
    NSUInteger s = (int)seconds % 60;
    
   
    
    NSString *result1 = [NSString stringWithFormat:@"%.2lu:%.2lu:%.2lu", (unsigned long)h, (unsigned long)m,(unsigned long)s];
    self.durationLabel.text = result1;
    
    //self.caloriesLabel.text = [NSString stringWithFormat:@"%.2f", ]
    
}

-(void)calculateCalories {
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    

    
}


-(void)loadPlaylist {
    
   
    
    for (Song *song in self.workout.playlist.playlistSongs) {
        
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString: song.songURL] options:nil];

        self.songTitleLabel.text = song.songTitle;
        double newBPM = [Song lookUpBPMForSpeed:4.0 andWorkoutType:@"treadmill"];
        currentSongRate = newBPM / [song.bpm doubleValue];
        
        NSArray *keyArray = [[NSArray alloc] initWithObjects:@"tracks", nil];
        
        [urlAsset loadValuesAsynchronouslyForKeys:keyArray completionHandler:^{
            
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:urlAsset];
            [playerItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:nil];
            [playerItem addObserver:self forKeyPath:NSStringFromSelector
             (@selector(playbackBufferEmpty)) options:0 context:nil];
            [avPlayerItemsArray addObject:playerItem];
            [self.queuePlayer insertItem:playerItem afterItem:nil];
            
        }];

        
        
    }
    
    [self.queuePlayer pause];

    
    
    
}

-(void)setWorkoutDetails {
    
    self.speedLabel.text = [NSString stringWithFormat:@"Speed: 8.0MPH"];
    self.inclineLabel.text = [NSString stringWithFormat:@"Incline: 0%%"];
    
    
}

-(Song *)getSongFromURL:(NSURL*)assetURL {
    
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *songRequest = [[NSFetchRequest alloc]initWithEntityName:@"Song"];
    NSPredicate *songURLPredicate = [NSPredicate predicateWithFormat:@"songURL == %@" , [assetURL absoluteString]];
    songRequest.predicate = songURLPredicate;
    NSError *error;
    NSArray *result = [coreDataStack.managedObjectContext executeFetchRequest:songRequest error:&error];
    Song *song = [result firstObject];
    
    return song;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)updateTimer:(NSTimer *)timer {
    timeInMilliSeconds = timeInMilliSeconds -  10 ;
    [self displayTime:timeInMilliSeconds];
    if(timeInMilliSeconds <=0) {
        [timer invalidate];
    }
}

- (IBAction)startWorkoutPressed:(id)sender {
    
//    self.view.alpha = 1.0;
//    CABasicAnimation *animationWidth = [CABasicAnimation animation];
//    animationWidth.keyPath = @"size.width";
//    animationWidth.fromValue = @(self.startWorkoutButton.frame.size.width);
//    animationWidth.toValue = @0;
//    CABasicAnimation *animationHeight = [CABasicAnimation animation];
//    animationHeight.keyPath = @"size.height";
//    animationHeight.fromValue = @(self.startWorkoutButton.frame.size.height);
//    animationHeight.toValue = @0;
//    
//    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
//    group.animations = @[ animationWidth, animationHeight ];
//    group.duration = 1.2;
//    group.beginTime = 0.5;
//    
//    [self.startWorkoutButton.layer addAnimation:group forKey:@"shrink"];
    
    if(timerHasStarted == NO){
        self.startStopLabel.text = @"Pause Workout";
         workoutTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];

        timerHasStarted = YES;
        self.queuePlayer.rate = currentSongRate;
        playerIsPlaying = YES;
    }
    else {
        timerHasStarted = NO;
        self.startStopLabel.text = @"Resume Workout";
        [workoutTimer invalidate];
        [self.queuePlayer pause];
    }
    
    
   
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        
        AVAsset *currentPlayerAsset = item.asset;
        // make sure the current asset is an AVURLAsset
        if ([currentPlayerAsset isKindOfClass:AVURLAsset.class]){
        // return the NSURL
        NSURL *songURL = [(AVURLAsset *)currentPlayerAsset URL];

        Song *song = [self getSongFromURL:songURL];
        self.songTitleLabel.text = song.songTitle;
        double newBPM = [Song lookUpBPMForSpeed:4.0 andWorkoutType:@"treadmill"];
         currentSongRate = newBPM / [song.bpm doubleValue];
            NSLog(@"song: %@, rate: %@", song.songTitle, song.bpm);
            
        }
        
        //playerItem status value changed?
        if ([keyPath isEqualToString:@"status"])
        {   //yes->check it...
            switch(item.status)
            {
                case AVPlayerItemStatusFailed:
                   // NSLog(@"player item status failed");
                   // NSLog(@"failed: %ld", item.status);
                    break;
                case AVPlayerItemStatusReadyToPlay:
//                    NSLog(@"player item status is ready to play");
//                    NSLog(@"ready: %ld", item.status);
                    if ([self isPlayerPlaying]) {
                        self.queuePlayer.rate = currentSongRate;
                    }
                    break;
                case AVPlayerItemStatusUnknown:
//                    NSLog(@"player item status is unknown");
//                    NSLog(@"unknown: %ld", item.status);
                    break;

            }
            
            if(playerIsPlaying == YES){
            }
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            if (item.playbackBufferEmpty)
            {
                NSLog(@"player item playback buffer is empty");
            }
        }
    }
}

-(BOOL)isPlayerPlaying{
    NSLog(@"self.queuePlayer.rate:%f", self.queuePlayer.rate);
    if (self.queuePlayer.rate == 0.0f) {
        return NO;
    }else{
        return YES;
    }
    
}

- (IBAction)previousSelected:(id)sender {
    [self.queuePlayer playPreviousItemWithRate:currentSongRate];
    
}

- (IBAction)playPauseSelected:(id)sender {
    if(playerIsPlaying == YES ){
        [self.queuePlayer pause];
        [self.playPauseButton.titleLabel setText:@"Play"];
        playerIsPlaying = NO;
    }
    else {
        
        self.queuePlayer.rate = currentSongRate;
        [self.playPauseButton.titleLabel setText:@"Pause"];
        playerIsPlaying = YES;
    }
    
}
- (IBAction)nextSelected:(id)sender {
    [self.queuePlayer advanceToNextItem];
    
    
    
}
- (IBAction)exitWorkout:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Exit Workout"
                                                                   message:@"Are you sure you want to exit the workout?."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * stayAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                        
                                                            [self dismissViewControllerAnimated:alert completion:nil];
                                                        }];
    
    UIAlertAction* exitAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
    [self dismissViewControllerAnimated:alert completion:nil];
    UIStoryboard * aStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WorkoutViewController *controller = (WorkoutViewController *)[aStoryBoard instantiateViewControllerWithIdentifier: @"myWorkouts"];
      [self.queuePlayer pause];
      self.queuePlayer = nil;
    [self presentViewController:controller animated:YES completion:nil];
                                                              }];
    
    [alert addAction:stayAction];
    [alert addAction:exitAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
@end
