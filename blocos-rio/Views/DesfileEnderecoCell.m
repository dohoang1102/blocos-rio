//
//  DesfileTableViewCell.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 13/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import "DesfileEnderecoCell.h"


@implementation DesfileEnderecoCell

@synthesize desfile;

- (id)initWithDesfile:(Desfile *)umDesfile reuseIdentifier:(NSString *)reuseIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.desfile = umDesfile;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        lblNome = [[UILabel alloc] initWithFrame:CGRectMake(6, 3, 247, 21)];
        lblNome.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        lblNome.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:lblNome];
        
        lblEndereco = [[UILabel alloc] initWithFrame:CGRectMake(6, 24, 247, 18)];
        lblEndereco.font = [UIFont systemFontOfSize:14.0];
        lblEndereco.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:lblEndereco];
        
        lblHora = [[UILabel alloc] initWithFrame:CGRectMake(254, 11, 60, 21)];
        lblHora.font = [UIFont systemFontOfSize:14.0];
        lblHora.adjustsFontSizeToFitWidth = YES;
        lblHora.minimumFontSize = 8;
        lblHora.textAlignment = UITextAlignmentRight;
        lblHora.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:lblHora];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
 
    if (selected) {
        lblNome.textColor = [UIColor whiteColor];
        lblEndereco.textColor = [UIColor whiteColor];
        lblHora.textColor = [UIColor whiteColor];
    } else {
        lblNome.textColor = [UIColor darkTextColor];
        lblEndereco.textColor = [UIColor grayColor];
        lblHora.textColor = [UIColor colorWithRed:0.22 green:0.329 blue:0.529 alpha:1];
    }
}


- (void)dealloc {
    [lblNome release];
    [lblEndereco release];
    [lblHora release];
    [desfile release];
    [super dealloc];
}

- (void)setDesfile:(Desfile *)newDesfile {
    if (newDesfile != desfile) {
        [desfile release];
        desfile = [newDesfile retain];
    }
    
    lblNome.text = desfile.bloco.nome;
    lblEndereco.text = [NSString stringWithFormat:@"%@, %@", desfile.endereco, desfile.bairro.nome];
    lblHora.text = [desfile.dataHora timeToString];
}


@end
