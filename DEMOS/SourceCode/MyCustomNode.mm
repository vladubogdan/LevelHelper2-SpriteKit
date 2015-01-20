//
//  MyCustomNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 25/08/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "MyCustomNode.h"

@implementation MyCustomNode

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    
    self = [super initWithDictionary:dict parent:prnt];
    if(self)
    {
        //init your content here
        NSLog(@"Did create object of type %@ with name %@", NSStringFromClass([self class]), [self name]);
        
        [self addChildRepresentation];
    }
    return self;
}

-(void) addChildRepresentation
{
    CGSize _size = [self size];
    
    SKShapeNode* debugShapeNode = [SKShapeNode node];
    CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(-_size.width*0.5,
                                                        -_size.height*0.5,
                                                        _size.width,
                                                        _size.height),
                                             nil);
    debugShapeNode.path = pathRef;
    CGPathRelease(pathRef);
    debugShapeNode.strokeColor = [SKColor blueColor];
    [self addChild:debugShapeNode];
}

@end
