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

@end



@implementation PlayWorkoutViewController {
    NSTimeInterval workoutDuration;
    NSDateFormatter *dateFormatter;
    UIGestureRecognizer *tapGesture;
    BOOL musicPicked;
    double timeInMilliSeconds;
    double currentIntervalInMilliSeconds;
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
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    timeInMilliSeconds = ([self.workout.workoutDuration doubleValue] * 60 * 1000);
    TimeInterval *firstinterval = timeIntervalsArray[0];
    currentIntervalInMilliSeconds = ([firstinterval.start doubleValue] * 60 * 1000);
     formatter = [[NSNumberFormatter alloc] init];
    timerHasStarted = NO;
    playerIsPlaying = NO;
    avPlayerItemsArray = [[NSMutableArray alloc]init];
    self.queuePlayer = [[AVQueuePlayerPrevious alloc]initWithItems:avPlayerItemsArray];
    [self.queuePlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self displayTime:timeInMilliSeconds onLabel:self.durationLabel];
    [self loadPlaylist];
    timeIntervalsArray = [[NSArray alloc]init];
    timeIntervalsArray = [self.workout.timeIntervals allObjects];
    [self sortTimeIntervalArray];
    currentSongRate = 1.0;
    currentTimeIntervalIndex = 0;
    [self setUpGraph];
    //MusicPickerViewController *musicPickerVC = [[MusicPickerViewController alloc]init];
    //[self presentViewController:musicPickerVC animated:NO completion:nil];
    [self setWorkoutDetails];
    NSLog(@"playlist: %@", self.workout.playlist.playlistName);
    
    
    
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
    
    self.chart = [[SimpleBarChart alloc]initWithFrame:CGRectMake(0, 0, self.barChartView.frame.size.width, 150)];
    [self.barChartView addSubview:self.chart];
    
    self.chart.delegate = self;
    self.chart.dataSource = self;
    self.chart.backgroundColor = [UIColor colorWithRed:0.847f green:0.847f blue:0.847f alpha:1.00f];
    self.chart.gridColor = [UIColor colorWithRed:0.847f green:0.847f blue:0.847f alpha:1.00f];
    self.chart.barWidth	= 18.0;
    self.chart.incrementValue = 1;
    [self.chart reloadData];
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

-(void)calculateCalories {
    
    
    
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
    
   // self.speedLabel.text = [NSString stringWithFormat:@"Speed: 8.0MPH"];
    //self.inclineLabel.text = [NSString stringWithFormat:@"Incline: 0%%"];
    
    
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
            double newBPM = [Song lookUpBPMForSpeed:[interval.speed doubleValue] andWorkoutType:@"treadmill"];
            currentSongRate = newBPM / [currentPlayingSong.bpm doubleValue];
            self.queuePlayer.rate = currentSongRate;
            self.speedLabel.text = [NSString stringWithFormat:@"%.1f MPH",[interval.speed floatValue]];
            self.inclineLabel.text = [NSString stringWithFormat:@"%.1f%%",[interval.incline floatValue]];
        }
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
    
    
   
    
}

-(void)setNewBPMForSpeed:(double)speed {
    
    
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
    
    
    if(timerHasStarted == NO){
        self.playPauseButton.imageView.image = [UIImage imageNamed:@"pauseButton"];
        [self.playPauseButton setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
        totalWorkoutTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        currentIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentIntervalTimer:) userInfo:nil repeats:YES];
        timerHasStarted = YES;
        self.queuePlayer.rate = currentSongRate;
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
    [self.queuePlayer removeObserver:self forKeyPath:@"status"];
    [self removeObserversFromQueuePlayer];
    self.queuePlayer = nil;
    [self presentViewController:controller animated:YES completion:nil];
                                                              }];
    
    [alert addAction:stayAction];
    [alert addAction:exitAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)removeObserversFromQueuePlayer{
    for (AVPlayerItem *item in self.queuePlayer.items) {
        [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
        [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(playbackBufferEmpty))];

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
    return [time.speed stringValue];
}

//- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index
//{
//    TimeInterval *time = [timeIntervalsArray objectAtIndex:index];
//    return [time.start stringValue];
//}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    if(index == currentTimeIntervalIndex){
        return [UIColor colorWithRed:0.443f green:0.835f blue:0.969f alpha:1.00f];
    }
    return (index % 2 == 0) ? [UIColor colorWithRed:0.659f green:0.333f blue:0.945f alpha:1.00f] : [UIColor colorWithRed:0.420f green:0.098f blue:0.486f alpha:1.00f];

}
#pragma mark - JBBarChartViewDelegate

//- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
//{
//    TimeInterval *time = [timeIntervalsArray objectAtIndex:index];
//    return [ time.speed floatValue];
//}
//
//- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
//{
//    return (index % 2 == 0) ? [UIColor colorWithRed:0.659f green:0.333f blue:0.945f alpha:1.00f] : [UIColor colorWithRed:0.420f green:0.098f blue:0.486f alpha:1.00f];
//}
//
//- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
//{
//    return [UIColor whiteColor];
//}
//
//- (CGFloat)barPaddingForBarChartView:(JBBarChartView *)barChartView
//{
//    return 5.0;
//}


@end
