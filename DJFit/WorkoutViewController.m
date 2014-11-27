//
//  WorkoutViewController.m
//  
//
//  Created by Taylor Ledingham on 2014-11-17.
//
//

#import "WorkoutViewController.h"
#import "ProfileDetailsViewController.h"
#import "WorkoutsCollectionViewController.h"

@interface WorkoutViewController ()

@end

@implementation WorkoutViewController {
    WorkoutsCollectionViewController *  workoutCollectionView;
    UIBarButtonItem *done;
    UIBarButtonItem *edit;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"] == NO){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self askForProfileDetails];
        
    }
    self.title = @"My Workouts";

    edit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemEdit  target:self action:@selector(editButtonPressed:)];
    done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemDone  target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"gear"]  style:UIBarButtonItemStylePlain target:self action:@selector(gearButtonPressed:)];
     self.navigationItem.leftBarButtonItem = edit;
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
    if([segue.identifier isEqualToString:@"workoutCollectionView"]){
        workoutCollectionView = (WorkoutsCollectionViewController *)segue.destinationViewController;
        
        self.delegate = workoutCollectionView;
    }
    
}


-(void)askForProfileDetails {
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add details?"
                                                                   message:[NSString stringWithFormat: @"Would you like to add your information to enable calorie counting?"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * addAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           
                                                           
                                                           [self dismissViewControllerAnimated:alert completion:nil];
                                                           
                                                           ProfileDetailsViewController *profileController = [storyboard instantiateViewControllerWithIdentifier:@"profileDetails"];
                                                           [self presentViewController:profileController animated:YES completion:NULL];
                                                           
                                                       }];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"No, maybe later" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              [self  dismissViewControllerAnimated:alert completion:nil];
                                                              
                                                              
                                                          }];
    
    [alert addAction:addAction];
    [alert addAction:dismissAction];
    [self  presentViewController:alert animated:YES completion:nil];
    
}

-(void)editButtonPressed:(id)sender {
    [workoutCollectionView startEditing];
    self.navigationItem.leftBarButtonItem = done;
}

-(void)doneButtonPressed:(id)sender {
    [self.delegate doneEditing];
}

- (IBAction)gearButtonPressed:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    
    ProfileDetailsViewController *profileController = [storyboard instantiateViewControllerWithIdentifier:@"profileDetails"];
    [self presentViewController:profileController animated:YES completion:NULL];
    
    
}
@end
