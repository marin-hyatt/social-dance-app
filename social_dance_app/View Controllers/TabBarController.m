//
//  TabBarController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "TabBarController.h"
#import "Parse/Parse.h"
#import "ProfileViewController.h"

@interface TabBarController () <UITabBarControllerDelegate>
@property PFUser *user;

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.user = [PFUser currentUser];
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    // Checks if profile tab has been selected
    if (tabBarController.selectedIndex == 3) {
        ProfileViewController *vc = (ProfileViewController*) [[(UINavigationController*)[[tabBarController viewControllers] objectAtIndex:3] viewControllers] objectAtIndex:0];
        vc.user = self.user;
    }
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
