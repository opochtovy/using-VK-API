//
//  OPPostProfileViewController.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 17.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

// That class illustrates transition to detailed information of the post after pressing on the cell with that post. Here we can comment current post and add/delete like.

#import "OPPostProfileViewController.h"

#import "OPServerManager.h"

#import "OPUser.h"
#import "OPGroup.h"
#import "OPPost.h"
#import "OPAttachmentPhoto.h"
#import "OPAttachmentVideo.h"
#import "OPComment.h"

#import "UIImageView+AFNetworking.h"

#import "OPCommentCell.h"

@interface OPPostProfileViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostOwnerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentHeaderLabel;

@property (weak, nonatomic) IBOutlet UIImageView *ownerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *repostOwnerImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *likesScrollView;
@property (weak, nonatomic) IBOutlet UIView *allLikesView;
@property (weak, nonatomic) IBOutlet UIView *commentHeaderView;
@property (weak, nonatomic) IBOutlet UIView *addCommentView;

@property (weak, nonatomic) IBOutlet UITextView *addCommentTextView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) UIButton *likeButton; // strong because I redraw it after pressing on that button
@property (strong, nonatomic) UIButton *addCommentButton;
@property (strong, nonatomic) UIButton *cancelCommentButton;

@property (strong, nonatomic) IBOutlet UITableView *commentsTableView; // STRONG

@property (strong, nonatomic) OPPost *postProfile;

@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIFont *boldFont;
@property (strong, nonatomic) UIFont *repostFont;
@property (strong, nonatomic) UIFont *repostBoldFont;

@property (strong, nonatomic) NSString *ownerNameString;
@property (strong, nonatomic) NSString *dateString;

@property (strong, nonatomic) NSString *repostOwnerNameString;
@property (strong, nonatomic) NSString *repostDateString;

@property (assign, nonatomic) CGSize scrollViewSize;

@property (strong, nonatomic) NSMutableArray *attachmentViewsArray;

@property (strong, nonatomic) NSMutableArray *usersWhoLikedPostArray;

@property (strong, nonatomic) UIWindow *appWindow;

@property (strong, nonatomic) NSMutableArray *likeImageViewsArray;

@property (assign, nonatomic) CGFloat likeButtonTopOffset;

@property (strong, nonatomic) NSMutableArray *commentsArray;

@property (strong, nonatomic) NSArray *heightsOfCellsForCommentsTableView;

@property (assign, nonatomic) BOOL keyboardIsOnScreen;

@end

@implementation OPPostProfileViewController

static NSInteger likesInRequest = 20;
static NSInteger commentsInRequest = 100;

static CGFloat fontOfSize = 14.0;
static CGFloat fontOfRepostSize = 12.0;
static CGFloat offsetFromTopBar = 20.0;
static CGFloat offset = 5.0;

static CGFloat ownerImageWidth = 40.0;
static CGFloat ownerImageHeight = 40.0;
static CGFloat repostOwnerImageWidth = 30.0;
static CGFloat repostOwnerImageHeight = 30.0;

static CGFloat videoWidth = 320.0;
static CGFloat videoHeight = 240.0;

static CGFloat likeButtonHeight = 30.0;
static CGFloat likeImageWidth = 30.0;
static CGFloat likeImageHeight = 30.0;

