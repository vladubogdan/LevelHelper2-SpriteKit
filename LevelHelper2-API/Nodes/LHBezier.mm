//
//  LHBezier.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHBezier.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

static float MAX_BEZIER_STEPS = 24.0f;

@implementation LHBezier
{
    NSMutableArray*             _linePoints;
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_linePoints);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(_physicsProtocolImp);
    
    LH_SUPER_DEALLOC();
}


+ (instancetype)bezierNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initBezierNodeWithDictionary:dict
                                                               parent:prnt]);
}

- (instancetype)initBezierNodeWithDictionary:(NSDictionary*)dict
                                      parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _linePoints = [[NSMutableArray alloc] init];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        self.strokeColor = [dict colorForKey:@"colorOverlay"];
        
        
        NSArray* points = [dict objectForKey:@"points"];
        BOOL closed = [dict boolForKey:@"closed"];
        
        CGMutablePathRef linePath = nil;
        NSDictionary* previousPointDict = nil;
        for(NSDictionary* pointDict in points)
        {
            if(previousPointDict != nil)
            {
                CGPoint control1 = [previousPointDict pointForKey:@"ctrl2"];
                if(![previousPointDict boolForKey:@"hasCtrl2"]){
                    control1 = [previousPointDict pointForKey:@"mainPt"];
                }
                
                CGPoint control2 = [pointDict pointForKey:@"ctrl1"];
                if(![pointDict boolForKey:@"hasCtrl1"]){
                    control2 = [pointDict pointForKey:@"mainPt"];
                }
                
                CGPoint vPoint = {0.0f, 0.0f};
                for(float t = 0.0; t <= (1 + (1.0f / MAX_BEZIER_STEPS)); t += 1.0f / MAX_BEZIER_STEPS)
                {
                    vPoint = LHPointOnCurve([previousPointDict pointForKey:@"mainPt"],
                                            control1,
                                            control2,
                                            [pointDict pointForKey:@"mainPt"],
                                            t);
                    
                    if(!linePath){
                        linePath = CGPathCreateMutable();
                        CGPathMoveToPoint(linePath, nil, vPoint.x, -vPoint.y);
                        [_linePoints addObject:LHValueWithCGPoint(CGPointMake(vPoint.x, -vPoint.y))];
                    }
                    else{
                        CGPathAddLineToPoint(linePath, nil, vPoint.x, -vPoint.y);
                        [_linePoints addObject:LHValueWithCGPoint(CGPointMake(vPoint.x, -vPoint.y))];
                    }
                }
            }
            previousPointDict = pointDict;
        }
        if(closed){
            if([points count] > 1)
            {
                NSDictionary* ptDict = [points objectAtIndex:0];
                
                CGPoint control1 = [previousPointDict pointForKey:@"ctrl2"];
                if(![previousPointDict boolForKey:@"hasCtrl2"]){
                    control1 =  [previousPointDict pointForKey:@"mainPt"];
                }
                
                CGPoint control2 = [ptDict pointForKey:@"ctrl1"];
                if(![ptDict boolForKey:@"hasCtrl1"]){
                    control2 = [ptDict pointForKey:@"mainPt"];
                }
                
                CGPoint vPoint = {0.0f, 0.0f};
                for(float t = 0; t <= (1 + (1.0f / MAX_BEZIER_STEPS)); t += 1.0f / MAX_BEZIER_STEPS)
                {
                    vPoint = LHPointOnCurve([previousPointDict pointForKey:@"mainPt"],
                                            control1,
                                            control2,
                                            [ptDict pointForKey:@"mainPt"],
                                            t);
                 
                    if(linePath){
                        CGPathAddLineToPoint(linePath, nil, vPoint.x, -vPoint.y);
                        [_linePoints addObject:LHValueWithCGPoint(CGPointMake(vPoint.x, -vPoint.y))];
                    }
                }
            }
        }
        
        if(linePath){
            self.path = linePath;
            CGPathRelease(linePath);
        }

        
#if LH_USE_BOX2D
        {
            CGPoint scl = [dict pointForKey:@"scale"];
            [self setXScale:scl.x];
            [self setYScale:scl.y];
        }
#endif
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        //scale must be set after loading the physic info or else spritekit will not resize the sprite anymore - bug
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setXScale:scl.x];
        [self setYScale:scl.y];
        
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
    }
    
    return self;
}

-(NSMutableArray*)linePoints{
    return _linePoints;
}

-(CGSize)size{
    return CGPathGetBoundingBox(self.path).size;
}

-(CGRect)boundingBox{
    return CGPathGetBoundingBox(self.path);
}

#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D


#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    [_physicsProtocolImp update:currentTime delta:dt];
    [_nodeProtocolImp update:currentTime delta:dt];
    [_animationProtocolImp update:currentTime delta:dt];
}


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
