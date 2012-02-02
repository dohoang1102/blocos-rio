//    Copyright 2011 Felipe Cypriano
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

#import "DesfileEnderecoCell.h"


@implementation DesfileEnderecoCell

+ (CGFloat)rowHeight {
    return 54.0f;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        lblNome = [[UILabel alloc] initWithFrame:CGRectMake(6, 5, 247, 21)];
        lblNome.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        lblNome.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:lblNome];
        
        lblEndereco = [[UILabel alloc] initWithFrame:CGRectMake(6, 30, 247, 18)];
        lblEndereco.font = [UIFont systemFontOfSize:14.0];
        lblEndereco.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:lblEndereco];
        
        lblHora = [[UILabel alloc] initWithFrame:CGRectMake(254, 16, 60, 21)];
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
    [super dealloc];
}

- (void)updateWithDesfile:(Desfile *)newDesfile {
    lblNome.text = newDesfile.bloco.nome;
    lblEndereco.text = [NSString stringWithFormat:@"%@, %@", newDesfile.endereco, newDesfile.bairro.nome];
    lblHora.text = [newDesfile.dataHora timeToString];
}


@end
