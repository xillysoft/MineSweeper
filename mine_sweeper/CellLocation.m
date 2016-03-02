//
//  CellLocation.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/28/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "CellLocation.h"

@implementation CellLocation

-(instancetype)init
{
    self = [super init];
    if(self){
        _row = 0;
        _column = 0;
    }
    return self;
}

-(instancetype)initWithRow:(int)row column:(int)column
{
    self = [super init];
    if(self){
        _row = row;
        _column = column;
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"CellLocation[%d, %d]", self.row, self.column];
}

@end
