//
//  OneDay+CoreDataProperties.m
//  app3
//
//  Created by Admin on 16.09.17.
//  Copyright © 2017 Admin. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "OneDay+CoreDataProperties.h"

@implementation OneDay (CoreDataProperties)

+ (NSFetchRequest<OneDay *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"OneDay"];
}

@dynamic aerobic;
@dynamic date;
@dynamic run;
@dynamic walk;

@end
