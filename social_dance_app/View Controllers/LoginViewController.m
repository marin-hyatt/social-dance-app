//
//  LoginViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "LoginViewController.h"
#import "LoginView.h"
#import "Parse/Parse.h"
#import "UIManager.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet LoginView *loginView;

@end

@implementation LoginViewController

- (IBAction)signUpPressed:(id)sender {
    [self registerUser];
}

- (IBAction)loginPressed:(id)sender {
    [self loginUser];
}

- (void)registerUser {
    if ([self.loginView.usernameField.text isEqual:@""]) {
        [UIManager presentAlertWithMessage:@"Username cannot be empty." overViewController:self];
    }
    
    if ([self.loginView.passwordField.text isEqual:@""]) {
        [UIManager presentAlertWithMessage:@"Password cannot be empty." overViewController:self];
    }
    
    PFUser *newUser = [PFUser user];
    
    newUser.username = self.loginView.usernameField.text;
    newUser.password = self.loginView.passwordField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self];
        } else {
            [self performSegueWithIdentifier:@"SpotifyAuthViewController" sender:nil];
        }
    }];
}


- (void)loginUser {
    if ([self.loginView.usernameField.text isEqual:@""]) {
        [UIManager presentAlertWithMessage:@"Username cannot be empty." overViewController:self];
    }
    
    if ([self.loginView.passwordField.text isEqual:@""]) {
        [UIManager presentAlertWithMessage:@"Password cannot be empty." overViewController:self];
    }
    
    NSString *username = self.loginView.usernameField.text;
    NSString *password = self.loginView.passwordField.text;
    
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self];
        } else {
            [self performSegueWithIdentifier:@"SpotifyAuthViewController" sender:nil];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
