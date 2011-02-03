//
//  BlocosService.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BlocosService : NSObject {
@private
    NSMutableData *zipData;
    NSError *errorOnHTTPRequest;
}

- (void)updateBlocosData;

@end
