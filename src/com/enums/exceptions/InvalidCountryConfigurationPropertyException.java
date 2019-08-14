package com.enums.exceptions;

public class InvalidCountryConfigurationPropertyException extends IuteRuntimeException {

    private static final long serialVersionUID = -4012752912901697788L;
    public static final String INVALID_PROPERTY = "Invalid property: ";

    public InvalidCountryConfigurationPropertyException(String property) {
        super(INVALID_PROPERTY + property);
    }
}
