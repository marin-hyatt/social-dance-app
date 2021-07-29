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

@interface CreateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SpotifySearchDelegate>
@property (strong, nonatomic) IBOutlet CreateView *createView;
@property (strong, nonatomic) PFFileObject *videoFile;
@property (strong, nonatomic) NSNumber *videoWidth;
@property (strong, nonatomic) NSNumber *videoHeight;
@property (strong, nonatomic) PFFileObject *thumbnailImage;
@property (strong, nonatomic) Song *chosenSong;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) NSMutableArray *tags;


@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.createView updateAppearance];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.tags = [[NSMutableArray alloc] init];
    self.createView.tagField.delegate = self;
    
    [self.createView.tagView setAxis:UILayoutConstraintAxisHorizontal];
    [self.createView.tagView setDistribution:UIStackViewDistributionFillProportionally];
    [self.createView.tagView setAlignment:UIStackViewAlignmentCenter];
    [self.createView.tagView setSpacing:3];
}

- (void)dismissKeyboard {
    [self.createView.captionField resignFirstResponder];
    [self.createView.tagField resignFirstResponder];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![self.createView.tagField.text isEqualToString:@""]) {
        [self.tags addObject:[self.createView.tagField.text lowercaseString]];
        [self.createView.tagField setText:@""];
        
        CGSize stringsize = [[self.tags lastObject] sizeWithAttributes: @{
            NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
        }];
        UIButton *tag = [[UIButton alloc] init];
        [tag setFrame:CGRectMake(0,0, stringsize.width + 4, stringsize.height)];
        [tag addTarget:self
                action:@selector(removeTagAtIndex:)
      forControlEvents:UIControlEventTouchUpInside];
        
        [tag setBackgroundColor:[UIColor systemBlueColor]];
        [tag setTitle:[self.tags lastObject] forState:UIControlStateNormal];
        
        [self.createView.tagView addArrangedSubview:tag];
        [tag.heightAnchor constraintEqualToConstant:30].active = true;
        return YES;
    } else {
        return NO;
    }
    
}

- (void)removeTagAtIndex:(UIButton *)sender {
    for (NSString *tag in [self.tags copy]) {
        if ([tag isEqualToString:sender.titleLabel.text]) {
            [self.tags removeObject:tag];
        }
    }
    [self.createView.tagView removeArrangedSubview:[self.createView.tagView viewWithTag:sender.tag]];
    [sender removeFromSuperview];
}

- (IBAction)onPostPressed:(UIBarButtonItem *)sender {
    if (self.videoFile != nil) {
        NSString *caption = self.createView.captionField.text;
        Song *song = self.chosenSong;

        [SVProgressHUD showWithStatus:@"Posting"];
        [Post postUserVideo:self.videoFile withCaption:caption withSong:song withHeight:self.videoHeight withWidth:self.videoWidth withThumbnail:self.thumbnailImage withTags:self.tags withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error! %@", error.localizedDescription);
            } else {
                [SVProgressHUD dismiss];
            }
        }];
        
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    } else {
        [UIManager presentAlertWithMessage:@"Choose a video before posting!" overViewController:self];
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
            NSLog(@"Error: %@", exportSession.error.localizedDescription);
        } else {
            NSLog(@"Error: %ld", (long)exportSession.status);
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
    
    CGImageRef image = [generateImg copyCGImageAtTime:thumbnailTime actualTime:NULL error:&imgError];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
    
    PFFileObject *thumbnailImage = [PFFileObject fileObjectWithName:@"thumbnail.png" data:thumbnailData];
    self.thumbnailImage = thumbnailImage;
    
    [self.createView.thumbnailView setImage:[UIImage imageWithData:thumbnailData]];
}

- (void) showImagePicker:(BOOL) userIsRecording {
    // Sets up image picker
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.videoQuality = UIImagePickerControllerQualityTypeMedium;
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
