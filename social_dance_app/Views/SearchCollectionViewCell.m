//
//  SearchCollectionViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "SearchCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation SearchCollectionViewCell

- (void)updateAppearance {
    self.usernameLabel.text = self.user[@"username"];
    
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.layer.masksToBounds = true;
    PFFileObject *postImage = self.user[@"profilePicture"];
    NSURL *imageURL = [NSURL URLWithString:postImage.url];
    [self.profilePictureView setImageWithURL:imageURL];
}

@end
