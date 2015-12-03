//
//  main.m
//  Pazzle
//
//  Created by Admin on 03.12.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NSInteger n = 4;
NSInteger canonical_matrix[4][4];
NSInteger linear_cols[4][4];

@interface Puzzle:NSObject

-(void)calcCanonicalMatrix:(NSInteger)N;
-(NSInteger)getHeuristic:(NSArray*)matrix;
-(NSInteger)getManhattanDistance:(NSArray*)matrix;
-(NSInteger)getLinearConflict:(NSArray*)matrix;
-(NSInteger)getCornerConflict:(NSArray*)matrix;
-(NSMutableArray*)getSolution:(NSInteger)limit
                             :(NSMutableArray*)solution
                             :(NSMutableArray*)matrix
                             :(NSInteger)x_space
                             :(NSInteger)y_space;

@property (nonatomic, strong) NSMutableArray *linear_conflicts;
@property (nonatomic, strong) NSMutableArray *manhatten_array;
@property (nonatomic, strong) NSMutableArray *solution;
@property (nonatomic, strong) NSArray *RESULT;
@end

@implementation Puzzle


- (void)calcCanonicalMatrix:(NSInteger)N
{
    NSInteger canonical_matrix[n][n];
    NSInteger linear_cols[n][n];
    NSPoint manhattenPoint = CGPointMake(2, 2);
    [self.manhatten_array addObject:[NSValue valueWithPoint:manhattenPoint ]];
    NSInteger value = 1;
    for (NSInteger i = 0; i < n; i++)
    {
        for (NSInteger j = 0; j < n; j++)
        {
            canonical_matrix[i][j] = value;
            linear_cols[j][i] = value;
            if (value == n*n)
            {
                value = 0;
            }
            
            manhattenPoint = CGPointMake(i, j);
            [self.manhatten_array addObject:[NSValue valueWithPoint:manhattenPoint]];
            canonical_matrix[i][j] = value;
            linear_cols[j][i] = value;
            value++;
        }
    }
}




- (NSInteger)getHeuristic:(NSArray*)matrix
{
    self.linear_conflicts = [NSMutableArray array];
    NSInteger heuristic = 0;
    heuristic += [self getManhattanDistance:matrix];
    if(heuristic == 0)
    {
        return 0;
    }
    //We can use another heuristic methods linear conflict and corner conflict
    /*
     heuristic += [self getLinearConflict:matrix];
     heuristic += [self getCornerConflict:matrix];
     */
    return heuristic;
}


-(NSInteger)getManhattanDistance:(NSArray*)matrix
{
    NSInteger distance = 0;
    NSInteger value, canonical_x, canonical_y;
    for(NSInteger i = 0; i < n; i++)
    {
        for(NSInteger j = 0; j < n; j++)
        {
            value = [[[matrix objectAtIndex:i] objectAtIndex:j] integerValue];
            NSValue *valuePoint;
            valuePoint =self.manhatten_array[value];
            CGPoint point = [valuePoint pointValue];
            canonical_x = point.x;
            canonical_y = point.y;
            
            if(value!=0)
            {
                distance += labs(canonical_x - i) + labs(canonical_y - j);
            }
        }
    }
    
    if(distance == 2)
    {
        distance-=1;
    }
    return distance;
}


