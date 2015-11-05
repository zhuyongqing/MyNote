//
//  MynoteModel+CoreDataProperties.h
//  MyNote
//
//  Created by zhuyongqing on 15/10/20.
//  Copyright © 2015年 zhuyongqing. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MynoteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MynoteModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber *textNum;
@property (nullable, nonatomic, retain) NSString *imageName;
@property (nullable, nonatomic, retain) NSString *trueTime;
@property (nullable, nonatomic, retain) NSString *isHaveLogin;

@end

NS_ASSUME_NONNULL_END
