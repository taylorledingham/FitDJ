//
//  CustomTimeIntervalCell.m
//  
//
//  Created by Taylor Ledingham on 2014-12-20.
//
//

#import "CustomTimeIntervalCell.h"

@implementation CustomTimeIntervalCell

- (IBAction)deleteIntervalPressed:(id)sender {
    [self.delegate deleteTimeIntervalCell:self];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    if(textField == self.speedTextField){
       
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if(textField == self.durationTextField){
        
        NSString *text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString: string];
        if(text.length > 6){
            return NO;
        }
        
        if( [string isEqualToString:@""] && range.location == 4 && range.length==1){
            textField.text = @"00:00";
            return NO;
            
        }
        
        if([textField.text isEqualToString:@"00:00"]){
            textField.text = [NSString stringWithFormat:@"00:0%@", string];
            
        }
        
        else if([[textField.text substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"0"]){
            NSString *charAtPos1 = [textField.text substringWithRange:NSMakeRange(4, 1)];
            textField.text = [NSString stringWithFormat:@"00:%@%@", charAtPos1, string];

            
        }
        else if([[textField.text substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"0"]){
            NSString *charAtPos1 = [textField.text substringWithRange:NSMakeRange(4, 1)];
            NSString *charAtPos2 = [textField.text substringWithRange:NSMakeRange(3, 1)];
            textField.text = [NSString stringWithFormat:@"0%@:%@%@",  charAtPos2, charAtPos1, string];
            
            
        }
        else if([[textField.text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"]){
            NSString *charAtPos1 = [textField.text substringWithRange:NSMakeRange(4, 1)];
            NSString *charAtPos2 = [textField.text substringWithRange:NSMakeRange(3, 1)];
            NSString *charAtPos3 = [textField.text substringWithRange:NSMakeRange(1, 1)];

            textField.text = [NSString stringWithFormat:@"%@%@:%@%@",  charAtPos3, charAtPos2, charAtPos1, string];

            
        }
        
        else if(textField.text.length >5) {
            return NO;//textField.text = [textField.text substringWithRange:NSMakeRange(0, 4)];
        }
        
        else {
            return NO;//textField.text = textField.text;
        }
        
    
        return NO;
        }
    
    else if (textField == self.speedTextField || textField == self.inclineTextField){
        NSString *text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString: string];
        text = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        if(text.length > 3){
            return NO;
        }
        
        
    }
    
    
    return YES;
    
}
@end
