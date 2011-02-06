//
//  BlocosService.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlocosXMLParserDelegate.h"

@interface BlocosService : NSObject {
@private
    NSMutableData *zipData;
    NSError *errorOnHTTPRequest;
    
    BlocosXMLParserDelegate *blocosXMLDelegate;
}

- (void)updateBlocosData;

@end