static CGFloat minAddCommentFieldHeight = 30.0;
static CGFloat addCommentButtonWidth = 100.0;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.commentsTableView.dataSource = self;
    self.commentsTableView.delegate = self;
    
    self.appWindow = [[[UIApplication sharedApplication] windows] firstObject];
    
    self.font = [UIFont systemFontOfSize:fontOfSize];
    self.boldFont = [UIFont boldSystemFontOfSize:fontOfSize];
    self.repostFont = [UIFont systemFontOfSize:fontOfRepostSize];
    self.repostBoldFont = [UIFont boldSystemFontOfSize:fontOfRepostSize];
    
    self.ownerNameString = [NSString string];
    self.dateString = [NSString string];
    
    self.repostOwnerNameString = [NSString string];
    self.repostDateString = [NSString string];
    
    self.attachmentViewsArray = [NSMutableArray array];
    
    self.usersWhoLikedPostArray = [NSMutableArray array];
    
    self.likeImageViewsArray = [NSMutableArray array];
    
    self.commentsArray = [NSMutableArray array];
    
    self.heightsOfCellsForCommentsTableView = [NSArray array];
    
    self.scrollView.delegate = self;
    self.likesScrollView.delegate = self;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(keyboardAppearedNotitification:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardDisappearedNotitification:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    // !!! - unsubscribe from NSNotificationCenter in dealloc
    
    self.topBarView.backgroundColor = [UIColor whiteColor];
    
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.allLikesView.backgroundColor = [UIColor purpleColor];
    
    [self.cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.cancelButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addCommentTextView.delegate = self;
    self.addCommentTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.addCommentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addCommentTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.addCommentTextView.keyboardType = UIKeyboardTypeASCIICapable;
    self.addCommentTextView.returnKeyType = UIReturnKeyDefault;
    self.addCommentTextView.spellCheckingType = UITextSpellCheckingTypeNo;
    self.addCommentTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.addCommentTextView.textAlignment = NSTextAlignmentJustified;
    
    self.addCommentTextView.text = @"Комментировать...";
    self.addCommentTextView.textColor = [UIColor lightGrayColor];
    
    [self getPostProfileFromServer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    // !!! - unsubscribe from NSNotificationCenter
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications
- (void)keyboardAppearedNotitification:(NSNotification *)notification {
    
    self.keyboardIsOnScreen = YES;
    
    self.addCommentTextView.text = nil;
    self.addCommentTextView.textColor = [UIColor blackColor];
    
    NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGRect keyboardFrame = [value CGRectValue];
    
    // here I change the height of scrollView decreasing by the keyboard height
    self.scrollView.frame = CGRectMake(0.f,
                                       offsetFromTopBar,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height - offsetFromTopBar - keyboardFrame.size.height);
    
    // addCommentButton
    
    self.addCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addCommentButton.titleLabel.font = self.boldFont;
    [self.addCommentButton setTitle:@"Отправить" forState:UIControlStateNormal];
    [self.addCommentButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.addCommentButton setBackgroundColor:[UIColor whiteColor]];
    [self.addCommentButton addTarget:self action:@selector(actionAddComment:) forControlEvents:UIControlEventTouchUpInside];
    self.addCommentButton.frame = CGRectMake(self.view.bounds.size.width - addCommentButtonWidth - offset,
                                             offset,
                                             addCommentButtonWidth,
                                             minAddCommentFieldHeight);
    self.addCommentButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.addCommentView addSubview:self.addCommentButton];
    
    // cancelCommentButton
    
    self.cancelCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelCommentButton.titleLabel.font = self.boldFont;
    [self.cancelCommentButton setTitle:@"Отмена" forState:UIControlStateNormal];
    [self.cancelCommentButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.cancelCommentButton setBackgroundColor:[UIColor whiteColor]];
    [self.cancelCommentButton addTarget:self action:@selector(actionCancelComment:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelCommentButton.frame = CGRectMake(self.view.bounds.size.width - addCommentButtonWidth - offset,
                                             offset + minAddCommentFieldHeight + offset,
                                             addCommentButtonWidth,
                                             minAddCommentFieldHeight);
    self.cancelCommentButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.addCommentView addSubview:self.cancelCommentButton];
    [self countAllFrames];
}

- (void)keyboardDisappearedNotitification:(NSNotification *)notification {
    
    self.keyboardIsOnScreen = NO;
    
    self.scrollView.frame = CGRectMake(0.f,
                                       offsetFromTopBar,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height - offsetFromTopBar);
    
    [self.addCommentButton removeFromSuperview];
    [self.cancelCommentButton removeFromSuperview];
    
    [self countAllFrames];
}

#pragma mark - Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    for (UIImageView *view in self.attachmentViewsArray) {
        
        [view removeFromSuperview];
    }
    
    [self.attachmentViewsArray removeAllObjects];
    
    [self countAllFrames];
}

#pragma mark - Private Methods

- (CGRect) countRectForPostText:(NSString *)text {
    
    NSDictionary *attributes = [self attributesForPostText];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(window.bounds.size.width - 2 * offset, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return rect;
}

- (CGRect) countRectForPostText:(NSString *) text forWidth:(CGFloat) width {
    
    NSDictionary *attributes = [self attributesForPostText];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return rect;
}

- (CGRect) countRectForPostText:(NSString *) text forWidth:(CGFloat) width forFont:(UIFont *) font {
    
    NSDictionary *attributes = [self attributesForTextWithFont:font];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return rect;
}

- (NSDictionary *) attributesForPostText {
    
    UIFont *font = [UIFont systemFontOfSize:fontOfSize];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(1, 1);
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentJustified];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor grayColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                shadow, NSShadowAttributeName,
                                paragraph, NSParagraphStyleAttributeName, nil];
    return attributes;
}

- (NSDictionary *) attributesForTextWithFont:(UIFont *) font {
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(1, 1);
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentJustified];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor grayColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                shadow, NSShadowAttributeName,
                                paragraph, NSParagraphStyleAttributeName, nil];
    return attributes;
}

