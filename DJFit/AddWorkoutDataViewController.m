//
//  AddWorkoutDataViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-17.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "AddWorkoutDataViewController.h"
#import "TLCoreDataStack.h"
#import "PlayWorkoutViewController.h"
#import "TimeInterval.h"
#import "MusicPickerViewController.h"

typedef enum : NSInteger {
    warmUpSection = 2,
    lowSection = 3,
    highSection = 4,
    coolDownSection = 5
} sectionTags;

typedef enum : NSInteger {
    warmUpIndex = 0,
    lowIndex = 1,
    highIndex = 2,
    coolDownIndex = 3
} sectionIndex;
@interface AddWorkoutDataViewController ()

#define normalCellHeight 60.0
#define roundCellHeight 120.0

@end

@implementation AddWorkoutDataViewController {
    
    Workout *workout;
    UITapGestureRecognizer *cellTapGesture;
    UIPanGestureRecognizer *timePanViewGesture;
    UITapGestureRecognizer *hideKeyBoardTapGesture;
    BOOL isCellExpanded;
    UILabel *timeSliderLabel;
    UIView *timeView;
    UITableViewCell *editingTimeCell;
    NSIndexPath *editingTimeCellIndexPath;
    BOOL timeViewCreated;
    CGPoint cellOrigin;
    CGPoint translation;
    NSArray *sectionArray;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    self.workoutNameTextField.delegate = self;
    [self setUpSliders];
    //self.view.backgroundColor = [UIColor colorWithRed:0.659f green:0.333f blue:0.945f alpha:1.00f];
    timeSliderLabel = [[UILabel alloc]init];
    timeViewCreated = NO;
    sectionArray = [[NSArray alloc]initWithObjects: @(warmUpSection),@(lowSection), @(highSection), @(coolDownSection), nil];
    
    cellTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnTimeCell:) ];
    timePanViewGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(timeDidPan:)];
    hideKeyBoardTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAnywhere:)];
    isCellExpanded = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
    
}


-(void)setUpSliders {
    
    self.numberOfRoundsSlider.popUpViewCornerRadius = 12.0;
    [self.numberOfRoundsSlider setMaxFractionDigitsDisplayed:0];
    self.numberOfRoundsSlider.popUpViewColor = [UIColor colorWithRed:0.518f green:0.200f blue:0.678f alpha:1.00f];
    self.numberOfRoundsSlider.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:28];
    self.numberOfRoundsSlider.textColor = [UIColor whiteColor];
  
    for (ASValueTrackingSlider *slider in self.inclineSliders) {
        slider.popUpViewCornerRadius = 12.0;
        [slider setMaxFractionDigitsDisplayed:0];
        slider.popUpViewColor = [UIColor colorWithRed:0.518f green:0.200f blue:0.678f alpha:1.00f];
        slider.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:20];
        slider.textColor = [UIColor whiteColor];
        
        }
    
        for (UITextField *field in self.speedTextField) {
            field.delegate = self;
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
    if([segue.identifier isEqualToString:@"startWorkout"]){
        
        PlayWorkoutViewController *playVC = (PlayWorkoutViewController *)segue.destinationViewController;
        playVC.view.alpha = 0.5;
        playVC.startWorkoutButton.alpha = 1.0;
        playVC.workout = workout;
        [playVC.navigationController setNavigationBarHidden:YES animated:YES];
        
        
    }
    
    else if ([segue.identifier isEqualToString:@"showMusicPicker"]){
        MusicPickerViewController *musicVC = (MusicPickerViewController *)segue.destinationViewController;
        musicVC.workout = workout;
        
        
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.row == 0 && [sectionArray containsObject:@(indexPath.section)]){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        editingTimeCell = cell;
        [cell addGestureRecognizer:cellTapGesture];
        isCellExpanded = YES;
        if(timeViewCreated == NO){
        timeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 60)];
        timeView.backgroundColor = [UIColor colorWithRed:0.553f green:0.235f blue:0.749f alpha:1.00f];
            timeView.layer.cornerRadius = 6.0;
            timeSliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 60)];
            timeSliderLabel.textColor = [UIColor whiteColor];
            timeSliderLabel.textAlignment = NSTextAlignmentCenter;
            timeSliderLabel.text = @"▼    00:00    ▲";
            timeSliderLabel.font = [UIFont systemFontOfSize:20];
        [timeView addSubview:timeSliderLabel];
        [timeView addGestureRecognizer:timePanViewGesture];
        [cell addSubview:timeView];
        cellOrigin = timeView.frame.origin;
            timeViewCreated = YES;
            editingTimeCellIndexPath = indexPath;
        
        UILabel *time = [self getTimeLabelByTag:[self getIndexForSectionIndex:editingTimeCellIndexPath.section]];
        UILabel *timeText = [self getTimeTextLabelByTag:[self getIndexForSectionIndex:editingTimeCellIndexPath.section]+4];
            time.hidden = YES;
            timeText.hidden = YES;
        }
        

    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];


    
}

