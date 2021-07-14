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

@interface CreateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet CreateView *createView;
@property (strong, nonatomic) PFFileObject *videoFile;


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
    [self performSegueWithIdentifier:@"SpotifyAuthViewController" sender:nil];
}

- (IBAction)onPostPressed:(UIBarButtonItem *)sender {
    NSString *caption = self.createView.captionField.text;
    
    // TODO: add spotify functionality, for now Song object is nil
    Song *song = nil;

    
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

    // Checks to see if phone or simulator is able to take pictures
    if (userIsRecording && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerVC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    } else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
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