-(NSInteger)getLinearConflict:(NSArray*)matrix
{
    
    NSInteger linear_cols[4][4] = {{[[[matrix objectAtIndex:0] objectAtIndex:0] integerValue],
        [[[matrix objectAtIndex:1] objectAtIndex:0] integerValue],
        [[[matrix objectAtIndex:2] objectAtIndex:0] integerValue],
        [[[matrix objectAtIndex:3] objectAtIndex:0] integerValue]},
        {[[[matrix objectAtIndex:0] objectAtIndex:1] integerValue],
            [[[matrix objectAtIndex:1] objectAtIndex:1] integerValue],
            [[[matrix objectAtIndex:2] objectAtIndex:1] integerValue],
            [[[matrix objectAtIndex:3] objectAtIndex:1] integerValue]},
        {[[[matrix objectAtIndex:0] objectAtIndex:2] integerValue],
            [[[matrix objectAtIndex:1] objectAtIndex:2] integerValue],
            [[[matrix objectAtIndex:2] objectAtIndex:2] integerValue],
            [[[matrix objectAtIndex:3] objectAtIndex:2] integerValue]},
        {[[[matrix objectAtIndex:0] objectAtIndex:3] integerValue],
            [[[matrix objectAtIndex:1] objectAtIndex:3] integerValue],
            [[[matrix objectAtIndex:2] objectAtIndex:3] integerValue],
            [[[matrix objectAtIndex:3] objectAtIndex:3] integerValue]}};
    
    NSInteger conflict = 0;
    NSInteger value, conflict_value;
    for(NSInteger i = 0; i < n; i++)
    {
        for(NSInteger j = 0; j < n; j++)
        {
            value = [[[matrix objectAtIndex:i] objectAtIndex:j] integerValue];
            if ([self inArrayCanonical_matrix:value :canonical_matrix[i]])
            {
                for(NSInteger k = i+1; k < n; k++)
                {
                    conflict_value = [[[matrix objectAtIndex:i] objectAtIndex:k] integerValue];
                    if([self inArrayCanonical_matrix:conflict_value
                                                    :canonical_matrix[i]] && value > conflict_value)
                    {
                        conflict += 2;
                        [self.linear_conflicts addObject: [NSNumber numberWithInteger: value]];
                    }
                }
            }
            
            if(![self inArrayMassive:value
                                    :self.linear_conflicts] && [self inArrayCanonical_matrix
                                                                :value
                                                                :linear_cols[i]])
            {
                for(NSInteger k = j+1; k < n; k++)
                {
                    conflict_value = [[[matrix objectAtIndex:k] objectAtIndex:j] integerValue];
                    if ([self inArrayCanonical_matrix:conflict_value
                                                     :linear_cols[j]] && value > conflict_value)
                    {
                        conflict += 2;
                    }
                }
            }
        }
    }
    
    return conflict;
    
    
}

-(NSInteger)getCornerConflict:(NSArray*)matrix
{
    NSInteger conflict = 0;
    // checking upper left corner
    NSInteger corner_value = [[[matrix objectAtIndex:0] objectAtIndex:0] integerValue];
    if ([[[matrix objectAtIndex:1] objectAtIndex:0] integerValue]  == canonical_matrix[1][0] &&
        [[[matrix objectAtIndex:0] objectAtIndex:1] integerValue]  == canonical_matrix[0][1] &&
        corner_value != canonical_matrix[0][0] &&
        corner_value != 0 &&
        ! [self inArrayMassive:[[[matrix objectAtIndex:0] objectAtIndex:1] integerValue] :self.linear_conflicts] &&
        ![self inArrayMassive:[[[matrix objectAtIndex:1] objectAtIndex:0] integerValue] : self.linear_conflicts])
    {
        conflict += 2;
    }
    
    // checking upper right corner
    corner_value = [[[matrix objectAtIndex:n-1] objectAtIndex:0] integerValue];
    if([[[matrix objectAtIndex:n-2] objectAtIndex:0] integerValue] == canonical_matrix[n-2][0] &&
       [[[matrix objectAtIndex:n-1] objectAtIndex:1] integerValue] == canonical_matrix[n-1][1] &&
       corner_value != canonical_matrix[n-1][0] &&
       corner_value != 0 &&
       ![self inArrayMassive:[[[matrix objectAtIndex:3-2] objectAtIndex:0] integerValue] : self.linear_conflicts] &&
       ![self inArrayMassive: [[[matrix objectAtIndex:3-1] objectAtIndex:1] integerValue] : self.linear_conflicts])
    {
        conflict += 2;
    }
    
    // checking downer left corner
    corner_value = [[[matrix objectAtIndex:0] objectAtIndex:n-1] integerValue];// matrix[0][3-1];
    if([[[matrix objectAtIndex:0] objectAtIndex:n-2] integerValue] == canonical_matrix[0][n-2] &&
       [[[matrix objectAtIndex:1] objectAtIndex:n-1] integerValue]  == canonical_matrix[1][n-1] &&
       corner_value != canonical_matrix[0][n-1] &&
       corner_value != 0 &&
       ![self inArrayMassive: [[[matrix objectAtIndex:0] objectAtIndex:n-2] integerValue] : self.linear_conflicts] &&
       ![self inArrayMassive:[[[matrix objectAtIndex:1] objectAtIndex:n-1] integerValue]  : self.linear_conflicts])
    {
        conflict += 2;
    }
    
    return conflict;
    
}


