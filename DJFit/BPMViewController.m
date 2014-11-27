//
//  BPMViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-26.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "BPMViewController.h"
#import "TLCoreDataStack.h"

@interface BPMViewController ()

@end

@implementation BPMViewController {
    AVPlayer *player;
    NSTimeInterval *timeTapped;
    int count;
    double msecsFirst;
    double msecsPrevious;
    double bpmAvg;
    BOOL playerIsPlaying;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bpmPickerView.delegate = self;
    self.bpmPickerView.dataSource = self;
    count = 0;
    msecsFirst = 0;
    msecsPrevious = 0;
    
    player = [[AVPlayer alloc]init];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemSave  target:self action:@selector(savePressed:)];
    

    
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadAvPlayer];

}

-(void)loadAvPlayer {
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString: self.song.songURL] options:nil];
    
    NSArray *keyArray = [[NSArray alloc] initWithObjects:@"tracks", nil];
    
    [urlAsset loadValuesAsynchronouslyForKeys:keyArray completionHandler:^{
        
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:urlAsset];
        player = [player initWithPlayerItem:playerItem];
    }];

}

-(void)viewWillDisappear:(BOOL)animated {
    [player pause];
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

#pragma mark - UIPickerView Delegate and data source methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 250;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld BPM",(long)row];
}


- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
}

-(void)calculateBPM {
    
    NSTimeInterval seconds = [NSDate timeIntervalSinceReferenceDate];
   double msecs = seconds*1000;
  
    if ((msecs - msecsPrevious) > 1000 )
    {
        count = 0;
    }
    
    if (count == 0)
    {
        msecsFirst = msecs;
        count = 1;
    }
    else
    {
        bpmAvg = 60000 * count / (msecs - msecsFirst);
        bpmAvg = (bpmAvg +  [self.song.bpm doubleValue]) / 2;
       // double roundedNumber = ceil(bpmAvg/3);
        int roundedNumber = (bpmAvg + 0.5);
        count++;
        [self.bpmPickerView selectRow:(NSInteger)roundedNumber inComponent:0 animated:YES];
    }
    msecsPrevious = msecs;
    
}

-(void)savePressed:(id)sender {
    
   TLCoreDataStack *coreDataStack =  [TLCoreDataStack defaultStack];
    self.song.bpm = [NSNumber numberWithInteger: [self.bpmPickerView selectedRowInComponent:0]];
    [coreDataStack saveContext];
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)tapButtonTouchedDown:(id)sender {
    [self calculateBPM];
}

- (IBAction)playButtonPressed:(id)sender {
    [player play];
}

- (IBAction)tapButtonPressed:(id)sender {
   // [self calculateBPM];
}
@end
