//
//  HomeTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "HomeTableViewCell.h"
#import "Parse/Parse.h"
#import "PlayerView.h"


@implementation HomeTableViewCell

static void * cellContext = &cellContext;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    [self.videoView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.videoView addGestureRecognizer:tapGestureRecognizer];
    [self.videoView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    UITapGestureRecognizer *usernameTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    [self.profilePictureView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePictureView setUserInteractionEnabled:YES];
    [self.usernameLabel addGestureRecognizer:usernameTapGestureRecognizer];
    [self.usernameLabel setUserInteractionEnabled:YES];
}

- (void)updateAppearance {
    PFUser *user = self.post[@"author"];
    
    self.usernameLabel.text = user[@"username"];
    
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    // Update autolayout corresponding to video aspect ratio
    CGFloat videoHeight = [self.post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [self.post[@"videoWidth"] doubleValue];
    
    [self.videoView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];
    
    
    // Figure out if user liked video or not
    self.likeButton.selected = NO;
    NSArray *likedByUsers = self.post[@"likedByUsers"];
    NSLog(@"%@", likedByUsers);
    PFUser *currentUser = [PFUser currentUser];
    
    // TODO: potentially find out a better way to do this
    for (PFUser *user in likedByUsers) {
        if (user[@"objectId"] == currentUser[@"objectId"]) {
            self.likeButton.selected = YES;
        }
        break;
    }
     
    
//    [self setUpVideoPlayerWithUrl:videoFileUrl];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:videoFileUrl];
    
    // As I understand it, the task runs on a background thread
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // generate a temporary file URL
        NSString *filename = [[NSUUID UUID] UUIDString];
        
        NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *fileURL = [[temporaryDirectoryURL URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"mp4"];

        NSError *fileError;
        [data writeToURL:fileURL options:0 error:&fileError];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        

        // Code needs to be here, not in main queue
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.player == nil) {
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                
                self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                [self.videoView setPlayer:self.player];
            }
            
        });
        
    }];
    [task resume];
}

-(void)updateVideoAspect {
//    AVPlayerItem *playerItem = (AVPlayerItem *)object;
//    NSLog(@"%ld", playerItem.status);
    
    AVAsset *asset = self.playerItem.asset;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    CGFloat trackHeight = track.naturalSize.height;
    CGFloat trackWidth = track.naturalSize.width;
    
    // Update UI
    [self.videoView printDimensions];
    [self.videoView updateAutolayoutWithHeight:trackHeight withWidth:trackWidth];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

-(void)startPlayback {
    NSLog(@"Playback time");
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

-(void)onProfileTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"Profile picture tapped");
    [self.delegate feedCell:self didTap:self.post[@"author"]];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.player = nil;
}

- (IBAction)onLikeButtonTapped:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    
    if (!self.likeButton.selected) {
        [Post likePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateAppearance];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    } else {
        // Unlike post
        [Post unlikePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateAppearance];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
    
}

@end
