//
//  OPAttachmentPhoto.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 18.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPServerObject.h"

@interface OPAttachmentPhoto : OPServerObject

@property (assign, nonatomic) NSInteger height;
@property (assign, nonatomic) NSInteger width;
@property (strong, nonatomic) NSURL *photo75URL;
@property (strong, nonatomic) NSURL *photo130URL;
@property (strong, nonatomic) NSURL *photo604URL;
@property (strong, nonatomic) NSURL *photo807URL;

@property (strong, nonatomic) NSURL *srcURL;
@property (strong, nonatomic) NSURL *srcBigURL;

@end
