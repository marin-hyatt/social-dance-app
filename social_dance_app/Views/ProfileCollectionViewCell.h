//
//  ProfileCollectionViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) Post *post;

@end

NS_ASSUME_NONNULL_END