-(NSUInteger)getIndexForSectionIndex:(NSInteger)secIndex{
    
    switch (secIndex) {
        case warmUpSection:
            return warmUpIndex;
            break;
         case lowSection:
            return lowIndex;
            break;
        case highSection:
            return highIndex;
            break;
        case coolDownSection:
            return coolDownIndex;
            break;
        default:
            return 0;
            break;
    }
    
    
}

-(void)didTapOnTimeCell:(UITapGestureRecognizer*)gesture{
        
    isCellExpanded = NO;
    timeViewCreated = NO;
    NSInteger timeLabelIndex = [self getIndexForSectionIndex:editingTimeCellIndexPath.section];
    UILabel *timeCellLabel = [self getTimeLabelByTag:timeLabelIndex];
    NSString *time = [timeSliderLabel.text substringWithRange:NSMakeRange(5, 4)];
    timeCellLabel.text = time;
    [gesture.view removeGestureRecognizer:gesture];
    [gesture.view removeGestureRecognizer:timePanViewGesture];
    [timeView removeFromSuperview];
    [timeSliderLabel removeFromSuperview];
    editingTimeCell = nil;
    editingTimeCellIndexPath = nil;
    UILabel *timeText = [self getTimeTextLabelByTag:timeLabelIndex+4];
    timeCellLabel.hidden = NO;
    timeText.hidden = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    
}

-(void)timeDidPan:(UIPanGestureRecognizer *)gesture {
        float elevation = [gesture locationInView:gesture.view.superview].y;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"changed: %f", elevation);
            if(elevation <= 25.0){
                gesture.view.center = CGPointMake(gesture.view.center.x, cellOrigin.y+25.0);
            } else if(elevation <= 375.00){
                NSLog(@"[gesture locationInView:gesture.view]: %f", [gesture locationInView:gesture.view.superview].y);
                gesture.view.center = CGPointMake(gesture.view.center.x, [gesture locationInView:gesture.view.superview].y);
            } else if(elevation > 375.0){
                gesture.view.center = CGPointMake(gesture.view.center.x, 375);
            }
            break;
        case UIGestureRecognizerStateEnded:
            
            //[gesture setTranslation:CGPointMake(0, 0) inView:editingTimeCell];
            break;

        default:
            NSAssert(NO, @"handle this later...");
            break;
    }
    
    float timeVal = gesture.view.center.y/20 - 1.5;
    float rounded = timeVal < 0.5f ? 0.5f : floorf(timeVal * 2) / 2;
    NSLog(@"%f", fmodf(rounded, 1.0));
    if(fmodf(rounded, 1.0) > 0){
        rounded = rounded - 0.20;
    }
    timeSliderLabel.text = [NSString stringWithFormat:@"▼    %.2f    ▲", rounded];


}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{

    UITableViewHeaderFooterView *headerIndexText = (UITableViewHeaderFooterView *)view;
    [headerIndexText.textLabel setTextColor:[UIColor colorWithRed:0.498f green:0.180f blue:0.635f alpha:1.00f]];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        return  normalCellHeight;
    }
    
    else if (indexPath.section == 1){
            return 117;
    }
    
    else if([sectionArray containsObject:@(indexPath.section)]){
        if(indexPath.row == 0){
            if(isCellExpanded && editingTimeCellIndexPath.section==indexPath.section){
                return 400;
            }
            return  normalCellHeight;
            
        }
        else if (indexPath.row == 1){
            return  75.0;
            
        }
        else if(indexPath.row == 2){
            return 100;
        }
        else {

            return 60.0;
        }
    }
    
    
    return 60;
}

#pragma mark - text field delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // do whatever you have to do
    [textField resignFirstResponder];
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view addGestureRecognizer:hideKeyBoardTapGesture];
    
}

-(void)didTapAnywhere:(UITapGestureRecognizer *)gesture {
    
    [gesture.view removeGestureRecognizer:gesture];
    [self.tableView endEditing:YES];
}

- (IBAction)speedTextViewDidBeginEditing:(id)sender {
}



- (IBAction)donePressed:(id)sender {
    
    [self saveWorkout];
    
    MusicPickerViewController *musicVC = [[MusicPickerViewController alloc]init];
    musicVC.workout = workout;
    
    [self.navigationController pushViewController:musicVC animated:YES];

    
}

-(UILabel *)getTimeLabelByTag:(NSInteger)tag {
    
    NSPredicate *timeTagPredicate = [NSPredicate predicateWithFormat:@"tag = %@", @(tag)];
    NSArray *result = [self.cellTimeLabel filteredArrayUsingPredicate:timeTagPredicate];
    return result.firstObject;
}

-(UILabel *)getTimeTextLabelByTag:(NSInteger)tag {
    
    NSPredicate *timeTagPredicate = [NSPredicate predicateWithFormat:@"tag = %@", @(tag)];
    NSArray *result = [self.cellTimeTextLabel filteredArrayUsingPredicate:timeTagPredicate];
    return result.firstObject;
}

