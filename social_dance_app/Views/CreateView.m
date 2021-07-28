//
//  CreateView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "CreateView.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"

@implementation CreateView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearance {
    PFUser *currentUser = [PFUser currentUser];
    PFFileObject *file = currentUser[@"profilePicture"];
    NSLog(@"%@", file);
    
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:file];
}

- (void)updateSongViewWithSong:(Song *)song {
    self.trackNameLabel.text = song.title;
    self.artistNameLabel.text = song.artist;
    
    self.albumImageView.image = nil;
    
    if (song.albumImageURLString != nil) {
        [self.albumImageView setImageWithURL: [NSURL URLWithString:song.albumImageURLString]];
    }
}

@end