- (NSString *) findStringForDate:(NSInteger) date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *currentDate = [NSDate date];
    
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:date];
    
    [dateFormatter setDateFormat:@"yyyy"];
    
    NSString *postDateString = [NSString string];
    
    if (date) {
        
        if ([[dateFormatter stringFromDate:postDate] isEqualToString:[dateFormatter stringFromDate:currentDate]]) {
            
            [dateFormatter setDateFormat:@"dd MMMM"];
            
            if ([[dateFormatter stringFromDate:postDate] isEqualToString:[dateFormatter stringFromDate:currentDate]]) {
                
                [dateFormatter setDateFormat:@"HH:mm"];
                
                postDateString = [NSString stringWithFormat:@"сегодня в %@", [dateFormatter stringFromDate:postDate]];
                
            } else {
                
                [dateFormatter setDateFormat:@"dd MMM HH:mm"];
                
                postDateString = [dateFormatter stringFromDate:postDate];
            }
            
        } else {
            
            [dateFormatter setDateFormat:@"dd MMMM yyyy HH:mm"];
            
            postDateString = [dateFormatter stringFromDate:postDate];
        }
        
    }
    
    return postDateString;
}

- (void) countAllFrames {
    
    // ownerImageView
    
    self.ownerImageView.frame = CGRectMake(offset,
                                            offset,
                                            ownerImageWidth,
                                           ownerImageHeight);
    
    // cancelButton
    
    CGRect cancelButtonRect = [self countRectForPostText:@"Закрыть"];
    
    self.cancelButton.frame = CGRectMake(self.appWindow.bounds.size.width - cancelButtonRect.size.width - offset,
                                         2 * offset,
                                         cancelButtonRect.size.width,
                                         cancelButtonRect.size.height);
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    // ownerNameLabel
    
    if (self.postProfile.ownerID > 0) {
        
        self.ownerNameString = [self.postProfile.postOwnerUser.firstName stringByAppendingFormat:@" %@", self.postProfile.postOwnerUser.lastName];
        
    } else if (self.postProfile.ownerID < 0) {
        
        self.ownerNameString = self.postProfile.postOwnerGroup.name;
    }
    
    CGFloat ownerNameRectWidth = self.appWindow.bounds.size.width - (offset + ownerImageWidth + offset) - (offset + self.cancelButton.frame.size.width + offset);
    
    CGRect ownerNameRect = [self countRectForPostText:self.ownerNameString forWidth:ownerNameRectWidth];
    
    self.ownerNameLabel.frame = CGRectMake(offset + ownerImageWidth + offset,
                                           offset,
                                           ownerNameRectWidth,
                                           ownerNameRect.size.height);
    
    self.ownerNameLabel.text = self.ownerNameString;
    self.ownerNameLabel.font = self.boldFont;
    
    // dateLabel
    
    self.dateString = [self findStringForDate:self.postProfile.postDate];
    
    CGRect dateRect = [self countRectForPostText:self.dateString forWidth:ownerNameRectWidth];
    
    self.dateLabel.frame = CGRectMake(offset + ownerImageWidth + offset,
                                      offset + ownerNameRect.size.height + offset,
                                      ownerNameRectWidth,
                                      dateRect.size.height);
    
    self.dateLabel.text = self.dateString;
    self.dateLabel.textColor = [UIColor grayColor];
    
    CGFloat maxHeightForOwner = MAX(ownerImageHeight, ownerNameRect.size.height + offset + dateRect.size.height);
    
    // repostOwnerImageView
    
    self.repostOwnerImageView.frame = CGRectMake(offset,
                                                 offset,
                                                 repostOwnerImageWidth,
                                                 repostOwnerImageHeight);
    
    // repostOwnerNameLabel
    
    if (self.postProfile.copyOwnerID > 0) {
        
        self.repostOwnerNameString = [self.postProfile.postCopyOwnerUser.firstName stringByAppendingFormat:@" %@", self.postProfile.postCopyOwnerUser.lastName];
        
    } else if (self.postProfile.copyOwnerID < 0) {
        
        self.repostOwnerNameString = self.postProfile.postCopyOwnerGroup.name;
    }
    
    self.repostOwnerNameString = [NSString stringWithFormat:@"Re: %@", self.repostOwnerNameString];
    
    CGFloat repostOwnerNameRectWidth = self.appWindow.bounds.size.width - (offset + repostOwnerImageWidth + offset);
    
    self.repostOwnerNameLabel.font = self.repostBoldFont;
    self.repostOwnerNameLabel.textColor = [UIColor brownColor];
    
    CGRect repostOwnerNameRect = [self countRectForPostText:self.repostOwnerNameString
                                                   forWidth:repostOwnerNameRectWidth
                                                forFont:self.repostOwnerNameLabel.font];
    
    self.repostOwnerNameLabel.frame = CGRectMake(offset + repostOwnerImageWidth + offset,
                                                 offset,
                                                 repostOwnerNameRectWidth,
                                                 repostOwnerNameRect.size.height);
    
    // repostDateLabel
    
    self.repostDateString = [self findStringForDate:self.postProfile.copyPostDate];
    
    self.repostDateLabel.font = self.repostFont;
    self.repostDateLabel.textColor = [UIColor grayColor];
    
    CGRect repostDateRect = [self countRectForPostText:self.repostDateString
                                              forWidth:repostOwnerNameRectWidth
                                           forFont:self.repostDateLabel.font];
    
    self.repostDateLabel.frame = CGRectMake(offset + repostOwnerImageWidth + offset,
                                            offset + repostOwnerNameRect.size.height + offset,
                                            repostOwnerNameRectWidth,
                                            repostDateRect.size.height);
    
    CGFloat maxHeightForRepostOwner = 0;
    
    if (self.postProfile.copyOwnerID) {
        
        maxHeightForRepostOwner = MAX(repostOwnerImageHeight, repostOwnerNameRect.size.height + offset + repostDateRect.size.height);
        maxHeightForRepostOwner += offset;
        
        self.repostOwnerNameLabel.text = self.repostOwnerNameString;
        self.repostDateLabel.text = self.repostDateString;
    }
    
    // textLabel
    
    CGRect textRect;
    
    if ([self.postProfile.text length] > 0) {
        
        textRect = [self countRectForPostText:self.postProfile.text];
        self.textLabel.text = self.postProfile.text;
        
    } else if ([self.postProfile.repostText length] > 0) {
        
        textRect = [self countRectForPostText:self.postProfile.repostText];
        self.textLabel.text = self.postProfile.repostText;
    }
    
    self.textLabel.frame = CGRectMake(offset,
                                      offset + maxHeightForRepostOwner,
                                      self.appWindow.bounds.size.width - 2 * offset,
                                      textRect.size.height);
    
    // attachments
    
    CGFloat maxHeightForAttachments = 0;
    
    // attachmentPhoto
    
    CGFloat attachmentWidth;
    CGFloat attachmentHeight;
    
    if ([self.postProfile.attachments count]) {
        
        maxHeightForAttachments = offset;
        
        for (id attachment in self.postProfile.attachments) {
            
            if ([attachment isKindOfClass:[OPAttachmentPhoto class]]) {
                
                OPAttachmentPhoto *attachmentPhoto = (OPAttachmentPhoto *)attachment;
                
                attachmentWidth = MIN(self.appWindow.bounds.size.width - 2 * offset, (float)attachmentPhoto.width);
                attachmentHeight = attachmentWidth * (float)attachmentPhoto.height / (float)attachmentPhoto.width;
                
                CGRect attachmentPhotoFrame = CGRectMake(offset,
                                                         offset + maxHeightForRepostOwner + textRect.size.height + offset + maxHeightForAttachments,
                                                         attachmentWidth,
                                                         attachmentHeight);
                
                maxHeightForAttachments += attachmentHeight + offset;
                
                UIImageView *attachmentPhotoView = [[UIImageView alloc] initWithFrame:attachmentPhotoFrame];
                
                [self.contentView addSubview:attachmentPhotoView];
                
                [self.attachmentViewsArray addObject:attachmentPhotoView];
                
                // loading image for attachments (photo)
                 NSURLRequest *request;
                 
                 if (attachmentPhoto.photo807URL) {
                 
                 request = [NSURLRequest requestWithURL:attachmentPhoto.photo807URL];
                 
                 } else if (attachmentPhoto.photo604URL) {
                 
                 request = [NSURLRequest requestWithURL:attachmentPhoto.photo604URL];
                 } else if (attachmentPhoto.photo130URL) {
                 
                 request = [NSURLRequest requestWithURL:attachmentPhoto.photo130URL];
                 } else if (attachmentPhoto.photo75URL) {
                 
                 request = [NSURLRequest requestWithURL:attachmentPhoto.photo75URL];
                 }
                 
                 if (request) {
                 
                 __weak UIImageView *weakAttachmentPhotoView = attachmentPhotoView;
                 
                 [attachmentPhotoView
                 setImageWithURLRequest:request
                 placeholderImage:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                     
                     weakAttachmentPhotoView.image = image;
                 
                 }
                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                 
                 }];
                 
                 }
                
            } else if ([attachment isKindOfClass:[OPAttachmentVideo class]]) {
                    
                    OPAttachmentVideo *attachmentVideo = (OPAttachmentVideo *)attachment;
                    
                    attachmentWidth = MIN(self.appWindow.bounds.size.width - 2 * offset, videoWidth);
                    attachmentHeight = attachmentWidth * videoHeight / videoWidth;
                
                    CGRect attachmentVideoFrame = CGRectMake(offset,
                                                             offset + maxHeightForRepostOwner + textRect.size.height + offset + maxHeightForAttachments,
                                                             attachmentWidth,
                                                             attachmentHeight);
                    
                    maxHeightForAttachments += attachmentHeight + offset;
                    
                    UIImageView *attachmentVideoView = [[UIImageView alloc] initWithFrame:attachmentVideoFrame];
                    
                    [self.contentView addSubview:attachmentVideoView];
                
                    [self.attachmentViewsArray addObject:attachmentVideoView];
                    
                    // loading image for attachments (image for video)
                    NSURLRequest *request;
                    
                    if (attachmentVideo.photo320URL) {
                        
                        request = [NSURLRequest requestWithURL:attachmentVideo.photo320URL];
                        
                    } else if (attachmentVideo.photo130URL) {
                        
                        request = [NSURLRequest requestWithURL:attachmentVideo.photo130URL];
                    }
                    
                    if (request) {
                        
                        __weak UIImageView *weakAttachmentVideoView = attachmentVideoView;
                        
                        [attachmentVideoView
                         setImageWithURLRequest:request
                         placeholderImage:nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             
                             weakAttachmentVideoView.image = image;
                             
                         }
                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             
                         }];
                    }
                }
            
        }
        
        maxHeightForAttachments += offset;
    }
    
    // likeButton
    
    self.likeButtonTopOffset = offset + maxHeightForRepostOwner + maxHeightForAttachments + self.textLabel.frame.size.height + offset;
    
    [self drawLikeButton:self.likeButtonTopOffset];
    
    // commentHeaderLabel
    
    CGFloat commentsHeaderTopOffset = offset + maxHeightForRepostOwner + maxHeightForAttachments + self.textLabel.frame.size.height + offset + ownerImageHeight + offset;
    
    NSInteger commentsCountRest = self.postProfile.commentsCount % 10;
    
    NSString *endString = [NSString string];
    
    switch (commentsCountRest) {
        case 1:
            endString = @"комментарий";
            break;
            
        case 2:
            endString = @"комментария";
            break;
            
        case 3:
            endString = @"комментария";
            break;
            
        case 4:
            endString = @"комментария";
            break;
            
        default:
            endString = @"комментариев";
            break;
    }
    
    NSString *commentHeaderString = [NSString stringWithFormat:@"%i %@", self.postProfile.commentsCount, endString];
    
    CGRect commentHeaderRect = [self countRectForPostText:commentHeaderString
                                                 forWidth:(self.appWindow.bounds.size.width - 2 * offset)
                                                  forFont:self.boldFont];
    
    self.commentHeaderLabel.frame = CGRectMake(offset,
                                               offset,
                                               self.appWindow.bounds.size.width - 2 * offset,
                                               commentHeaderRect.size.height);
    
    self.commentHeaderLabel.text = commentHeaderString;
    self.commentHeaderLabel.font = self.boldFont;
    
    // commentHeaderView
    
    self.commentHeaderView.frame = CGRectMake(0,
                                               commentsHeaderTopOffset,
                                               self.view.frame.size.width,
                                               commentHeaderRect.size.height + 2 * offset);
    
    self.commentHeaderView.backgroundColor = [UIColor cyanColor];
    
    // commentsArray
    
    CGFloat commentsTableViewTopOffset = commentsHeaderTopOffset + self.commentHeaderView.frame.size.height;
    
    CGFloat heightForCommentsTableView = 0;

    if ([self.commentsArray count]) {
        
        heightForCommentsTableView = [self heightForCommentsTableView];
        
        self.commentsTableView.frame = CGRectMake(0,
                                                  commentsTableViewTopOffset,
                                                  self.view.frame.size.width,
                                                  heightForCommentsTableView);
        
    } else {
        
        self.commentsTableView.frame = CGRectMake(0, 0, 0, 0);
    }
    
    // addCommentField -> addCommentTextView
    
    CGFloat addCommentTextViewWidth = self.view.bounds.size.width - 2 * offset;
    CGFloat addCommentTextViewHeight = minAddCommentFieldHeight;
    
    if (self.keyboardIsOnScreen) {
        
        addCommentTextViewWidth = self.view.bounds.size.width - addCommentButtonWidth - 3 * offset;
        addCommentTextViewHeight = 2 * minAddCommentFieldHeight + offset;
        
    }
    
    CGRect addCommentTextViewRect = CGRectMake(0.f,
                                               0.f,
                                               addCommentTextViewWidth,
                                               addCommentTextViewHeight);
   
    self.addCommentTextView.frame = CGRectMake(offset,
                                               offset,
                                               addCommentTextViewWidth,
                                               addCommentTextViewHeight);
    
    self.addCommentTextView.backgroundColor = [UIColor whiteColor];
    self.addCommentTextView.font = self.font;
    
    // addCommentView
    
    CGFloat addCommentViewTopOffset = commentsTableViewTopOffset + self.commentsTableView.frame.size.height;
    
    self.addCommentView.frame = CGRectMake(0,
                                           addCommentViewTopOffset,
                                           self.view.frame.size.width,
                                           addCommentTextViewRect.size.height + 2 * offset);
    
    self.addCommentView.backgroundColor = [UIColor purpleColor];
    
    CGFloat contentViewHeight = addCommentViewTopOffset + self.addCommentView.frame.size.height;
    
    // headerView
    
    self.topBarView.frame = CGRectMake(0,
                                       0,
                                       self.appWindow.bounds.size.width,
                                       offsetFromTopBar);
    
    self.headerView.frame = CGRectMake(0,
                                       0,
                                       self.appWindow.bounds.size.width,
                                       offset + maxHeightForOwner + offset);
    
    self.headerView.backgroundColor = [UIColor cyanColor];
    
    self.contentView.frame = CGRectMake(0,
                                        self.headerView.frame.size.height,
                                        self.appWindow.bounds.size.width,
                                        contentViewHeight);
    
    // self.scrollViewSize
    
    self.scrollViewSize = CGSizeMake(self.appWindow.bounds.size.width,
                                     self.headerView.frame.size.height + self.contentView.frame.size.height);
    
    self.scrollView.contentSize = self.scrollViewSize;
    
    if ( self.keyboardIsOnScreen && (self.headerView.frame.size.height + self.contentView.frame.size.height >= self.scrollView.frame.size.height) ) {
        
        self.scrollView.contentOffset = CGPointMake(0.f,
                                                    self.headerView.frame.size.height + self.contentView.frame.size.height - self.scrollView.frame.size.height);
    }

    [self.commentsTableView reloadData];
    
}

