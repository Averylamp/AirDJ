//
//  RWGameData.m
//  GreenRedBlackGame
//
//  Created by Avery Lamp on 1/2/15.
//  Copyright (c) 2015 Avery Lamp. All rights reserved.
//

#import "RWGameData.h"

@implementation RWGameData

static NSString* const SSGameDataActiveSpriteDictionary = @"activeSpriteDictionary";
static NSString* const SSGameDataBasePath = @"basePath";
-(void)reset
{

}
+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

-(NSMutableDictionary * )activeSpriteDictionary
{
    if(!_songUrl){
        _songUrl = [[NSMutableDictionary alloc]init];
    }
    return _songUrl;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    if(self.activeSpriteDictionary){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.activeSpriteDictionary];
        [aCoder encodeObject:data forKey:SSGameDataActiveSpriteDictionary];
    }
    if (self.basePath) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.basePath];
        [aCoder encodeObject:data forKey:SSGameDataBasePath];
    }
    
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.songUrl = [NSKeyedUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:SSGameDataActiveSpriteDictionary]];
        self.basePath = [NSKeyedUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:SSGameDataBasePath]];
    }
    return self;
}
+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [RWGameData filePath]];
    if (decodedData) {
        RWGameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[RWGameData alloc] init];
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gameData"];
    }
    return filePath;
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[RWGameData filePath] atomically:YES];
}
@end