-(BOOL)inArrayMassive:(NSInteger)element :(NSMutableArray*)array
{
    BOOL in_array = false;
    for(NSInteger i = 0; i < [array count]; i++)
    {
        if(element == [array[i] integerValue])
        {
            in_array = true;
            break;
        }
    }
    return in_array;
}



-(BOOL)inArrayCanonical_matrix:(NSInteger)element :(NSInteger*)array
{
    BOOL in_array = false;
    for(NSInteger i = 0; i < n; i++)
    {
        if(element == array[i])
        {
            in_array = true;
            break;
        }
    }
    return in_array;
}



-(NSMutableArray*)getSolution:(NSInteger)limit
                             :(NSMutableArray*)solution
                             :(NSMutableArray*)matrix
                             :(NSInteger)x_space
                             :(NSInteger)y_space
{
    
    
    NSInteger value;
    NSMutableArray *new_matrix;
    NSInteger steps = [solution count];
    
    if(y_space > 0)
    {
        new_matrix = [NSMutableArray arrayWithArray:matrix];
        value = [[[new_matrix objectAtIndex:x_space] objectAtIndex:y_space-1] integerValue];
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space]];
        [tmp removeObjectAtIndex:y_space];
        [tmp insertObject:[NSNumber numberWithInteger:value] atIndex:y_space];
        [new_matrix removeObjectAtIndex:x_space];
        [new_matrix insertObject:tmp atIndex:x_space];
        NSMutableArray *tmp2 = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space]];
        [tmp2 removeObjectAtIndex:y_space-1];
        [tmp2 insertObject:@0 atIndex:y_space-1];
        [new_matrix removeObjectAtIndex:x_space];
        [new_matrix insertObject:tmp2 atIndex:x_space];
        NSInteger up_heuristic = [self getHeuristic:new_matrix];
        if((up_heuristic +steps) <= limit && [solution[steps-1] integerValue]!= value)
        {
            [solution addObject:[NSNumber numberWithInteger: value]];
            if(up_heuristic == 0)
            {
                self.RESULT = [NSArray arrayWithObject:solution];
                NSLog(@"%@",new_matrix);
                [solution addObject:@"End"];
                NSLog(@"Result is %@",solution);
                return solution;
            }
            else
            {
               return [self getSolution:limit: solution : new_matrix : x_space : y_space-1];
            }
        }
    }
    
    
    if(x_space > 0)
    {
        new_matrix = [NSMutableArray arrayWithArray:matrix];
        value = [[[new_matrix objectAtIndex:x_space-1] objectAtIndex:y_space] integerValue];
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space]];
        [tmp removeObjectAtIndex:y_space];
        [tmp insertObject:[NSNumber numberWithInteger:value] atIndex:y_space];
        [new_matrix removeObjectAtIndex:x_space];
        [new_matrix insertObject:tmp atIndex:x_space];
        NSMutableArray *tmp2 = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space-1]];
        [tmp2 removeObjectAtIndex:y_space];
        [tmp2 insertObject:@0 atIndex:y_space];
        [new_matrix removeObjectAtIndex:x_space-1];
        [new_matrix insertObject:tmp2 atIndex:x_space-1];
        NSInteger left_heuristic = [self getHeuristic:new_matrix];
        if((left_heuristic + steps)<= limit && [solution[steps-1] integerValue] != value)
        {
            [solution addObject:[NSNumber numberWithInteger: value]];
            if (left_heuristic == 0)
            {
                NSLog(@"%@",new_matrix);
                [solution addObject:@"End"];
                NSLog(@"Result is %@",solution);
                self.RESULT = [NSArray arrayWithObject:solution];
                return self.solution;
            }
            else
            {
               return [self getSolution:limit: solution : new_matrix : x_space-1 : y_space];
            }
        }
    }
    
    if(x_space < n-1)
    {
        new_matrix = [NSMutableArray arrayWithArray:matrix];
        value = [[[new_matrix objectAtIndex:x_space+1] objectAtIndex:y_space] integerValue];
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space]];
        [tmp removeObjectAtIndex:y_space];
        [tmp insertObject:[NSNumber numberWithInteger:value] atIndex:y_space];
        [new_matrix removeObjectAtIndex:x_space];
        [new_matrix insertObject:tmp atIndex:x_space];
        NSMutableArray *tmp2 = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space+1]];
        [tmp2 removeObjectAtIndex:y_space];
        [tmp2 insertObject:@0 atIndex:y_space];
        [new_matrix removeObjectAtIndex:x_space+1];
        [new_matrix insertObject:tmp2 atIndex:x_space+1];
        
        NSInteger right_heuristic = [self getHeuristic:new_matrix];
        
        if((right_heuristic + steps)<= limit && [solution[steps-1] integerValue]!= value)
        {
            [solution addObject:[NSNumber numberWithInteger: value]];
            if(right_heuristic == 0)
            {
                NSLog(@"%@",new_matrix);
                [solution addObject:@"End"];
                NSLog(@"Result is %@",solution);
                self.RESULT = [NSArray arrayWithObject:solution];
                return self.solution;
            }
            else
            {
              return [self getSolution:limit: solution : new_matrix : x_space+1 : y_space];
            }
        }
    }
    
    
    
    if (y_space < n-1)
    {
        
        new_matrix = [NSMutableArray arrayWithArray:matrix];
        value = [[[new_matrix objectAtIndex:x_space] objectAtIndex:y_space+1] integerValue];
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space]];
        [tmp removeObjectAtIndex:y_space+1];
        [tmp insertObject:@0 atIndex:y_space+1];
        [new_matrix removeObjectAtIndex:x_space];
        [new_matrix insertObject:tmp atIndex:x_space];
        NSMutableArray *tmp2 = [NSMutableArray arrayWithArray:[new_matrix objectAtIndex:x_space]];
        [tmp2 removeObjectAtIndex:y_space+1];
        [tmp2 insertObject:[NSNumber numberWithInteger:value] atIndex:y_space];
        [new_matrix removeObjectAtIndex:x_space];
        [new_matrix insertObject:tmp2 atIndex:x_space];
        NSInteger down_heuristic = [self getHeuristic:new_matrix];
        if((down_heuristic) <= limit && [solution[steps-1] integerValue]!= value)
        {
            [solution addObject:[NSNumber numberWithInteger: value]];
            if (down_heuristic == 0)
            {
                NSLog(@"%@",new_matrix);
                [solution addObject:@"End"];
                 NSLog(@"Result is %@",solution);
                self.RESULT = [NSArray arrayWithObject:solution];
                return solution;
            }
            else
            {
               return [self getSolution:limit: solution : new_matrix : x_space : y_space+1];
            }
        }
    }
    
    return solution;
}
@end





