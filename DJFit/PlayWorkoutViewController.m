//
//  PlayWorkoutViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-18.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "PlayWorkoutViewController.h"
#import "WorkoutViewController.h"
#import "Playlist.h"
#import "AVQueuePlayerPrevious.h"
#import "TimeInterval.h"


@interface PlayWorkoutViewController ()



@property (strong, nonatomic) AVQueuePlayerPrevious *queuePlayer;
@property (strong, nonatomic) SimpleBarChart *chart;
@property ( nonatomic) float weight;
@property (nonatomic) float height;
@property (nonatomic) double caloriesBurned;
@property (strong, nonatomic) MPNowPlayingInfoCenter *mediaCenter;
@property (nonatomic) BOOL voiceCoachingEnabled;


@end



@implementation PlayWorkoutViewController {
    NSTimeInterval workoutDuration;
    NSDateFormatter *dateFormatter;
    UIGestureRecognizer *tapGesture;
    BOOL musicPicked;
    double timeInMilliSeconds;
    double currentIntervalInMilliSeconds;
    double timePassedInMilliSeconds;
    NSTimer *totalWorkoutTimer;
    NSTimer *currentIntervalTimer;
    NSNumberFormatter *formatter;
    BOOL timerHasStarted;
    NSMutableArray *avPlayerItemsArray;
    BOOL playerIsPlaying;
    double currentSongRate;
    NSInteger currentTimeIntervalIndex;
    NSArray *timeIntervalsArray;
    Song *currentPlayingSong;
    AVSpeechUtterance *utterance;
    AVSpeechSynthesizer *synth;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    timerHasStarted = NO;
    playerIsPlaying = NO;
    currentTimeIntervalIndex = 0;
    avPlayerItemsArray = [[NSMutableArray alloc]init];
    [self setWorkoutDetails];
    [self setUpQueuePlayer];
    [self loadPlaylist];
    [self displayTime:timeInMilliSeconds onLabel:self.durationLabel];
    timePassedInMilliSeconds = 0;
    [self setUpGraph];
    synth = [[AVSpeechSynthesizer alloc] init];
    self.voiceCoachingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"wantsVoiceCoaching"];
    
}
    
    
-(void)setUpQueuePlayer{
    
    self.queuePlayer = [[AVQueuePlayerPrevious alloc]init];
    self.queuePlayer = [[AVQueuePlayerPrevious alloc]initWithItems:avPlayerItemsArray];
    [self.queuePlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    currentSongRate = 1.0;
    self.mediaCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    self.queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.queuePlayer currentItem]];
    
    
    NSLog(@"playlist: %@", self.workout.playlist.playlistName);
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
}

-(void)setWorkoutDetails {
    
    if([self.workout.workoutType  isEqual: @"timed"] || [self.workout.workoutType  isEqual: @"distance"]){
        
    }
    
    currentTimeIntervalIndex = 0;
    timePassedInMilliSeconds = 0;
    timeIntervalsArray = [[NSArray alloc]init];
    timeIntervalsArray = [self.workout.timeIntervals allObjects];
    [self sortTimeIntervalArray];
    timeInMilliSeconds = ([self.workout.workoutDuration doubleValue] * 60 * 1000);
    TimeInterval *firstinterval = timeIntervalsArray[0];
    currentIntervalInMilliSeconds = ([firstinterval.start doubleValue] * 60 * 1000);
    formatter = [[NSNumberFormatter alloc] init];
    self.caloriesBurned = 0;
    self.speedLabel.text = [NSString stringWithFormat:@"%.1f MPH",[firstinterval.speed floatValue]];
    self.inclineLabel.text = [NSString stringWithFormat:@"%.1f%%",[firstinterval.incline floatValue]];

    
}

-(void)sortTimeIntervalArray {
    
    timeIntervalsArray = [timeIntervalsArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        TimeInterval * time1 = (TimeInterval *)obj1;
        TimeInterval * time2 = (TimeInterval *)obj2;
        
        if(time1.index > time2.index){
            return NSOrderedDescending;
        }
        else if(time2.index == time1.index){
            return NSOrderedSame;
        }
        else {
            return NSOrderedAscending;
        }
    }];

}

-(void)setUpGraph {
    
    self.chart = [[SimpleBarChart alloc]initWithFrame:CGRectMake(0, 0, self.barChartView.frame.size.width+10, 160)];
    [self.barChartView addSubview:self.chart];
    
    self.chart.delegate = self;
    self.chart.dataSource = self;
    self.chart.backgroundColor = [UIColor colorWithRed:0.847f green:0.847f blue:0.847f alpha:1.00f];
    
    self.chart.gridColor = [UIColor colorWithRed:0.847f green:0.847f blue:0.847f alpha:1.00f];
    self.chart.barWidth	= 18.0;
    if([self.workout.workoutType  isEqual: @"timed"] || [self.workout.workoutType  isEqual: @"distance"]){
        self.chart.barWidth	= 50;

    }
    self.chart.incrementValue = 1;
    [self.chart reloadData];
}

