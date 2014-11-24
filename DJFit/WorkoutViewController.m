//
//  WorkoutViewController.m
//  
//
//  Created by Taylor Ledingham on 2014-11-17.
//
//

#import "WorkoutViewController.h"

@interface WorkoutViewController ()

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    ProfileDetailsViewController *profileVC = [sb instantiateViewControllerWithIdentifier:@"profileDetails"];
//    
//    [self.navigationController pushViewController:profileVC animated:YES];
    self.title = @"My Workouts";
    
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

@end
