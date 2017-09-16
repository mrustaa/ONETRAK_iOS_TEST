//
//  CellPrototype.h
//  app3
//
//  Created by Admin on 15.09.17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CellPrototype : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *ViewCell;

@property (strong, nonatomic) IBOutlet UIView *MyProgressBar;
@property (strong, nonatomic) IBOutlet UIView  *bar1view;
@property (strong, nonatomic) IBOutlet UIView  *bar2view;
@property (strong, nonatomic) IBOutlet UIView  *bar3view;

@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelProgress;

@property (strong, nonatomic) IBOutlet UILabel *labelWalkCount;
@property (strong, nonatomic) IBOutlet UILabel *labelAerobicCount;
@property (strong, nonatomic) IBOutlet UILabel *labelRunCount;

@property (strong, nonatomic) IBOutlet UIImageView *imageStar;
@property (strong, nonatomic) IBOutlet UIView *separatorLine;

@end