// that method draws self.likeButton, self.likesScrollView, allLikesView
- (void) drawLikeButton:(CGFloat) topOffset {
    
    // likeButton
    
    NSString *likeButtonString = [@"Мне нравится " stringByAppendingFormat:@" %i", self.postProfile.likesCount];
    
    [self.likeButton setTitle:likeButtonString forState:UIControlStateNormal];
    
    if (self.postProfile.isLiked) {
        
        [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.likeButton setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.8f]];
        
        self.likeButton.titleLabel.font = [UIFont boldSystemFontOfSize:fontOfRepostSize];
        
    } else {
        
        [self.likeButton setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.8f] forState:UIControlStateNormal];
        [self.likeButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2]];
        
        self.likeButton.titleLabel.font = [UIFont systemFontOfSize:fontOfRepostSize];
    }
    
    CGFloat likeButtonRectWidth = self.view.bounds.size.width - 2 * offset;
    
    CGRect likeButtonRect = [self countRectForPostText:likeButtonString
                                              forWidth:likeButtonRectWidth
                                               forFont:self.likeButton.titleLabel.font];
    
    self.likeButton.frame = CGRectMake(offset,
                                       topOffset + offset,
                                       likeButtonRect.size.width + 2 * offset,
                                       likeButtonHeight);
    
    self.likeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    [self.contentView addSubview:self.likeButton];
    
    // images of owners (users or groups) who liked that post
    
    CGFloat maxWidthForLikeImages = 0;
    
    if ([self.usersWhoLikedPostArray count]) {
        
        maxWidthForLikeImages = offset;
        
        for (OPUser *user in self.usersWhoLikedPostArray) {
            
            CGRect userPhotoFrame = CGRectMake(maxWidthForLikeImages,
                                               offset,
                                               likeImageWidth,
                                               likeImageHeight);
            
            maxWidthForLikeImages += likeImageWidth + offset;
            
            UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:userPhotoFrame];
            
            [self.allLikesView addSubview:likeImageView];
            
            [self.likeImageViewsArray addObject:likeImageView];
            
            // loading of image for owner of like for that post
            NSURLRequest *request;
            
            if (user.imageURL) {
                
                request = [NSURLRequest requestWithURL:user.imageURL];
                
            }
            
            if (request) {
                
                __weak UIImageView *weakLikeImageView = likeImageView;
                
                [likeImageView
                 setImageWithURLRequest:request
                 placeholderImage:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                     
                     weakLikeImageView.image = image;
                     
                 }
                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                     
                 }];
            }
        }
    }
    
    // likeScrollView - UIScrollView
    
    CGSize likeScrollViewSize = CGSizeMake(maxWidthForLikeImages,
                                           likeButtonHeight + 2 * offset);
    self.likesScrollView.contentSize = likeScrollViewSize;
    
    // allLikesView
    if (self.postProfile.likesCount) {
        
        self.likesScrollView.frame = CGRectMake(offset + self.likeButton.frame.size.width + offset,
                                                topOffset,
                                                MIN(maxWidthForLikeImages, self.view.frame.size.width - (offset + self.likeButton.frame.size.width + 2 * offset)),
                                                likeButtonHeight + 2 * offset);
        
        self.allLikesView.frame = CGRectMake(0,
                                             0,
                                             maxWidthForLikeImages,
                                             likeButtonHeight + 2 * offset);
        
    } else {
        
        self.likesScrollView.frame = CGRectMake(0, 0, 0, 0);
        self.allLikesView.frame = CGRectMake(0, 0, 0, 0);
    }
}

