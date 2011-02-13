//
//  DesfileTableViewCell.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 13/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Desfile.h"

@interface DesfileEnderecoCell : UITableViewCell {
@private
    UILabel *lblNome;
    UILabel *lblEndereco;
    UILabel *lblHora;
}

@property (nonatomic, retain) Desfile *desfile;

- (id)initWithDesfile:(Desfile *)umDesfile reuseIdentifier:(NSString *)reuseIdentifier;

@end
