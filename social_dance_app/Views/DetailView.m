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
#import "UIManager.h"

@implementation DetailView

- (void)updateAppearanceWithPost:(Post *)post {
    self.captionLabel.text = post.caption;
    
    self.listenWithSpotifyButton.layer.cornerRadius = 5;
    self.listenWithSpotifyButton.layer.masksToBounds = true;
    
    [self updateSongWithPost:post];
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

-(void)updateVideoWithPost:(Post *)post {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.videoPlayerView addGestureRecognizer:tapGestureRecognizer];
    [self.videoPlayerView setUserInteractionEnabled:YES];
    [self.videoPlayerView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
    
    // Update autolayout corresponding to video aspect ratio
    CGFloat videoHeight = [post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [post[@"videoWidth"] doubleValue];
    
    [self.videoPlayerView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];
}

-(void)startPlayback {
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

@end
