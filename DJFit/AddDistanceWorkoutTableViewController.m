//
//  AddDistanceWorkoutTableViewController.m
//  DJFit
//
//  Created by Taylor Ledingham on 2014-11-25.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "AddDistanceWorkoutTableViewController.h"
#import "TLCoreDataStack.h"
#import "PlayWorkoutViewController.h"
#import "TimeInterval.h"
#import "MusicPickerViewController.h"


@interface AddDistanceWorkoutTableViewController ()

@end

@implementation AddDistanceWorkoutTableViewController {
    
    Workout *workout;
    UITapGestureRecognizer *cellTapGesture;
    UIPanGestureRecognizer *timePanViewGesture;
    UITapGestureRecognizer *hideKeyBoardTapGesture;
    BOOL isCellExpanded;
    UILabel *distanceSliderLabel;
    UIView *distanceView;
    UITableViewCell *editingDistanceCell;
    NSIndexPath *editingDistanceCellIndexPath;
    BOOL distanceViewCreated;
    CGPoint cellOrigin;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cellTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnTimeCell:) ];
    timePanViewGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(timeDidPan:)];
    hideKeyBoardTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAnywhere:)];
    isCellExpanded = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
    [self setUpSlidersAndTexFields];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpSlidersAndTexFields {
    
    
    self.inclineSlider.popUpViewCornerRadius = 12.0;
    [self.inclineSlider setMaxFractionDigitsDisplayed:1];
    self.inclineSlider.popUpViewColor = [UIColor colorWithRed:0.518f green:0.200f blue:0.678f alpha:1.00f];
    self.inclineSlider.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:20];
    self.inclineSlider.textColor = [UIColor whiteColor];
    self.speedTextField.delegate = self;
    self.workoutNameTextField.delegate = self;
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 1 && indexPath.section == 1){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        editingDistanceCell = cell;
        [cell addGestureRecognizer:cellTapGesture];
        isCellExpanded = YES;
        if(distanceViewCreated == NO){
            distanceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 60)];
            distanceView.backgroundColor = [UIColor colorWithRed:0.553f green:0.235f blue:0.749f alpha:1.00f];
            distanceView.layer.cornerRadius = 6.0;
            distanceSliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 60)];
            distanceSliderLabel.textColor = [UIColor whiteColor];
            distanceSliderLabel.text = @"▼    00:00    ▲";
            distanceSliderLabel.textAlignment = NSTextAlignmentCenter;
            distanceSliderLabel.font = [UIFont systemFontOfSize:20];
            [distanceView addSubview:distanceSliderLabel];
            [distanceView addGestureRecognizer:timePanViewGesture];
            [cell addSubview:distanceView];
            cellOrigin = distanceView.frame.origin;
            distanceViewCreated = YES;
            editingDistanceCellIndexPath = indexPath;
            self.distanceLabel.hidden = YES;
            self.distanceInputLabel.hidden = YES;
        }
        
        
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    
    
}



-(void)didTapOnTimeCell:(UITapGestureRecognizer*)gesture{
    
    isCellExpanded = NO;
    distanceViewCreated = NO;
    NSString *distance = [distanceSliderLabel.text substringWithRange:NSMakeRange(5, 4)];
    self.distanceInputLabel.text = distance;
    [gesture.view removeGestureRecognizer:gesture];
    [gesture.view removeGestureRecognizer:timePanViewGesture];
    [distanceView removeFromSuperview];
    [distanceSliderLabel removeFromSuperview];
    editingDistanceCell = nil;
    editingDistanceCellIndexPath = nil;
    self.distanceInputLabel.hidden = NO;
    self.distanceLabel.hidden = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    
}

-(void)timeDidPan:(UIPanGestureRecognizer *)gesture {
    float elevation = [gesture locationInView:gesture.view.superview].y;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            if(elevation <= 25.0){
                gesture.view.center = CGPointMake(gesture.view.center.x, cellOrigin.y+25.0);
            } else if(elevation <= 375.00){
                gesture.view.center = CGPointMake(gesture.view.center.x, [gesture locationInView:gesture.view.superview].y);
            } else if(elevation > 375.0){
                gesture.view.center = CGPointMake(gesture.view.center.x, 375);
            }
            break;
        case UIGestureRecognizerStateEnded:
            break;
            
        default:
            break;
    }
    
    float timeVal = gesture.view.center.y/20 - 1.5;
    float rounded = timeVal < 0.2f ? 0.2f : floorf(timeVal * 2) / 2;

    distanceSliderLabel.text = [NSString stringWithFormat:@"▼    %.2f    ▲", rounded];
    
    
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
        return  60.0;
    }
    
    else if (indexPath.section == 1){
        if (indexPath.row == 0){
            return  60.0;
            
        }
        else if(indexPath.row == 1){
            if(isCellExpanded && editingDistanceCellIndexPath.section==indexPath.section){
                return 400;
            }
            return  60.0;
            
        }

        else if(indexPath.row == 2){
            return 70;
        }
        else if (indexPath.row == 3){
            return 80.0;
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
    BOOL emptyReqFields = NO;
    NSMutableArray *errorMessages = [[NSMutableArray alloc]init];
    if([self.speedTextField.text isEqualToString:@""] ){
        [errorMessages addObject:@"Speed"];
         emptyReqFields = YES;
    }
    if([self.distanceInputLabel.text isEqualToString:@""] || [self.distanceInputLabel.text isEqualToString:@"0.00"]){
        [errorMessages addObject:@"Distance"];
        emptyReqFields = YES;
    }
    if(emptyReqFields == YES){
        NSString *errorString = @"Please enter in the following fields: ";
        for (NSString *str in errorMessages) {
            errorString = [errorString stringByAppendingString:[NSString stringWithFormat:@"▪️%@ \n", str]];
            
        }
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error - Missing Fields"
                                                                       message: errorString
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * keepAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                
                                                                
                                                            }];
        
        
        [alert addAction:keepAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else {
    [self saveWorkout];
    MusicPickerViewController *musicVC = [[MusicPickerViewController alloc]init];
    musicVC.workout = workout;
    [self.navigationController pushViewController:musicVC animated:YES];
    }
    
    
}

-(void)saveWorkout {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    double workoutDuration=0;
    NSMutableArray *timeIntervalArray = [[NSMutableArray alloc]init];
    
    workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:coreDataStack.managedObjectContext];
    workout.workoutName = self.workoutNameTextField.text;
    workout.workoutType = kDistanceWorkout;
    workout.numberOfRounds = @1;
    workout.dateCreated = [NSDate date];
    workout.machineType = kTypeTreadmill;
    NSInteger index = 0;
    
    TimeInterval *warmUpTimeInterval = [NSEntityDescription insertNewObjectForEntityForName:@"TimeInterval" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    float speed = [self.speedTextField.text floatValue];
    float roundedSpeed = speed < 0.5f ? 0.5f : floorf(speed * 2) / 2;

    float time = ([self getConvertedDistance] / speed)*60;

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


-(float)getConvertedDistance {
    if([self.distanceUnitsSegmentControl selectedSegmentIndex]  == 0){
        return [self.distanceInputLabel.text floatValue] * 0.621371;
    }
    else {
        return [self.distanceInputLabel.text floatValue];
    }
}


- (IBAction)distanceUnitsChanged:(id)sender {
}
@end
