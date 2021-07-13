//
//  SearchCollectionViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "SearchCollectionViewCell.h"

@implementation SearchCollectionViewCell

- (void)updateAppearance {
    self.usernameLabel.text = self.user[@"username"];
}

@end
