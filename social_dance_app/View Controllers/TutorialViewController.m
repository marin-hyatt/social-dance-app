//
//  TutorialViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "TutorialViewController.h"
#import "CacheManager.h"
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "TutorialView.h"
#import "TutorialSettingViewController.h"
#import "UIManager.h"
#import "PostUtility.h"

@interface TutorialViewController () <TutorialSettingDelegate, PlayerViewDelegate>
@property (strong, nonatomic) IBOutlet TutorialView *tutorialView;
@property BOOL isMirrored;
@property float videoSpeedMultiplier;
@property CMTime startTime;
@property CMTime endTime;
@property CMTime duration;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isMirrored = YES;
    self.videoSpeedMultiplier = 1;
    self.tutorialView.slider.value = 0;
    self.startTime = CMTimeMakeWithSeconds(0, NSEC_PER_SEC);
    
    
    [self.tutorialView updateViewWithMirrorSetting:self.isMirrored];
    self.tutorialView.playerView.delegate = self;
    self.tutorialView.playbackSpeed = 1;
    [self loadVideo];
    [self updateVideoPlayer];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSliderWithTimestamp:) userInfo:nil repeats:YES];
}

- (void)setStartLabel {
    self.tutorialView.startLabel.text = [self convertCMTimeToReadableFormatWithCMTime:self.startTime];
}

- (void)setEndLabel {
    self.tutorialView.endLabel.text = [self convertCMTimeToReadableFormatWithCMTime:self.endTime];
}

- (NSString *)convertCMTimeToReadableFormatWithCMTime:(CMTime)time {
    NSUInteger timeInSeconds = CMTimeGetSeconds(time);

    NSUInteger minutes = floor(timeInSeconds % 3600 / 60);
    NSUInteger seconds = floor(timeInSeconds % 3600 % 60);

    NSString *readableTime = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
    return readableTime;
}

- (void)updateVideoPlayer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlaybackWithRate:)];
    [self.tutorialView.playerView addGestureRecognizer:tapGestureRecognizer];
    [self.tutorialView.playerView setUserInteractionEnabled:YES];
    [self.tutorialView.playerView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
}

- (void)loadVideo {
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * _Nonnull playerItem) {
    } withMainBlock:^(AVPlayerItem * _Nonnull playerItem) {
        if (self.tutorialView.player == nil) {
            self.tutorialView.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.tutorialView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.tutorialView.player currentItem]];
            [self.tutorialView.playerView setPlayer:self.tutorialView.player];
            [(AVPlayerLayer *)[self.tutorialView.playerView layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
            self.endTime = self.tutorialView.player.currentItem.asset.duration;
            self.duration = self.tutorialView.player.currentItem.asset.duration;
            [self setEndLabel];
        }
    }];
}

- (void)displayVideoThumbnail {
    [PostUtility displayVideoThumbnailOverView:self.tutorialView.playerView withPost:self.post withPlayButtonIncluded:NO];
}

- (void)removeVideoThumbnail {
    for (UIImageView *subview in self.tutorialView.playerView.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)startPlaybackWithRate:(float)playbackSpeed {
    if (self.tutorialView.player.rate != 0) {
        [self.tutorialView.player pause];
    } else {
        [self removeVideoThumbnail];
        [self.tutorialView.player playImmediatelyAtRate:self.tutorialView.playbackSpeed];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:self.startTime completionHandler:nil];
}

- (IBAction)onSettingsButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"TutorialSettingViewController" sender:nil];
}

- (IBAction)onDownloadButtonPressed:(UIBarButtonItem *)sender {
    [UIManager presentAlertWithMessage:@"Download this video to your device?" overViewController:self withHandler:^{
        [self downloadVideo];
    }];
}

- (void)downloadVideo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.post.videoFile.url]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filename = [[NSUUID UUID] UUIDString];
        NSString *filePath = [[documentsDirectory stringByAppendingPathComponent:filename] stringByAppendingString:@".mp4"];
        
        if ([videoData writeToFile:filePath atomically:YES]) {
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video: didFinishSavingWithError: contextInfo:), nil);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIManager presentAlertWithMessage:@"There was an error downloading the video." overViewController:self withHandler:nil];
            });
        }
    });
}

- (void) video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    if (error != nil) {
        [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
    }
}

- (void)mirrorVideoChangedWithNewValue:(BOOL)isMirrored {
    self.isMirrored = isMirrored;
    [self.tutorialView mirrorViewWithSetting:self.isMirrored];
}

- (void)videoSpeedChangedWithNewMultiplier:(float)multiplier {
    self.videoSpeedMultiplier = multiplier;
    
    [self.tutorialView changePlaybackRateWithRate:self.videoSpeedMultiplier];
}

- (IBAction)onSliderValueChanged:(UISlider *)sender {
    // Jump to appropriate point in video
    CMTime playerDuration = self.tutorialView.player.currentItem.duration;
    
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue = [self.tutorialView.slider minimumValue];
        float maxValue = [self.tutorialView.slider maximumValue];
        float value = [self.tutorialView.slider value];
        
        double time = duration * (value - minValue) / (maxValue - minValue);
        
        if (time > CMTimeGetSeconds(self.endTime)) {
            [self.tutorialView.player seekToTime:self.endTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        } else if (time < CMTimeGetSeconds(self.startTime)) {
        } else {
            [self.tutorialView.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        
    }
    [self.tutorialView.player pause];
}


- (void)updateSliderWithTimestamp:(CMTime)timestamp {
    self.tutorialView.startLabel.text = [self convertCMTimeToReadableFormatWithCMTime:self.tutorialView.player.currentTime];
    
    if (CMTimeGetSeconds(self.tutorialView.player.currentItem.currentTime) > CMTimeGetSeconds(self.endTime)) {
        [self.tutorialView.player seekToTime:self.startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    self.tutorialView.slider.value = CMTimeGetSeconds(self.tutorialView.player.currentItem.currentTime)  / CMTimeGetSeconds(self.tutorialView.player.currentItem.duration);
}

- (void)startTimeChangedToTime:(CMTime)startTime withReset:(BOOL)reset {
    if (CMTimeGetSeconds(startTime) >= CMTimeGetSeconds(self.startTime) || reset) {
        self.startTime = startTime;
        [self.tutorialView.player seekToTime:self.startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (void)endTimeChangedToTime:(CMTime)endTime withReset:(BOOL)reset {
    if (CMTimeGetSeconds(endTime) <= CMTimeGetSeconds(self.endTime) || reset) {
        self.endTime = endTime;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.tutorialView.player pause];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"TutorialSettingViewController"]) {
        TutorialSettingViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.isMirrored = self.isMirrored;
        vc.videoSpeedMutliplier = self.videoSpeedMultiplier;
        vc.startTimePlaceholder = @"00:00";
        vc.endTimePlaceholder = [self convertCMTimeToReadableFormatWithCMTime:self.duration];
    }
}


@end