-(UITextField *)getSpeedTextFieldByTag:(NSInteger)tag {
    
    NSPredicate *speedTagPredicate = [NSPredicate predicateWithFormat:@"tag = %@", @(tag)];
    NSArray *result = [self.speedTextField filteredArrayUsingPredicate:speedTagPredicate];
    return result.firstObject;
}

-(ASValueTrackingSlider *)getInclineSliderByTag:(NSInteger)tag {
    
    NSPredicate *inclineTagPredicate = [NSPredicate predicateWithFormat:@"tag = %@", @(tag)];
    NSArray *result = [self.inclineSliders filteredArrayUsingPredicate:inclineTagPredicate];
    return result.firstObject;
}


-(void)saveWorkout {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    double workoutDuration=0;
    NSMutableArray *timeIntervalArray = [[NSMutableArray alloc]init];
    
    workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:coreDataStack.managedObjectContext];
    workout.workoutName = self.workoutNameTextField.text;
    workout.workoutType = @"interval";
    workout.numberOfRounds = [NSNumber numberWithFloat: self.numberOfRoundsSlider.value];
    workout.dateCreated = [NSDate date];
    workout.machineType = @"treadmill";
    NSInteger index = 0;

    TimeInterval *warmUpTimeInterval = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
       float time = [[self getTimeLabelByTag:0].text floatValue ];
       float speed = [[self getSpeedTextFieldByTag:0].text floatValue];
       float rounded = [self getInclineSliderByTag:0].value < 0.5f ? 0.5f : floorf([self getInclineSliderByTag:0].value * 2) / 2;
        warmUpTimeInterval.incline = [NSNumber numberWithFloat: rounded];
        warmUpTimeInterval.speed = [NSNumber numberWithFloat:speed];
        warmUpTimeInterval.start = [NSNumber numberWithFloat: time] ;
        warmUpTimeInterval.workout = workout;
        warmUpTimeInterval.index = [NSNumber numberWithInteger:index];
        index += 1;
        workoutDuration += time;
        [timeIntervalArray addObject:warmUpTimeInterval];
    
    for (int i=0; i<[workout.numberOfRounds intValue]; i++) {
        
        TimeInterval *lowTimeInterval = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
        time = [[self getTimeLabelByTag:1].text floatValue ];
        speed = [[self getSpeedTextFieldByTag:1].text floatValue];
        
        rounded = [self getInclineSliderByTag:1].value < 0.5f ? 0.5f : floorf([self getInclineSliderByTag:1].value * 2) / 2;
        lowTimeInterval.incline = [NSNumber numberWithFloat: rounded];
        lowTimeInterval.speed = [NSNumber numberWithFloat:speed];
        lowTimeInterval.start = [NSNumber numberWithFloat: time] ;
        lowTimeInterval.workout = workout;
        lowTimeInterval.index = [NSNumber numberWithInteger:index];
        index += 1;
        workoutDuration += time;
        
        [timeIntervalArray addObject:lowTimeInterval];
        
        TimeInterval *highTimeInterval = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
        time = [[self getTimeLabelByTag:2].text floatValue ];
        speed = [[self getSpeedTextFieldByTag:2].text floatValue];
        rounded = [self getInclineSliderByTag:2].value < 0.5f ? 0.5f : floorf([self getInclineSliderByTag:2].value * 2) / 2;
        highTimeInterval.incline = [NSNumber numberWithFloat: rounded];
        highTimeInterval.speed = [NSNumber numberWithFloat:speed];
        highTimeInterval.start = [NSNumber numberWithFloat: time] ;
        highTimeInterval.workout = workout;
        workoutDuration += time;
        highTimeInterval.index = [NSNumber numberWithInteger:index];
        index += 1;
        
        [timeIntervalArray addObject:highTimeInterval];
    }

    
    TimeInterval *coolDownTimeInterval = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
    time = [[self getTimeLabelByTag:3].text floatValue ];
    speed = [[self getSpeedTextFieldByTag:3].text floatValue];
    rounded = [self getInclineSliderByTag:1].value < 0.5f ? 0.5f : floorf([self getInclineSliderByTag:3].value * 2) / 2;
    coolDownTimeInterval.incline = [NSNumber numberWithFloat: rounded];
    coolDownTimeInterval.speed = [NSNumber numberWithFloat:speed];
    coolDownTimeInterval.start = [NSNumber numberWithFloat: time] ;
    coolDownTimeInterval.workout = workout;
    workoutDuration += time;
    coolDownTimeInterval.index = [NSNumber numberWithInteger:index];
    index += 1;
    
    workout.workoutDuration = [NSNumber numberWithDouble: workoutDuration];
    [timeIntervalArray addObject:coolDownTimeInterval];
    workout.timeIntervals = [[NSSet alloc]initWithArray:timeIntervalArray];
    
    [coreDataStack saveContext];

    
    
}

@end
