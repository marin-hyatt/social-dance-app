//
//  SearchCollectionViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchCollectionViewCell : UICollectionViewCell
@property PFUser *user;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
-(void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
