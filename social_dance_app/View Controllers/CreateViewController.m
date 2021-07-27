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
#import <AVFoundation/AVFoundation.h>
#import "SVProgressHUD.h"

@interface CreateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SpotifySearchDelegate>
@property (strong, nonatomic) IBOutlet CreateView *createView;
@property (strong, nonatomic) PFFileObject *videoFile;
@property (strong, nonatomic) NSNumber *videoWidth;
@property (strong, nonatomic) NSNumber *videoHeight;
@property (strong, nonatomic) PFFileObject *thumbnailImage;
@property (strong, nonatomic) Song *chosenSong;


@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.createView.frame;
        frame.origin.y = -keyboardSize.height;
        self.createView.frame = frame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.createView.frame;
        frame.origin.y = 0.0f;
        self.createView.frame = frame;
    }];
}

- (void)dismissKeyboard {
    [self.createView.captionField resignFirstResponder];
}

- (IBAction)onRecordVideoPressed:(UIButton *)sender {
    [self showImagePicker:YES];
}

- (IBAction)onChooseVideoPressed:(UIButton *)sender {
    [self showImagePicker:NO];
}

- (IBAction)onChooseSongPressed:(id)sender {
    [self performSegueWithIdentifier:@"SpotifySearchViewController" sender:nil];
    
}

- (IBAction)onPostPressed:(UIBarButtonItem *)sender {
    NSString *caption = self.createView.captionField.text;
    Song *song = self.chosenSong;

    [SVProgressHUD showWithStatus:@"Posting"];
    [Post postUserVideo:self.videoFile withCaption:caption withSong:song withHeight:self.videoHeight withWidth:self.videoWidth withThumbnail:self.thumbnailImage withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error! %@", error.localizedDescription);
        } else {
            [SVProgressHUD dismiss];
        }
    }];
    
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // grab our movie URL
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"%@", chosenMovie);
    
    NSData *videoData = [NSData dataWithContentsOfURL:chosenMovie];
    
    [self setVideoDimensionsWithVideoURL:chosenMovie];
    [self setVideoThumbnailWithVideoURL:chosenMovie];

    self.videoFile = [PFFileObject fileObjectWithName:@"video.mp4" data:videoData];

    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
        
}

- (void)setVideoDimensionsWithVideoURL:(NSURL *)url {
    // Get video width and height, need to switch based on orientation of video
    AVAssetTrack* videoTrack = [[[AVAsset assetWithURL:url] tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty) {
        self.videoWidth = [NSNumber numberWithDouble:size.width];
        self.videoHeight = [NSNumber numberWithDouble:size.height];
    }
    else if (txf.tx == 0 && txf.ty == 0) {
        self.videoWidth = [NSNumber numberWithDouble:size.width];
        self.videoHeight = [NSNumber numberWithDouble:size.height];
    }
    else if (txf.tx == 0 && txf.ty == size.width) {
        self.videoWidth = [NSNumber numberWithDouble:size.height];
        self.videoHeight = [NSNumber numberWithDouble:size.width];
    }
    else {
        self.videoWidth = [NSNumber numberWithDouble:size.height];
        self.videoHeight = [NSNumber numberWithDouble:size.width];
    }
}

- (void)setVideoThumbnailWithVideoURL:(NSURL *)url {
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    [generateImg setAppliesPreferredTrackTransform:YES];
    NSError *imgError = NULL;
    
    
    CMTime end = asset.duration;
    
    CMTime thumbnailTime = CMTimeMake(CMTimeGetSeconds(end) / 2, 1);
    NSLog(@"End: %f", CMTimeGetSeconds(end));
    NSLog(@"%f", CMTimeGetSeconds(thumbnailTime));
    CMTime time = CMTimeMake(1, 2);
    
    CGImageRef image = [generateImg copyCGImageAtTime:thumbnailTime actualTime:NULL error:&imgError];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
    
    PFFileObject *thumbnailImage = [PFFileObject fileObjectWithName:@"thumbnail.png" data:thumbnailData];
    self.thumbnailImage = thumbnailImage;
}

- (void) showImagePicker:(BOOL) userIsRecording {
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
        imagePickerVC.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
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
