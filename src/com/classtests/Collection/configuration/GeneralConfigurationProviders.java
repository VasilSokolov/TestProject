package com.classtests.Collection.configuration;

import java.util.List;

//import javax.validation.constraints.NotBlank;
//
//import org.springframework.boot.context.properties.ConfigurationProperties;
//import org.springframework.context.annotation.PropertySource;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
//@PropertySource("classpath:application")
//@ConfigurationProperties(prefix = "sms.service")
public class GeneralConfigurationProviders {
    
//    @NotBlank
    private List<SmsCountryProviders> unifiedProviders;
}
