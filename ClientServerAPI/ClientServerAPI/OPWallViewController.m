//
//  OPWallViewController.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// ! - we have to plug in the framework AFNetworking -> read instruction at https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking

#import "OPWallViewController.h"

#import "OPServerManager.h"

#import "OPUser.h"
#import "OPGroup.h"
#import "OPPost.h"
#import "OPAttachmentPhoto.h"
#import "OPAttachmentVideo.h"

// #import "OPPostCell.h"
#import "OPPostDrawingCell.h"

#import "UIImageView+AFNetworking.h"

#import "OPPostProfileViewController.h"

@interface OPWallViewController () <UITextFieldDelegate, OPServerManagerDelegate>

// that property is for authorization for only 1 time
@property (assign, nonatomic) BOOL firstTimeAppear;

// currentUserID for "wall.get"
@property (strong, nonatomic) NSString *currentUserID;

@property (strong, nonatomic) NSMutableArray *postsArray;
@property (strong, nonatomic) NSNumber *countOfPosts;

@property (strong, nonatomic) UITextField *postField; // necessarily weak
@property (nonatomic, weak) UIButton *postButton;

@property (strong, nonatomic) NSMutableArray *postOwnersUsersArray;
@property (strong, nonatomic) NSMutableArray *postOwnersGroupsArray;

@property (strong, nonatomic) NSMutableArray *userCopyOwnersArray;
@property (strong, nonatomic) NSMutableArray *groupCopyOwnersArray;

@end

@implementation OPWallViewController

static CGFloat fontOfSize = 14.0;
static CGFloat offset = 10.0;

//static NSString *userID = @"124397841";

static NSInteger postsInRequest = 20;

static CGFloat postButtonWidth = 100.0;
static CGFloat postButtonHeight = 30.0;
static CGFloat postButtonTopOffset = 7.0;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.firstTimeAppear = YES;
    
    self.postsArray = [NSMutableArray array];
    self.countOfPosts = [[NSNumber alloc] init];
    
    self.postOwnersUsersArray = [NSMutableArray array];
    self.postOwnersGroupsArray = [NSMutableArray array];
    
    self.userCopyOwnersArray = [NSMutableArray array];
    self.groupCopyOwnersArray = [NSMutableArray array];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    self.postField = [[UITextField alloc] init];
    self.postField.delegate = self;
//    self.postField.frame = CGRectMake(10, 7, 240, 30);
    
