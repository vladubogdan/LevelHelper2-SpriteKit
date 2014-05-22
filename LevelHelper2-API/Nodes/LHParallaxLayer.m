//
//  LHParallaxLayer.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHParallaxLayer.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHParallax.h"

@implementation LHParallaxLayer
{
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;
    
    float _xRatio;
    float _yRatio;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);
    LH_SUPER_DEALLOC();
}


+ (instancetype)parallaxLayerWithDictionary:(NSDictionary*)dict
                                parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initParallaxLayerWithDictionary:dict
                                                                  parent:prnt]);
}

- (instancetype)initParallaxLayerWithDictionary:(NSDictionary*)dict
                                         parent:(SKNode*)prnt{
    
    if(self = [super init]){
                
        [prnt addChild:self];
        [self setName:[dict objectForKey:@"name"]];
    
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {
            
#if TARGET_OS_IPHONE
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:LH_SCREEN_RESOLUTION];
#else
            LHScene* scene = (LHScene*)[self scene];
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
#endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZPosition:z];
        
        _xRatio = [dict floatForKey:@"xRatio"];
        _yRatio = [dict floatForKey:@"yRatio"];
        
        NSArray* childrenInfo = [dict objectForKey:@"children"];
        if(childrenInfo)
        {
            for(NSDictionary* childInfo in childrenInfo)
            {
                SKNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                            parent:self];
#pragma unused (node)
            }
        }
    }
    
    return self;
}

-(float)xRatio{
    return _xRatio;
}

-(float)yRatio{
    return _yRatio;
}

#pragma mark LHNodeProtocol Required

-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(SKNode*)childNodeWithUUID:(NSString*)uuid{
    return [LHScene childNodeWithUUID:uuid
                              forNode:self];
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any{
    return [LHScene childrenWithTags:tagValues containsAny:any forNode:self];
}


-(NSMutableArray*)childrenOfType:(Class)type{
    return [LHScene childrenOfType:type
                           forNode:self];
}

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    
}
@end
