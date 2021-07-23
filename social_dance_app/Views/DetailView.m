//
//  DetailView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "DetailView.h"
#import "UIImageView+AFNetworking.h"
#import "Parse/Parse.h"
#import "CacheManager.h"
#import "Post.h"


@implementation DetailView

- (void)updateAppearanceWithPost:(Post *)post {
    NSLog(@"%@", post);
    
    self.usernameLabel.text = post.author.username;
    self.captionLabel.text = post.caption;
    
    [self updateSongWithPost:post];
    
    [self updateProfilePictureWithPost:post];
    
    [self updateVideoWithPost:post];
    
}

-(void)updateSongWithPost:(Post *)post {
    if (post.song == nil) {
        [self.songView setHidden:YES];
    } else {
        self.songNameLabel.text = post.song.title;
        
        self.albumImageView.image = nil;
        
        if (post.song.albumImageURLString != nil) {
            [self.albumImageView setImageWithURL: [NSURL URLWithString:post.song.albumImageURLString]];
        }
    }
}

-(void)updateProfilePictureWithPost:(Post *)post {
    PFFileObject * profileImage =  post.author[@"profilePicture"];
    NSURL * imageURL = [NSURL URLWithString:profileImage.url];
    [self.profilePictureView setImageWithURL:imageURL];
    
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.layer.masksToBounds = true;
}

-(void)updateVideoWithPost:(Post *)post {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.videoPlayerView addGestureRecognizer:tapGestureRecognizer];
    [self.videoPlayerView setUserInteractionEnabled:YES];
    [self.videoPlayerView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
    
    PFFileObject *videoFile = post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    // Update autolayout corresponding to video aspect ratio
    CGFloat videoHeight = [post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [post[@"videoWidth"] doubleValue];
    
    [self.videoPlayerView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * _Nonnull playerItem) {
    } withMainBlock:^(AVPlayerItem * _Nonnull playerItem) {
        if (self.player == nil) {
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.player currentItem]];
            [self.videoPlayerView setPlayer:self.player];
        }
    }];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

-(void)startPlayback {
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

@end