-(void)loadPlaylist {

    for (Song *song in self.workout.playlist.playlistSongs) {
        
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString: song.songURL] options:nil];

        self.songTitleLabel.text = song.songTitle;
        TimeInterval *firstTime = [timeIntervalsArray firstObject];
        double newBPM = [Song lookUpBPMForSpeed:[firstTime.speed doubleValue] andWorkoutType:@"treadmill"];
        currentSongRate = newBPM / [song.bpm doubleValue];
        
        NSArray *keyArray = [[NSArray alloc] initWithObjects:@"tracks", nil];
        
        [urlAsset loadValuesAsynchronouslyForKeys:keyArray completionHandler:^{
            
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:urlAsset];
            [playerItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:nil];
            [avPlayerItemsArray addObject:playerItem];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.queuePlayer insertItem:playerItem afterItem:nil];
            });
            
        }];
    }
    
    [self.queuePlayer pause];
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

-(void)displayTime:(double)milliseconds onLabel:(UILabel *)timeLabel {
    
    double seconds = milliseconds/1000;
    
    
    NSUInteger h = seconds / 3600;
    NSUInteger m = (int)(seconds / 60) % 60;
    NSUInteger s = (int)seconds % 60;
    
    
    
    NSString *result1 = [NSString stringWithFormat:@"%.2lu:%.2lu:%.2lu", (unsigned long)h, (unsigned long)m,(unsigned long)s];
    timeLabel.text = result1;
    
    //self.caloriesLabel.text = [NSString stringWithFormat:@"%.2f", ]
    
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
    timePassedInMilliSeconds += 10;
    //[self calculateCaloriesSinceSecondsPassed:timePassedInMilliSeconds * 0.001];
    [self displayTime:timeInMilliSeconds onLabel:self.durationLabel];
    if(timeInMilliSeconds <=0) {
        [self.queuePlayer pause];
        [timer invalidate];
    }
}

-(void)updateCurrentIntervalTimer:(NSTimer *)timer {
    currentIntervalInMilliSeconds = currentIntervalInMilliSeconds - 10;
    [self displayTime:currentIntervalInMilliSeconds onLabel:self.currentTimeIntervalLabel];
    
    if(currentIntervalInMilliSeconds <= 0){
        if(currentTimeIntervalIndex == timeIntervalsArray.count - 1){
            [timer invalidate];
        }
        else {
            currentTimeIntervalIndex +=1;
            TimeInterval *interval = timeIntervalsArray[currentTimeIntervalIndex];
            currentIntervalInMilliSeconds = ([interval.start doubleValue] * 60 * 1000);
            self.chart.animationDuration = 0;
            [self.chart reloadData];
            [self setNewBPMForSpeed];
            [self speakTimeInterval];
            self.queuePlayer.rate = currentSongRate;
            self.speedLabel.text = [NSString stringWithFormat:@"%.1f MPH",[interval.speed floatValue]];
            self.inclineLabel.text = [NSString stringWithFormat:@"%.1f%%",[interval.incline floatValue]];
        }
    }
    
    
}

-(void)calculateCaloriesSinceSecondsPassed:(double)seconds {
    
    double minutes = seconds / 60;
    double heightInInches = [[[NSUserDefaults standardUserDefaults] valueForKey:@"height"] doubleValue];
    double weightInPounds = 150;//[[[NSUserDefaults standardUserDefaults] valueForKey:@"weight"] doubleValue];
    double weightInKg = weightInPounds/2.2;
    TimeInterval *currentInterval = [timeIntervalsArray objectAtIndex:currentTimeIntervalIndex];
    double speedMinPerMins = [currentInterval.speed doubleValue] * 26.8;
    double incline = [currentInterval.incline doubleValue]/100;
    double x;
    if([currentInterval.speed doubleValue] < 3.7){
        x =  (0.1 * speedMinPerMins) + (1.8 * speedMinPerMins * incline) + 3.5;
    }
    else if([currentInterval.speed doubleValue] > 3.7){
        
        x =  (0.2 * speedMinPerMins) + (0.9 * speedMinPerMins * incline) + 3.5;
        
    }
    
    double calsPerMin = (x * weightInKg)/200;
    
    double totalCals = calsPerMin * minutes;
    self.caloriesBurned = self.caloriesBurned + totalCals;
    self.calorieLabel.text = [NSString stringWithFormat:@"%.1f", self.caloriesBurned];
}



