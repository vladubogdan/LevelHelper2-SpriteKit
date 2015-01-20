//
//  LHContactInfo.m
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 20/01/15.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHContactInfo.h"
#import "LHUtils.h"

#if LH_USE_BOX2D

#include "Box2d/Box2D.h"

@implementation LHContactInfo
{
    __weak SKNode*  _nodeA;
    __weak SKNode*  _nodeB;
    NSString*       _shapeAName;
    NSString*       _shapeBName;
    int             _shapeAID;
    int             _shapeBID;
    b2Contact*      _b2Contact;
    CGPoint         _contactPoint;
    float           _impulse;
    BOOL            _marked;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_shapeAName);
    LH_SAFE_RELEASE(_shapeBName);
    
    _nodeA = nil;
    _nodeB = nil;
    _b2Contact = nil;
    
    LH_SUPER_DEALLOC();
}

+(instancetype)contactInfoWithNodeA:(SKNode*)a
                              nodeB:(SKNode*)b
                         shapeAName:(NSString*)aName
                         shapeBName:(NSString*)bName
                           shapeAID:(int)aID
                           shapeBID:(int)bID
                              point:(CGPoint)pt
                            impulse:(float)i
                          b2Contact:(b2Contact*)contact
{
    return LH_AUTORELEASED([[LHContactInfo alloc] initWithNodeA:a
                                                          nodeB:b
                                                     shapeAName:aName
                                                     shapeBName:bName
                                                       shapeAID:aID
                                                       shapeBID:bID
                                                          point:pt
                                                        impulse:i
                                                      b2Contact:contact]);
}


-(instancetype)initWithNodeA:(SKNode*)a
                       nodeB:(SKNode*)b
                  shapeAName:(NSString*)aName
                  shapeBName:(NSString*)bName
                    shapeAID:(int)aID
                    shapeBID:(int)bID
                       point:(CGPoint)pt
                     impulse:(float)i
                   b2Contact:(b2Contact*)contact
{
    if(self = [super init])
    {
        _nodeA  = a;
        _nodeB  = b;
        _contactPoint = pt;
        _impulse = i;
        _b2Contact = contact;
        if(aName){
            _shapeAName = [[NSString alloc] initWithString:aName];
        }
        if(bName){
            _shapeBName = [[NSString alloc] initWithString:bName];
        }

        _shapeAID = aID;
        _shapeBID = bID;
    }
    return self;
}

-(void)setMarked{_marked = true;}
-(BOOL)marked{return _marked;}

-(SKNode*)nodeA{return _nodeA;}
-(SKNode*)nodeB{return _nodeB;}

-(CGPoint)contactPoint{return _contactPoint;}
-(float)impulse{return _impulse;}

-(NSString*)nodeAShapeName{return _shapeAName;}
-(NSString*)nodeBShapeName{return _shapeBName;}

-(int)nodeAShapeID{return _shapeAID;}
-(int)nodeBShapeID{return _shapeBID;}

-(b2Contact*)box2dContact{return _b2Contact;}

@end

#endif
