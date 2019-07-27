package com.classtests.Collection.configuration;

//import javax.validation.constraints.NotBlank;
//import javax.validation.constraints.Pattern;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SmsCountryProviders {
    
//    @NotBlank
    private String url;
    
//    @NotBlank
    private String userName;
    
//    @NotBlank
    private String password;
    
//    @Pattern(regexp = "^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,6}$")
    private String from;
    
//    @NotBlank
    private String type;
    
//    @NotBlank
    private String country;    
}