int main(int argc, const char * argv[]) {
    @autoreleasepool {
     
        while (1)
        {
      
            NSLog(@"Do You Wanna Start Calculation?");
            getchar();
        
        // Matrix for review
        NSArray *row1 = [NSArray  arrayWithObjects:@1,@2,@0,@3,nil];
        NSArray *row2 = [NSArray  arrayWithObjects:@6,@7,@8,@4,nil];
        NSArray *row3 = [NSArray  arrayWithObjects:@5,@10,@11,@12,nil];
        NSArray *row4 = [NSArray  arrayWithObjects:@9,@13,@14,@15,nil];
        
        NSArray *matrix  = [NSArray arrayWithObjects:row1,row2,row3,row4,nil];
        
        
        
        NSInteger a[16] = {[[[matrix objectAtIndex:0] objectAtIndex:0] integerValue],
                            [[[matrix objectAtIndex:0] objectAtIndex:1] integerValue],
                            [[[matrix objectAtIndex:0] objectAtIndex:2] integerValue],
                            [[[matrix objectAtIndex:0] objectAtIndex:3] integerValue],
                            [[[matrix objectAtIndex:1] objectAtIndex:0] integerValue],
                            [[[matrix objectAtIndex:1] objectAtIndex:1] integerValue],
                            [[[matrix objectAtIndex:1] objectAtIndex:2] integerValue],
                            [[[matrix objectAtIndex:1] objectAtIndex:3] integerValue],
                            [[[matrix objectAtIndex:2] objectAtIndex:0] integerValue],
                            [[[matrix objectAtIndex:2] objectAtIndex:1] integerValue],
                            [[[matrix objectAtIndex:2] objectAtIndex:2] integerValue],
                            [[[matrix objectAtIndex:2] objectAtIndex:3] integerValue],
                            [[[matrix objectAtIndex:3] objectAtIndex:0] integerValue],
                            [[[matrix objectAtIndex:3] objectAtIndex:1] integerValue],
                            [[[matrix objectAtIndex:3] objectAtIndex:2] integerValue],
                            [[[matrix objectAtIndex:3] objectAtIndex:3] integerValue]};
        
      /*  for(int i = 0; i<100; i++)
        {
            for(int j=0;j<16;j++)
        {
            NSInteger tmp,randPosition1,randPosition2;
            randPosition1 = rand()%16;
            randPosition2 = rand()%16;
            tmp =a[randPosition1];
            a[randPosition1] = a[randPosition2];
            a[randPosition2] = tmp;
        }*/
            
            NSString *status;
            int inv = 0;
            for (int i=0; i<n; ++i)
                if (a[i])
                    for (int j=0; j<i; ++j)
                        if (a[j] > a[i])
                            ++inv;
            for (int i=0; i<n; ++i)
                if (a[i] == 0)
                    inv += 1 + i/n;
            
            if(inv & 1)
            {
                status =@"No Solution";
            }
            else
            { status=@"Solution Exists";
            }
            NSLog(@"%@", status);
            if([status isEqualToString:@"Solution Exists"])
            {    NSLog(@"Start Position");
                 NSLog(@"%li %li %li %li",a[0],a[1],a[2],a[3]);
                 NSLog(@"%li %li %li %li",a[4],a[5],a[6],a[7]);
                 NSLog(@"%li %li %li %li",a[8],a[9],a[10],a[11]);
                 NSLog(@"%li %li %li %li",a[12],a[13],a[14],a[15]);
                
            }
        
       
        
        Puzzle *ob = [[Puzzle alloc] init];
        ob.manhatten_array = [NSMutableArray array];
        ob.linear_conflicts = [NSMutableArray array];
        ob.solution = [NSMutableArray array];
    
        NSInteger x_space = 0, y_space = 0;
        for (NSInteger i = 0; i < n; i++) {
            for (NSInteger j = 0; j < n; j++) {
                if ([[[matrix objectAtIndex:i] objectAtIndex:j] integerValue] == 0)
                {
                    x_space = i;
                    y_space = j;
                    break;
                }
            }
        }
        
        
        
        [ob calcCanonicalMatrix:n];
        NSMutableArray *solution = [NSMutableArray arrayWithCapacity:10];
            [solution addObject:@"Start"];
        NSInteger limit = [ob getHeuristic:matrix];
        [ob getSolution:limit :solution :matrix :x_space :y_space];
        //показує які клітки мають рухатись на місце пустої
        NSLog(@"Result %@",ob.RESULT);
            ob.RESULT = nil;
        }
    }
    return 0;
}
