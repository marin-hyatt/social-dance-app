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
                
//                // Add observer for KVO
//                [self.playerItem addObserver:self forKeyPath:@"status" options:
//                 NSKeyValueObservingOptionNew
//                                context:&cellContext];
                
                self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                [self.videoView setPlayer:self.player];
                // TODO: UI stuff
                NSLog(@"I'm in the main queue");
            }
            
        });
        
    }];
    [task resume];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == cellContext) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerItem *playerItem = (AVPlayerItem *)object;
            NSLog(@"%ld", playerItem.status);
            
            AVAsset *asset = playerItem.asset;
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *track = [tracks objectAtIndex:0];
            CGFloat trackHeight = track.naturalSize.height;
            CGFloat trackWidth = track.naturalSize.width;
            
            // Update UI
            [self.videoView printDimensions];
            [self.videoView updateAutolayoutWithHeight:trackHeight withWidth:trackWidth];
            
            @try {
                [object removeObserver:self forKeyPath:keyPath];
            }
            @catch (NSException * __unused exception) {}
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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

@end
