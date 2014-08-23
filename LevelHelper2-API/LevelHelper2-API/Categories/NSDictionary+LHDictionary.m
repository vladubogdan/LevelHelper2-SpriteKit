//
//  NSDictionary+LHDictionary.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 25/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "NSDictionary+LHDictionary.h"
#import <SpriteKit/SpriteKit.h>
#import "LHUtils.h"

@implementation NSDictionary (LHDictionary)


-(float) floatForKey:(NSString*)key{
    
    NSNumber* val = [self objectForKey:key];
    
    if(nil == val)
        NSLog(@"Float for key %@ is not available", key);
    
    return [val floatValue]; //if key is not available it will return 0.0f
}
-(int) intForKey:(NSString*)key{
    
    NSNumber* val = [self objectForKey:key];
    
    if(nil == val)
        NSLog(@"Int for key %@ is not available", key);
    
    return [val intValue]; //if key is not available it will return 0
}
-(bool) boolForKey:(NSString*)key{
    NSNumber* val = [self objectForKey:key];
    
    if(nil == val)
    {
        NSLog(@"Bool for key %@ is not available", key);
    }
    
    return [val boolValue]; //if key is not available it will return false
}
-(CGPoint) pointForKey:(NSString*)key{
    NSString* val = [self objectForKey:key];
    
    if(nil == val)
    {
        NSLog(@"CGPoint for key %@ is not available", key);
        return CGPointZero;
    }
    
    return LHPointFromString(val);
}
-(CGRect) rectForKey:(NSString*)key{
    
    NSString* val = [self objectForKey:key];
    
    if(nil == val)
    {
        NSLog(@"CGRect for key %@ is not available", key);
        return CGRectZero;
    }
    
    return LHRectFromString(val);
}
-(CGSize) sizeForKey:(NSString*)key{
    NSString* val = [self objectForKey:key];
    
    if(nil == val)
    {
        NSLog(@"CGSize for key %@ is not available", key);
        return CGSizeZero;
    }
    
    return LHSizeFromString(val);
    
}
-(SKColor*) colorForKey:(NSString*)key{
    
    NSString* val = [self objectForKey:key];
    
    if(nil == val)
    {
        NSLog(@"SKColor for key %@ is not available", key);
        return [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    
    CGRect rect = LHRectFromString(val);
    
    return [SKColor colorWithRed:rect.origin.x
                           green:rect.origin.y
                            blue:rect.size.width
                           alpha:1.0f];
}

-(NSString*)stringForKey:(id)key{
    
    NSString* str = [self objectForKey:key];
    
    if(nil == str){
        NSLog(@"NSString for key %@ is not available", key);
        return @"";
    }
    return str;
}


@end
