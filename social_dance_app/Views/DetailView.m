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

@end
