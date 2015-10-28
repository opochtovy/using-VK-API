//
//  OPPostDrawingCell.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 12.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPPost;

@interface OPPostDrawingCell : UITableViewCell

@property (strong, nonatomic) OPPost *post;

@property (strong, nonatomic) UIImageView *postOwnerImageView;
@property (strong, nonatomic) UIImageView *postCopyOwnerImageView;
@property (strong, nonatomic) UIImageView *attachmentImageView;

- (id)initWithPost:(OPPost *)post reuseIdentifier:(NSString *)identifier;

+ (CGFloat) heightForPost:(OPPost *) post;

@end
