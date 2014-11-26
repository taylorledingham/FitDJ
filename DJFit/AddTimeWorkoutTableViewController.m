//
//  AddTimeWorkoutTableViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-22.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "AddTimeWorkoutTableViewController.h"
#import "TLCoreDataStack.h"
#import "PlayWorkoutViewController.h"
#import "TimeInterval.h"
#import "MusicPickerViewController.h"

@interface AddTimeWorkoutTableViewController ()

@end

@implementation AddTimeWorkoutTableViewController {

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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cellTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnTimeCell:) ];
    timePanViewGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(timeDidPan:)];
    hideKeyBoardTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAnywhere:)];
    isCellExpanded = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemDone  target:self action:@selector(donePressed:)];
    [self setUpSlidersAndTexFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
-(void)setUpSlidersAndTexFields {
    
    
    self.inclineSlider.popUpViewCornerRadius = 12.0;
    [self.inclineSlider setMaxFractionDigitsDisplayed:0];
    self.inclineSlider.popUpViewColor = [UIColor colorWithRed:0.518f green:0.200f blue:0.678f alpha:1.00f];
    self.inclineSlider.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:20];
    self.inclineSlider.textColor = [UIColor whiteColor];
    self.speedTextField.delegate = self;
    self.workoutNameTextField.delegate = self;

    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0 && indexPath.section == 1){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        editingTimeCell = cell;
        [cell addGestureRecognizer:cellTapGesture];
        isCellExpanded = YES;
        if(timeViewCreated == NO){
            timeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 50)];
            timeView.backgroundColor = [UIColor colorWithRed:0.553f green:0.235f blue:0.749f alpha:1.00f];
            timeSliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.center.x-10, 0, cell.frame.size.width, 50)];
            timeSliderLabel.textColor = [UIColor whiteColor];
            timeSliderLabel.text = @"00:00";
            timeSliderLabel.font = [UIFont fontWithName:@"system" size:25];
            [timeView addSubview:timeSliderLabel];
            [timeView addGestureRecognizer:timePanViewGesture];
            [cell addSubview:timeView];
            cellOrigin = timeView.frame.origin;
            timeViewCreated = YES;
            editingTimeCellIndexPath = indexPath;
            
            self.durationLabel.hidden = NO;
            self.workoutTimeLabel.hidden = NO;
        }
        
        
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    
    
}



-(void)didTapOnTimeCell:(UITapGestureRecognizer*)gesture{
    
    isCellExpanded = NO;
    timeViewCreated = NO;
    self.workoutTimeLabel.text = timeSliderLabel.text;
    [gesture.view removeGestureRecognizer:gesture];
    [gesture.view removeGestureRecognizer:timePanViewGesture];
    [timeView removeFromSuperview];
    [timeSliderLabel removeFromSuperview];
    editingTimeCell = nil;
    editingTimeCellIndexPath = nil;
    self.durationLabel.hidden = NO;
    self.workoutTimeLabel.hidden = NO;
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
    
    timeSliderLabel.text = [NSString stringWithFormat:@"%.2f", rounded];
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        return  60.0;
    }
    
    else if (indexPath.section == 1){
        if(indexPath.row == 0){
            if(isCellExpanded && editingTimeCellIndexPath.section==indexPath.section){
                return 400;
            }
            return  60.0;
            
        }
        else if (indexPath.row == 1){
            return  75.0;
            
        }
        else if(indexPath.row == 2){
            return 90;
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

- (IBAction)donePressed:(id)sender {
    
    [self saveWorkout];
    MusicPickerViewController *musicVC = [[MusicPickerViewController alloc]init];
    musicVC.workout = workout;
    [self.navigationController pushViewController:musicVC animated:YES];
    
    
}

-(void)saveWorkout {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    double workoutDuration=0;
    NSMutableArray *timeIntervalArray = [[NSMutableArray alloc]init];
    
    workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:coreDataStack.managedObjectContext];
    workout.workoutName = self.workoutNameTextField.text;
    workout.workoutType = @"timed";
    workout.numberOfRounds = @1;
    workout.dateCreated = [NSDate date];
    workout.machineType = @"treadmill";
    NSInteger index = 0;
    
    TimeInterval *warmUpTimeInterval = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
    float time = [self.workoutTimeLabel.text floatValue ];
    float speed = [self.speedTextField.text floatValue];
    float rounded = self.inclineSlider.value < 0.5f ? 0.5f : floorf(self.inclineSlider.value * 2) / 2;
    warmUpTimeInterval.incline = [NSNumber numberWithFloat: rounded];
    warmUpTimeInterval.speed = [NSNumber numberWithFloat:speed];
    warmUpTimeInterval.start = [NSNumber numberWithFloat: time] ;
    warmUpTimeInterval.workout = workout;
    warmUpTimeInterval.index = [NSNumber numberWithInteger:index];
    index += 1;
    workoutDuration += time;
    [timeIntervalArray addObject:warmUpTimeInterval];

    
    workout.workoutDuration = [NSNumber numberWithDouble: workoutDuration];
    workout.timeIntervals = [[NSSet alloc]initWithArray:timeIntervalArray];
    
    [coreDataStack saveContext];
    
    
    
}





@end

