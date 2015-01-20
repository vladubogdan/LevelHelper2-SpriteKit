//
//  LHContactInfo.h
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 20/01/15.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "LHConfig.h"

#if LH_USE_BOX2D

#ifdef __cplusplus
class b2Contact;
#endif

@interface LHContactInfo : NSObject


+(instancetype)contactInfoWithNodeA:(SKNode*)a
                              nodeB:(SKNode*)b
                         shapeAName:(NSString*)aName
                         shapeBName:(NSString*)bName
                           shapeAID:(int)aID
                           shapeBID:(int)bID
                              point:(CGPoint)pt
                            impulse:(float)i
                          b2Contact:(b2Contact*)contact;

-(SKNode*)nodeA;
-(SKNode*)nodeB;

-(NSString*)nodeAShapeName;
-(NSString*)nodeBShapeName;

-(int)nodeAShapeID;
-(int)nodeBShapeID;

-(CGPoint)contactPoint;
-(float)impulse;

-(b2Contact*)box2dContact;

@end

#endif