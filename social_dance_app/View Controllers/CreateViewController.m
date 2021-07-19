//
//  CreateViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "CreateViewController.h"
#import "CreateView.h"
#import "Song.h"
#import "Parse/Parse.h"
#import "Post.h"
#import "APIManager.h"
#import "SpotifySearchViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface CreateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SpotifySearchDelegate>
@property (strong, nonatomic) IBOutlet CreateView *createView;
@property (strong, nonatomic) PFFileObject *videoFile;
@property (strong, nonatomic) Song *chosenSong;


@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onRecordVideoPressed:(UIButton *)sender {
    [self showImagePicker:YES];
}

- (IBAction)onChooseVideoPressed:(UIButton *)sender {
    [self showImagePicker:NO];
}

- (IBAction)onChooseSongPressed:(id)sender {
//    [[APIManager shared] openSpotify];
//    [[APIManager shared] getAccessToken];
//    NSLog(@"Access token: %@", [[APIManager shared] accessToken]);
    [self performSegueWithIdentifier:@"SpotifySearchViewController" sender:nil];
    
//    if ([[APIManager shared] shouldRefreshToken]) {
//        [self performSegueWithIdentifier:@"SpotifyAuthViewController" sender:nil];
//    } else {
//        [self performSegueWithIdentifier:@"SpotifySearchViewController" sender:nil];
//    }

    
    
}

- (IBAction)onPostPressed:(UIBarButtonItem *)sender {
    NSString *caption = self.createView.captionField.text;
    
    // TODO: add spotify functionality, for now Song object is nil
    Song *song = self.chosenSong;

    
    // Post video to backend
    [Post postUserVideo:self.videoFile withCaption:caption withSong:song withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error! %@", error.localizedDescription);
        } else {
            NSLog(@"Video posted!");
        }
    }];
    
    // Switches to root view controller
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // grab our movie URL
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"%@", chosenMovie);
    
    NSData *videoData = [NSData dataWithContentsOfURL:chosenMovie];
    self.videoFile = [PFFileObject fileObjectWithName:@"video.mp4" data:videoData];

    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
        
}

-(void) showImagePicker:(BOOL) userIsRecording {
    // Sets up image picker
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    NSArray *availableMediaTypes = [UIImagePickerController
                                    availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    if (userIsRecording
        && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerVC.mediaTypes = @[(NSString *)kUTTypeMovie];
    } else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)didPickSong:(Song *)song {
    self.chosenSong = song;
    [self.createView updateAppearanceWithSong:song];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SpotifySearchViewController"]) {
        SpotifySearchViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
}


@end
