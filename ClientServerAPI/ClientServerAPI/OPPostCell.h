//
//  OPPostCell.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;

+ (CGFloat) heightForText:(NSString *)text;

@end
