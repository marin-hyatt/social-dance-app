#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN const CGFloat RKTagsViewAutomaticDimension; // use sizeToFit

typedef NS_ENUM(NSInteger, RKTagsViewTextFieldAlign) { // align is relative to a last tag
  RKTagsViewTextFieldAlignTop,
  RKTagsViewTextFieldAlignCenter,
  RKTagsViewTextFieldAlignBottom,
};

@class RKTagsView;

@protocol RKTagsViewDelegate <NSObject>

@optional

- (UIButton *)tagsView:(RKTagsView *)tagsView buttonForTagAtIndex:(NSInteger)index; // used default tag button if not implemented
- (BOOL)tagsView:(RKTagsView *)tagsView shouldAddTagWithText:(NSString *)text; // called when 'space' key pressed. return NO to ignore tag
- (BOOL)tagsView:(RKTagsView *)tagsView shouldSelectTagAtIndex:(NSInteger)index; // called when tag pressed. return NO to disallow selecting tag
- (BOOL)tagsView:(RKTagsView *)tagsView shouldDeselectTagAtIndex:(NSInteger)index; // called when selected tag pressed. return NO to disallow deselecting tag
- (BOOL)tagsView:(RKTagsView *)tagsView shouldRemoveTagAtIndex:(NSInteger)index; // called when 'backspace' key pressed. return NO to disallow removing tag

- (void)tagsViewDidChange:(RKTagsView *)tagsView; // called when tag was added or removed by user
- (void)tagsViewContentSizeDidChange:(RKTagsView *)tagsView;

@end

IB_DESIGNABLE
@interface RKTagsView: UIView

@property (nonatomic, strong, readonly) UIScrollView *scrollView; // scrollView delegate is not used
@property (nonatomic, strong, readonly) UITextField *textField; // textfield delegate is not used
@property (nonatomic, copy, readonly) NSArray<NSString *> *tags;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *selectedTagIndexes;
@property (nonatomic, weak, nullable) IBOutlet id<RKTagsViewDelegate> delegate;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic, strong) UIFont *font; // default is font from textfield
@property (nonatomic) IBInspectable BOOL editable; // default is YES
@property (nonatomic) IBInspectable BOOL selectable; // default is YES
@property (nonatomic) IBInspectable BOOL allowsMultipleSelection; // default is YES
@property (nonatomic) IBInspectable BOOL selectBeforeRemoveOnDeleteBackward; // default is YES
@property (nonatomic) IBInspectable BOOL deselectAllOnEdit; // default is YES
@property (nonatomic) IBInspectable BOOL deselectAllOnEndEditing; // default is YES
@property (nonatomic) IBInspectable BOOL scrollsHorizontally; // default is NO

@property (nonatomic) IBInspectable CGFloat lineSpacing; // default is 2
@property (nonatomic) IBInspectable CGFloat interitemSpacing; // default is 2
@property (nonatomic) IBInspectable CGFloat tagButtonHeight; // default is auto
@property (nonatomic) IBInspectable CGFloat textFieldHeight; // default is auto
@property (nonatomic) RKTagsViewTextFieldAlign textFieldAlign; // default is center

@property (nonatomic, strong) NSCharacterSet* deliminater; // defailt is [NSCharacterSet whitespaceCharacterSet]

- (NSInteger)indexForTagAtScrollViewPoint:(CGPoint)point; // NSNotFound if not found
- (nullable __kindof UIButton *)buttonForTagAtIndex:(NSInteger)index;
- (void)reloadButtons;

- (void)addTag:(NSString *)tag;
- (void)insertTag:(NSString *)tag atIndex:(NSInteger)index;
- (void)moveTagAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex; // can be animated
- (void)removeTagAtIndex:(NSInteger)index;
- (void)removeAllTags;

- (void)selectTagAtIndex:(NSInteger)index;
- (void)deselectTagAtIndex:(NSInteger)index;
- (void)selectAll;
- (void)deselectAll;

@end

NS_ASSUME_NONNULL_END
