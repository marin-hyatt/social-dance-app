//
//  BookmarkCollectionViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookmarkCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) Post *post;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
-(void)updateAppearanceWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
