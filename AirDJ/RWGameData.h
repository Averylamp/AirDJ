//
//  RWGameData.h
//  GreenRedBlackGame
//
//  Created by Avery Lamp on 1/2/15.
//  Copyright (c) 2015 Avery Lamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface RWGameData : NSObject<NSCoding>
@property (nonatomic) NSMutableDictionary* songUrl;
@property NSString *basePath;
+(instancetype)sharedGameData;
-(void)save;
@end
