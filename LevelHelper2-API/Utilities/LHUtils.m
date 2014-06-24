//
//  LHUtils.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 25/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHUserPropertyProtocol.h"
#import "LHAnimation.h"
#import "LHGameWorldNode.h"

@implementation LHUtils

+(id)userPropertyForNode:(id)node fromDictionary:(NSDictionary*)dict
{
    id _userProperty = nil;
    
    NSDictionary* userPropInfo = [dict objectForKey:@"userPropertyInfo"];
    NSString* userPropClassName = [dict objectForKey:@"userPropertyName"];
    if(userPropInfo && userPropClassName)
    {
        Class userPropClass = NSClassFromString(userPropClassName);
        if(userPropClass){
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
            _userProperty = [userPropClass performSelector:@selector(customClassInstanceWithNode:)
                                                withObject:node];
    #pragma clang diagnostic pop
            if(_userProperty){
                [_userProperty setPropertiesFromDictionary:userPropInfo];
            }
        }
    }
    
    return _userProperty;
}

+(void)tagsFromDictionary:(NSDictionary*)dict
             savedToArray:(NSArray* __strong*)_tags
{
    NSArray* loadedTags = [dict objectForKey:@"tags"];
    if(loadedTags){
        *_tags = [[NSArray alloc] initWithArray:loadedTags];
    }
}

+(void)createAnimationsForNode:(id)node
               animationsArray:(NSMutableArray* __strong*)_animations
               activeAnimation:(LHAnimation* __weak*)activeAnimation
                fromDictionary:(NSDictionary*)dict
{
    NSArray* animsInfo = [dict objectForKey:@"animations"];
    for(NSDictionary* anim in animsInfo){
        if(!*_animations){
            *_animations = [[NSMutableArray alloc] init];
        }
        LHAnimation* animation = [LHAnimation animationWithDictionary:anim
                                                                 node:node];
        if([animation isActive]){
            *activeAnimation = animation;
        }
        [*_animations addObject:animation];
    }

}

+(NSString*)imagePathWithFilename:(NSString*)filename
                           folder:(NSString*)folder
                           suffix:(NSString*)suffix
{
    NSString* ext = [filename pathExtension];
    NSString* fileNoExt = [filename stringByDeletingPathExtension];
#if TARGET_OS_IPHONE
    return [[[folder stringByAppendingString:fileNoExt] stringByAppendingString:suffix] stringByAppendingPathExtension:ext];
#else
    NSString* fileName = [fileNoExt stringByAppendingString:suffix];
    NSString* val = [[NSBundle mainBundle] pathForResource:fileName ofType:ext inDirectory:folder];
    if(!val){
        return fileName;
    }
    return val;
#endif
}

+(NSString*)devicePosition:(NSDictionary*)availablePositions forSize:(CGSize)curScr{
//    CGSize curScr = LH_SCREEN_RESOLUTION;
    return [availablePositions objectForKey:[NSString stringWithFormat:@"%dx%d", (int)curScr.width, (int)curScr.height]];
}

+(CGPoint)positionForNode:(SKNode*)node
                 fromUnit:(CGPoint)unitPos
{
    LHScene* scene = (LHScene*)[node scene];
    
    CGSize designSize = [scene designResolutionSize];
    CGPoint offset = [scene designOffset];
    
    CGPoint designPos = CGPointZero;
    

    designPos = CGPointMake(designSize.width*unitPos.x,
                            designSize.height*(-unitPos.y));

    if([node parent] == nil || [node parent] == scene || [node parent] == [scene gameWorldNode])
    {
        designPos.x += offset.x;
        designPos.y -= offset.y;
    }

    return designPos;
}

#if TARGET_OS_IPHONE
+(LHDevice*)currentDeviceFromArray:(NSArray*)arrayOfDevs{
    return [LHUtils deviceFromArray:arrayOfDevs
                           withSize:LH_SCREEN_RESOLUTION];
}
#endif

+(LHDevice*)deviceFromArray:(NSArray*)arrayOfDevs
                   withSize:(CGSize)size
{
    for(LHDevice* dev in arrayOfDevs){
        if(CGSizeEqualToSize([dev size], size)){
            return dev;
        }
    }
    return nil;
}

@end


@implementation LHDevice

-(void)dealloc{
    LH_SAFE_RELEASE(suffix);
    LH_SUPER_DEALLOC();
}

+(id)deviceWithDictionary:(NSDictionary*)dict{
    return LH_AUTORELEASED([[LHDevice alloc] initWithDictionary:dict]);
}
-(id)initWithDictionary:(NSDictionary*)dict{
    if(self = [super init]){
        
        size = [dict sizeForKey:@"size"];
        suffix = [[NSString alloc] initWithString:[dict objectForKey:@"suffix"]];
        ratio = [dict floatForKey:@"ratio"];
        
    }
    return self;
}

-(CGSize)size{
    return size;
}
-(NSString*)suffix{
    return suffix;
}
-(float)ratio{
    return ratio;
}

@end