//    self.postField.frame = CGRectMake(5, 7, 200, 30);
    self.postField.frame = CGRectMake(offset, postButtonTopOffset, self.view.frame.size.width - postButtonWidth - 3 * offset, postButtonHeight);
    self.postField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // осталось доделать эстетические операции
    self.postField.borderStyle = UITextBorderStyleRoundedRect;
    self.postField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.postField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.postField.returnKeyType = UIReturnKeyDone;
    self.postField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.postField.spellCheckingType = UITextSpellCheckingTypeNo;
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.postButton.titleLabel.font = [UIFont systemFontOfSize:fontOfSize];
    
    [self.postButton setTitle:@"Отправить" forState:UIControlStateNormal];
    
    [self.postButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.postButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
    
    [self.postButton addTarget:self action:@selector(actionPost:) forControlEvents:UIControlEventTouchUpInside];
    
    self.postButton.frame = CGRectMake(self.view.frame.size.width - postButtonWidth - offset, postButtonTopOffset, postButtonWidth, postButtonHeight);
    
    self.postButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        
        self.firstTimeAppear = NO;
        
//        [OPServerManager sharedManager];
        OPServerManager *manager = [[OPServerManager sharedManager] init];
        manager.delegate = self;
        
    } else {
        
        [self refreshWall];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods

- (NSString *) formUserUidsStringForID:(NSString *)idKey {
    
    NSMutableString *userUidsString = [NSMutableString string];
    
    for (OPPost *post in self.postsArray) {
        
        NSNumber *IDNumber = [post valueForKey:idKey];
        
        NSInteger anID = [IDNumber integerValue];
        
        if (anID > 0) {
            
            if ([post isEqual:[self.postsArray lastObject]]) {
                
                [userUidsString appendFormat:@"%i", anID];
                
            } else {
                
                [userUidsString appendFormat:@"%i, ", anID];
            }
        }
    }
    
    return [userUidsString copy];
}

- (NSString *) formGroupUidsStringForID:(NSString *)idKey {
    
    NSMutableString *groupUidsString = [NSMutableString string];
    
    for (OPPost *post in self.postsArray) {
        
        NSNumber *IDNumber = [post valueForKey:idKey];
        
        NSInteger anID = [IDNumber integerValue];
        
        if (anID < 0) {
            
            if ([post isEqual:[self.postsArray lastObject]]) {
                
                [groupUidsString appendFormat:@"%i", (0 - anID)];
                
            } else {
                
                [groupUidsString appendFormat:@"%i, ", (0 - anID)];
            }
        }
    }
    
    return [groupUidsString copy];
}

#pragma mark - API

// that method to get a definite number of posts (postsInRequest with offset) from the curren user wall
- (void)getPostsFromServer {
    
    if ([self.currentUserID length]) {
        
        [[OPServerManager sharedManager]
         getUserWall:self.currentUserID
         withOffset:[self.postsArray count]
         count:postsInRequest
         onSuccess:^(NSArray *posts) {
             
             if ([posts count] > 1) {
                 
                 self.countOfPosts = [posts firstObject];
                 
                 posts = [posts subarrayWithRange:NSMakeRange(1, (int)[posts count] - 1)];
                 
                 [self.postsArray addObjectsFromArray:posts];
                 
             } else {
                 
                 self.postsArray = nil;
             }
             
             [self getPostOwnerUserProfilesFromServer];
             
             [self getPostOwnerGroupProfilesFromServer];
             
             [self getPostCopyOwnerUserProfilesFromServer];
             
             [self getPostCopyOwnerGroupProfilesFromServer];
         
//             [self.tableView reloadData];
             
             NSMutableArray *newPaths = [NSMutableArray array];
             for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                 [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
             }
             
         }
         
         onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
        
    }
    
}

// // that method to refresh all posts from the curren user wall - similar to getPostsFromServer
- (void)refreshWall {
    
    if ([self.currentUserID length]) {
        
        [[OPServerManager sharedManager]
         getUserWall:self.currentUserID
         withOffset:0
         count:MAX(postsInRequest, [self.postsArray count])
         onSuccess:^(NSArray *posts) {
             
             [self.postsArray removeAllObjects];
             
             if ([posts count] > 1) {
                 
                 self.countOfPosts = [posts firstObject];
                 
                 posts = [posts subarrayWithRange:NSMakeRange(1, (int)[posts count] - 1)];
                 
                 [self.postsArray addObjectsFromArray:posts];
                 
             } else {
                 
                 self.postsArray = nil;
             }
             
             [self getPostOwnerUserProfilesFromServer];
             
             [self getPostOwnerGroupProfilesFromServer];
             
             [self getPostCopyOwnerUserProfilesFromServer];
             
             [self getPostCopyOwnerGroupProfilesFromServer];
             
             [self.refreshControl endRefreshing];
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
             [self.refreshControl endRefreshing];
         }];
        
    }
    
}

// that method gets detailed information about every user (who is post owner) on the current user wall
- (void)getPostOwnerUserProfilesFromServer {
    
    NSString *userUidsString = [self formUserUidsStringForID:@"ownerID"];
   
    if ([userUidsString length] > 0) {
        
        [[OPServerManager sharedManager]
         getUsersWithUidsArray:userUidsString
         onSuccess:^(NSArray *users) {
             
             [self.postOwnersUsersArray addObjectsFromArray:users];
             
             for (OPUser *user in self.postOwnersUsersArray) {
                 
                 for (OPPost *post in self.postsArray) {
                     
                     if (post.ownerID == user.ID) {
                         
                         post.postOwnerUser = user;
                     }
                     
                 }
             }
             
             [self.tableView reloadData];
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
        
    }
}

// that method gets detailed information about every group (who is post owner) on the current user wall
- (void)getPostOwnerGroupProfilesFromServer {
    
    NSString *groupUidsString = [self formGroupUidsStringForID:@"ownerID"];
    
    if ([groupUidsString length] > 0) {
        
        [[OPServerManager sharedManager]
         getGroupsWithUidsArray:groupUidsString
         onSuccess:^(NSArray *groups) {
             
             [self.postOwnersGroupsArray addObjectsFromArray:groups];
             
             for (OPGroup *group in self.postOwnersGroupsArray) {
                 
                 for (OPPost *post in self.postsArray) {
                     
                     if ((0 - post.ownerID) == group.ID) {
                         
                         post.postOwnerGroup = group;
                     }
                     
                 }
             }
             
             [self.tableView reloadData];
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
        
    }
}

// that method gets detailed information about every user (who is copy_owner) on the current user wall
- (void)getPostCopyOwnerUserProfilesFromServer {
    
    NSString *userCopyOwnerUidsString = [self formUserUidsStringForID:@"copyOwnerID"];
    
    if ([userCopyOwnerUidsString length] > 0) {
        
        [[OPServerManager sharedManager]
         getUsersWithUidsArray:userCopyOwnerUidsString
         onSuccess:^(NSArray *users) {
             
             [self.userCopyOwnersArray addObjectsFromArray:users];
             
             for (OPUser *user in self.userCopyOwnersArray) {
                 
                 for (OPPost *post in self.postsArray) {
                     
                     if (post.copyOwnerID == user.ID) {
                         
                         post.postCopyOwnerUser = user;
                     }
                     
                 }
             }
             
             [self.tableView reloadData];
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
        
    }
}

// that method gets detailed information about every group (who is copy_owner) on the current user wall
- (void)getPostCopyOwnerGroupProfilesFromServer {
    
    NSString *groupCopyOwnerUidsString = [self formGroupUidsStringForID:@"copyOwnerID"];
    
    if ([groupCopyOwnerUidsString length] > 0) {
        
        [[OPServerManager sharedManager]
         getGroupsWithUidsArray:groupCopyOwnerUidsString
         onSuccess:^(NSArray *groups) {
             
             [self.groupCopyOwnersArray addObjectsFromArray:groups];
             
             for (OPGroup *group in self.groupCopyOwnersArray) {
                 
                 for (OPPost *post in self.postsArray) {
                     
                     if ( (0 - post.copyOwnerID) == group.ID) {
                         
                         post.postCopyOwnerGroup = group;
                     }
                 }
                 
             }
             
             [self.tableView reloadData];
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
        
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // there 2 additional cells (first - for adding a new post to the wall, last - to get more posts from server)
    return [self.postsArray count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!indexPath.row) {
        
        static NSString *identifier = @"AddPostCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        [cell addSubview:self.postField];
        
        self.postField.placeholder = @"Напишите сообщение...";
        
        [cell addSubview:self.postButton];
        
        return cell;
        
    } else if (indexPath.row == ([self.postsArray count] + 1)) {
        
        static NSString *identifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.textLabel.text = @"LOAD MORE";
        
        return cell;
        
    } else {
        
        OPPost *post = [self.postsArray objectAtIndex:(indexPath.row - 1)];
        
        static NSString *identifier = @"PostCell";
        
        OPPostDrawingCell *cell = [[OPPostDrawingCell alloc] initWithPost:post reuseIdentifier:identifier];
        
        // loading image for cell.postOwnerImageView
        
        NSURL *imageURL = [[NSURL alloc] init];
        
        if (post.ownerID > 0) {
            
            imageURL = post.postOwnerUser.imageURL;
            
        } else {
            
            imageURL = post.postOwnerGroup.imageURL;
        }
        
        // we need to use methods from AFNetworking (UIImageView+AFNetworking.h)
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        
        cell.postOwnerImageView.image = nil;
        
        __weak OPPostDrawingCell *weakCell = cell;
        
        [cell.postOwnerImageView
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             
             weakCell.postOwnerImageView.image = image;
             
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];
        
        // loading image for cell.postCopyOwnerImageView
        
        if (post.copyOwnerID != 0) {
            
            NSURL *postCopyOwnerImageURL = [[NSURL alloc] init];
            
            if (post.copyOwnerID > 0) {
                
                postCopyOwnerImageURL = post.postCopyOwnerUser.imageURL;
                
            } else {
                
                postCopyOwnerImageURL = post.postCopyOwnerGroup.imageURL;
            }
            
            NSURLRequest *copyOwnerImageRequest = [NSURLRequest requestWithURL:postCopyOwnerImageURL];
            
            cell.postCopyOwnerImageView.image = nil;
            
            [cell.postCopyOwnerImageView
             setImageWithURLRequest:copyOwnerImageRequest
             placeholderImage:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                 
                 weakCell.postCopyOwnerImageView.image = image;
             }
             
             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                 
             }];
            
        }
        
        // loading image for cell.attachmentImageView
        
        if ([post.attachment count]) {
            
            NSURL *attachmentImageURL = [[NSURL alloc] init];
            
            id attachment = [post.attachment firstObject];
            
            if ([attachment isKindOfClass:[OPAttachmentPhoto class]]) {
                
                OPAttachmentPhoto *attachmentPhoto = (OPAttachmentPhoto *)attachment;
                
                if (attachmentPhoto.srcBigURL) {
                    
                    attachmentImageURL = attachmentPhoto.srcBigURL;
                    
                } else if (attachmentPhoto.srcURL) {
                    
                    attachmentImageURL = attachmentPhoto.srcURL;
                }
                
            } else if ([attachment isKindOfClass:[OPAttachmentVideo class]]) {
                
                OPAttachmentVideo *attachmentVideo = (OPAttachmentVideo *)attachment;
                
                if (attachmentVideo.imageURL) {
                    
                    attachmentImageURL = attachmentVideo.imageURL;
                    
                }
                
            }
            
            NSURLRequest *attachmentImageRequest = [NSURLRequest requestWithURL:attachmentImageURL];
            
            cell.attachmentImageView.image = nil;
            
            [cell.attachmentImageView
             setImageWithURLRequest:attachmentImageRequest
             placeholderImage:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                 
                 weakCell.attachmentImageView.image = image;
             }
             
             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                 
             }];
            
        }
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( (indexPath.row == ([self.postsArray count] + 1)) && ([self.postsArray count] < [self.countOfPosts intValue]) ) {
        
        [self getPostsFromServer];
        
    } else {
        
        OPPostProfileViewController *postProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OPPostProfileViewController"];
        
        OPPost *post = [self.postsArray objectAtIndex:(indexPath.row - 1)];
        
        // Examples of posts:
        // 93388_21539,93388_20904,-1_340364
        
        NSMutableString *postID = [NSMutableString stringWithFormat:@"%i", post.ownerID];
        [postID appendFormat:@"_%i", post.postID];
        
        postProfileVC.postID = [postID copy];

        [self presentViewController:postProfileVC
                           animated:YES
                         completion:nil];
        
    }
}

// we need that method to count height for each cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( (indexPath.row == ([self.postsArray count] + 1)) || (!indexPath.row) ) {
        
        return 44.f;
        
    } else {
        
        OPPost *post = [self.postsArray objectAtIndex:(indexPath.row - 1)];
        
        return [OPPostDrawingCell heightForPost:post];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.postField]) {
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - OPServerManagerDelegate

- (void)ownerIDForWallIsFound:(OPServerManager *) manager {
    
    self.currentUserID = manager.currentUserID;
    
    [self getPostsFromServer];
    
}

#pragma mark - Actions

// that method adds a new post to the current user wall
- (void)actionPost:(UIButton *)sender {
    
    if (self.postField.text.length > 0) {
        
        [[OPServerManager sharedManager]
         postText:self.postField.text
         onUserWall:self.currentUserID
         onSuccess:^(id result) {
             
             UIAlertView *postHasBeenSentAlert = [[UIAlertView alloc]
                                                  initWithTitle:@"Поздравляем!"
                                                  message:@"Ваше сообщение успешно отправлено на стену!"
                                                  delegate:self
                                                  cancelButtonTitle:@"Закрыть"
                                                  otherButtonTitles:nil];
             
             [postHasBeenSentAlert show];
             
             self.postField.text = nil;
             self.postField.placeholder = @"Напишите сообщение...";
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
        
    }
}

@end
