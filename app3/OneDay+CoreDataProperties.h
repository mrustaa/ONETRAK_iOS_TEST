//
//  OneDay+CoreDataProperties.h
//  app3
//
//  Created by Admin on 16.09.17.
//  Copyright © 2017 Admin. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "OneDay+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OneDay (CoreDataProperties)

+ (NSFetchRequest<OneDay *> *)fetchRequest;

@property (nonatomic) int16_t aerobic;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) int16_t run;
@property (nonatomic) int16_t walk;

@end

NS_ASSUME_NONNULL_END