-(void)setNewBPMForSpeed {
    
    TimeInterval *interval = timeIntervalsArray[currentTimeIntervalIndex];
    double newBPM = [Song lookUpBPMForSpeed:[interval.speed doubleValue] andWorkoutType:@"treadmill"];
    currentSongRate = newBPM / [currentPlayingSong.bpm doubleValue];
    self.queuePlayer.rate = currentSongRate;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    [self.queuePlayer advanceToNextItem];
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
            currentPlayingSong = song;
        self.songTitleLabel.text = song.songTitle;
            TimeInterval *current = [timeIntervalsArray objectAtIndex:currentTimeIntervalIndex];
        double newBPM = [Song lookUpBPMForSpeed:[current.speed doubleValue] andWorkoutType:@"treadmill"];
         currentSongRate = newBPM / [song.bpm doubleValue];
            NSLog(@"song: %@, rate: %@", song.songTitle, song.bpm);
            [self updateControlCenterNowPlayingDictionary];
        }

        if ([keyPath isEqualToString:@"status"])
        {   //yes->check it...
            switch(item.status)
            {
                case AVPlayerItemStatusFailed:
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    if ([self isPlayerPlaying]) {
                        self.queuePlayer.rate = currentSongRate;
                    }
                    break;
                case AVPlayerItemStatusUnknown:
                    break;

            }
            
            if(playerIsPlaying == YES){
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

-(void)updateControlCenterNowPlayingDictionary {
    NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];
    [nowPlayingInfo setObject:currentPlayingSong.songTitle forKey:MPMediaItemPropertyTitle];
    [nowPlayingInfo setObject:[NSNumber numberWithDouble:self.queuePlayer.rate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playPauseSelected:nil];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self previousSelected:nil];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self nextSelected:nil];
                break;
                
            default:
                break;
        }
    }
}

-(void)speakTimeInterval {
    if(self.voiceCoachingEnabled == YES){
    TimeInterval *current = [timeIntervalsArray objectAtIndex:currentTimeIntervalIndex];
    NSString *next = [NSString stringWithFormat:@"set your speed to %@ miles per hour,", current.speed];
    if(current.incline > 0 && [self.workout.machineType isEqualToString: @"treadmill"]){
        next = [next stringByAppendingString:[NSString stringWithFormat:@"and set your incline to  %@ percent", current.incline]];
    }
    utterance = [AVSpeechUtterance speechUtteranceWithString:next];
    utterance.rate = 0.2;
   // utterance.voice = [[AVSpeechSynthesisVoice speechVoices] objectAtIndex:3];
    [synth speakUtterance:utterance];
    }
    
}

- (IBAction)previousSelected:(id)sender {
    [self.queuePlayer playPreviousItemWithRate:currentSongRate];
    [self setNewBPMForSpeed];
    
}

- (IBAction)playPauseSelected:(id)sender {
    
    
    if(timerHasStarted == NO){
        self.playPauseButton.imageView.image = [UIImage imageNamed:@"pauseButton"];
        [self.playPauseButton setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
        totalWorkoutTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        currentIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentIntervalTimer:) userInfo:nil repeats:YES];
        timerHasStarted = YES;
        self.queuePlayer.rate = currentSongRate;
        [self speakTimeInterval];
        playerIsPlaying = YES;
    }
    else {
        timerHasStarted = NO;
        //self.playPauseButton.imageView.image = [UIImage imageNamed:@"playButton"];
        [self.playPauseButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        [totalWorkoutTimer invalidate];
        [currentIntervalTimer invalidate];
        [self.queuePlayer pause];
    }

    
}
- (IBAction)nextSelected:(id)sender {
    [self.queuePlayer advanceToNextItem];
    [self setNewBPMForSpeed];
    
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
     UINavigationController *navController = (UINavigationController *)[aStoryBoard instantiateViewControllerWithIdentifier:@"workoutNavController"];

    
    [self.queuePlayer pause];
    [self.queuePlayer removeObserver:self forKeyPath:@"status"];
    [self removeObserversFromQueuePlayer];
    self.queuePlayer = nil;
   [self presentViewController:navController.topViewController animated:YES completion:nil];
                                                          }];
    [alert addAction:stayAction];
    [alert addAction:exitAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)removeObserversFromQueuePlayer{
    for (AVPlayerItem *item in self.queuePlayer.items) {
        [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];

    }
    
}

-(void)dealloc{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

#pragma mark SimpleBarChartDataSource

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart
{
    return timeIntervalsArray.count;
}

- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
    TimeInterval *time = [timeIntervalsArray objectAtIndex:index];

    return [time.speed floatValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
    TimeInterval *time = [timeIntervalsArray objectAtIndex:index];
    return [NSString stringWithFormat:@"%.1f", [time.speed floatValue]];
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    if(index == currentTimeIntervalIndex && timeIntervalsArray.count > 1){
        self.chart.barTextColor = [UIColor blackColor];
        return [UIColor colorWithRed:0.000f green:0.627f blue:0.839f alpha:1.00f];
    }
    self.chart.barTextColor = [UIColor whiteColor];
    return (index % 2 == 0) ? [UIColor colorWithRed:0.659f green:0.333f blue:0.945f alpha:1.00f] : [UIColor colorWithRed:0.420f green:0.098f blue:0.486f alpha:1.00f];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
}


@end
