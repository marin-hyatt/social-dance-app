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
#import "UIManager.h"

@interface CreateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RKTagsViewDelegate, SpotifySearchDelegate>
@property (strong, nonatomic) IBOutlet CreateView *createView;
@property (strong, nonatomic) PFFileObject *videoFile;
@property (strong, nonatomic) NSNumber *videoWidth;
@property (strong, nonatomic) NSNumber *videoHeight;
@property (strong, nonatomic) PFFileObject *thumbnailImage;
@property (strong, nonatomic) PFFileObject *lowQualityThumbnailImage;
@property (strong, nonatomic) Song *chosenSong;
@property (strong, nonatomic) AVAssetExportSession *exportSession;


@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.createView updateAppearance];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    self.createView.tagView.delegate = self;
}

- (void)dismissKeyboard {
    [self.createView endEditing:YES];
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
    if (self.videoFile != nil) {
        NSString *caption = self.createView.captionField.text;
        Song *song = self.chosenSong;

        [SVProgressHUD showWithStatus:@"Posting"];
        [Post postUserVideo:self.videoFile withCaption:caption withSong:song withHeight:self.videoHeight withWidth:self.videoWidth withLowQualityThumbnail:self.lowQualityThumbnailImage withThumbnail:self.thumbnailImage withTags:self.createView.tagView.tags withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
            }
            [SVProgressHUD dismiss];
        }];
        
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    } else {
        [UIManager presentAlertWithMessage:@"Choose a video before posting!" overViewController:self withHandler:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *filename = [[NSUUID UUID] UUIDString];
    NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *lowQualityMovie = [[temporaryDirectoryURL URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"mp4"];
    
    [self convertVideoToLowQuailtyWithInputURL:chosenMovie outputURL:lowQualityMovie handler:^(AVAssetExportSession *exportSession) {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *videoData = [NSData dataWithContentsOfURL:exportSession.outputURL];
                [self setVideoDimensionsWithVideoURL:chosenMovie];
                [self setVideoThumbnailWithVideoURL:chosenMovie];

                self.videoFile = [PFFileObject fileObjectWithName:@"video.mp4" data:videoData];

                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else if (exportSession.status == AVAssetExportSessionStatusFailed) {
            [UIManager presentAlertWithMessage:[NSString stringWithFormat:@"%@. Try uploading a shorter video.", exportSession.error.localizedDescription] overViewController:self withHandler:nil];
        }
    }];
}


- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession *))completion {
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    self.exportSession.outputURL = outputURL;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        completion(self.exportSession);
    }];
}

- (NSString *)sizeOfLocalURL:(NSURL *)url {
NSData *fileData = [[NSData alloc] initWithContentsOfURL:url];
return [NSString stringWithFormat:@"%.2f mb", fileData.length/1000000.00];
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

    CGImageRef image = [generateImg copyCGImageAtTime:thumbnailTime actualTime:NULL error:&imgError];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
    
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
    NSData *lowQualityData = UIImageJPEGRepresentation(thumbnail, 0.0);
    
    self.lowQualityThumbnailImage = [PFFileObject fileObjectWithName:@"low_quality_thumbnail.jpg" data:lowQualityData];
    PFFileObject *thumbnailImage = [PFFileObject fileObjectWithName:@"thumbnail.jpg" data:thumbnailData];
    self.thumbnailImage = thumbnailImage;
    
    [self.createView.thumbnailView setImage:[UIImage imageWithData:thumbnailData]];
}

- (void) showImagePicker:(BOOL) userIsRecording {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.videoQuality = UIImagePickerControllerQualityTypeMedium;
    imagePickerVC.videoMaximumDuration = 5 * 60; // 5 min max video
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
    [self.createView updateSongViewWithSong:song];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SpotifySearchViewController"]) {
        SpotifySearchViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
}


@end