- (CGFloat) heightForCommentsTableView {

    CGFloat heightForCommentsTableView = 0;
    
    NSMutableArray *heights = [NSMutableArray array];
    
    for (OPComment *comment in self.commentsArray) {
        
        CGFloat commentCellHeight = [OPCommentCell heightForComment:comment];
        
        heightForCommentsTableView += commentCellHeight;
        
        [heights addObject:[NSNumber numberWithFloat:commentCellHeight]];
        
    }
    
    self.heightsOfCellsForCommentsTableView = [heights copy];
    
    return heightForCommentsTableView;
    
}

#pragma mark - API

// that method gets detailed information for current post
- (void)getPostProfileFromServer {
    
    [[OPServerManager sharedManager]
     getPostById:self.postID
     onSuccess:^(OPPost *profile)
    {
        self.postProfile = profile;
        
        [self countAllFrames];
        
        if (self.postProfile.likesCount) {
            
            [self getLikesForPostFromServer];
            
            [self getIsLikedInfoForPostFromServer];
        }
        
        if (self.postProfile.commentsCount) {
            
            [self getCommentsForPost];
        }
            
        // loading of image for self.ownerImageView
        NSURLRequest *request;
        
        if (self.postProfile.ownerID > 0) {
            
            request = [NSURLRequest requestWithURL:self.postProfile.postOwnerUser.imageURL];
            
        } else if (self.postProfile.ownerID < 0) {
            
            request = [NSURLRequest requestWithURL:self.postProfile.postOwnerGroup.imageURL];
        }
        
        __weak UIImageView *weakOwnerImageView = self.ownerImageView;
        
        [self.ownerImageView
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
        {
            weakOwnerImageView.image = image;
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
        {
         
        }];
        
        // loading of image for self.repostOwnerImageView
        
        if (self.postProfile.copyOwnerID > 0) {
            
            request = [NSURLRequest requestWithURL:self.postProfile.postCopyOwnerUser.imageURL];
            
        } else if (self.postProfile.copyOwnerID < 0) {
            
            request = [NSURLRequest requestWithURL:self.postProfile.postCopyOwnerGroup.imageURL];
        }
        
        if (self.postProfile.copyOwnerID) {
            
            __weak UIImageView *weakRepostOwnerImageView = self.repostOwnerImageView;
            
            [self.repostOwnerImageView
             setImageWithURLRequest:request
             placeholderImage:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
            {
                weakRepostOwnerImageView.image = image;
            }
             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
            {
              
            }];
        }
    }
     onFailure:^(NSError *error, NSInteger statusCode)
    {
    }];

}

// that method gets detailed information for likes of current post
- (void)getLikesForPostFromServer {
    
    [[OPServerManager sharedManager]
     getLikesForOwnerID:self.postProfile.ownerID
     itemID:self.postProfile.postID
     withOffset:0
     count:likesInRequest
     onSuccess:^(NSArray *users)
    {
        [self.usersWhoLikedPostArray removeAllObjects];
        
        [self.usersWhoLikedPostArray addObjectsFromArray:users];
        
        [self.likeButton removeFromSuperview];
        
        for (UIView *view in self.likeImageViewsArray) {
            
            [view removeFromSuperview];
        }
        
        self.likeImageViewsArray = nil;
        
        [self drawLikeButton:self.likeButtonTopOffset];
        
    }
     onFailure:^(NSError *error, NSInteger statusCode)
    {
        NSLog(@"Error: %@", error);
    }];
    
}

// method to find out value of isLiked for post
- (void)getIsLikedInfoForPostFromServer {
    
    [[OPServerManager sharedManager]
     getIsLikedInfoForUser:self.postProfile.ownerID
     owner:self.postProfile.ownerID
     item:self.postProfile.postID
     onSuccess:^(BOOL liked)
    {
        self.postProfile.isLiked = liked;

        // next we redraw likeButton
        if (self.postProfile.isLiked) {
            
            [self.likeButton removeFromSuperview];
            
            for (UIView *view in self.likeImageViewsArray) {
                
                [view removeFromSuperview];
            }
            
            self.likeImageViewsArray = nil;
            
            [self drawLikeButton:self.likeButtonTopOffset];
        }
        
    }
     onFailure:^(NSError *error, NSInteger statusCode)
    {
    }];
    
}

// method to add like of current user for post
- (void)addLikeForPost {
    
    [[OPServerManager sharedManager]
     addLikeForItem:self.postProfile.postID
     owner:self.postProfile.ownerID
     onSuccess:^(NSInteger count)
     {
         self.postProfile.likesCount = count;
         
         [self getLikesForPostFromServer];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
     }];
    
}

// method to delete like of current user for post
- (void)deleteLikeForPost {
    
    [[OPServerManager sharedManager]
     deleteLikeForItem:self.postProfile.postID
     owner:self.postProfile.ownerID
     onSuccess:^(NSInteger count)
     {
         self.postProfile.likesCount = count;
         
         [self getLikesForPostFromServer];
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
     }];
    
}

// that method gets detailed information for comments of current post
- (void)getCommentsForPost {
    
    [[OPServerManager sharedManager]
     getCommentsForOwner:self.postProfile.ownerID
     post:self.postProfile.postID
     withOffset:0
     count:commentsInRequest
     onSuccess:^(NSArray *comments)
     {
         [self.commentsArray removeAllObjects];
         
         [self.commentsArray addObjectsFromArray:comments];
         
         self.postProfile.commentsCount = [self.commentsArray count];
         
         if (self.keyboardIsOnScreen) {
             
             [self.addCommentTextView resignFirstResponder];
             
             self.addCommentTextView.textColor = [UIColor lightGrayColor];

         } else {
             
             [self countAllFrames];
         }

     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         NSLog(@"Error: %@", error);
     }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.commentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPComment *comment = [self.commentsArray objectAtIndex:indexPath.row];
    
    CGFloat cellHeight = [[self.heightsOfCellsForCommentsTableView objectAtIndex:indexPath.row] floatValue];
    
    static NSString *identifier = @"CommentCell";
    
    OPCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    [cell countAllFramesForComment:comment cellHeight:cellHeight];
    
    NSString *ownerName = [NSString string];
    
    if (comment.ownerID > 0) {
        
        ownerName = [comment.userAsOwner.firstName stringByAppendingFormat:@" %@", comment.userAsOwner.lastName];
        
    } else {
        
        ownerName = comment.groupAsOwner.name;
    }
    
    NSString *date = [OPCommentCell findStringForDate:comment.date];
    
    // all texts for labels
    
    cell.ownerNameLabel.text = ownerName;
    cell.ownerNameLabel.font = self.boldFont;
    
    cell.commentTextLabel.text = comment.text;
    cell.commentTextLabel.font = self.font;
    cell.commentTextLabel.textAlignment = NSTextAlignmentJustified;
    
    cell.dateLabel.text = date;
    cell.dateLabel.font = self.repostFont;
    
    // loading image for cell.ownerImageView
    
    NSURL *imageURL = [[NSURL alloc] init];
    
    if (comment.ownerID > 0) {
        
        imageURL = comment.userAsOwner.imageURL;
        
    } else {
        
        imageURL = comment.groupAsOwner.imageURL;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    
    cell.ownerImageView.image = nil;
    
    __weak OPCommentCell *weakCell = cell;
    
    [cell.ownerImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
         weakCell.ownerImageView.image = image;
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

// we need that method to count height for each cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    if ([self.heightsOfCellsForCommentsTableView count]) {
        
        height = [[self.heightsOfCellsForCommentsTableView objectAtIndex:indexPath.row] floatValue];
        
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    self.addCommentTextView.text = textView.text;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if ([textView isEqual:self.addCommentTextView]) {
        
        [self countAllFrames];
    }
    
    return YES;
}

#pragma mark - Actions

- (void)actionCancel:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionLike:(UIButton *)sender {
    
    if (self.postProfile.isLiked) {
        
        [self deleteLikeForPost];
        
    } else {
        
        [self addLikeForPost];
    }
    
    self.postProfile.isLiked = !self.postProfile.isLiked;
}

- (void)actionAddComment:(UIButton *)sender {
    
    [[OPServerManager sharedManager]
     postComment:self.addCommentTextView.text
     forPost:self.postProfile.postID
     onOwnerWall:self.postProfile.ownerID
     onSuccess:^(id result)
    {
        [self getCommentsForPost];
    }
     onFailure:^(NSError *error, NSInteger statusCode)
    {
    }];
    
}

- (void)actionCancelComment:(UIButton *)sender {
    
    [self.addCommentTextView resignFirstResponder];
    
    self.addCommentTextView.text = @"Комментировать...";
    self.addCommentTextView.textColor = [UIColor lightGrayColor];
    
}

@end
