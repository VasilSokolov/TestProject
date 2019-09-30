package com.enums.exceptions;

public class IuteRuntimeException extends RuntimeException {

    /**  */
    private static final long serialVersionUID = -8757569925970351129L;

    /**
     *
     */
    public IuteRuntimeException() {
    }

    /**
     * @param message
     */
    public IuteRuntimeException(String message) {
        super(message);
    }

    /**
     * @param cause
     */
    public IuteRuntimeException(Throwable cause) {
        super(cause);
    }

    /**
     * @param message
     * @param cause
     */
    public IuteRuntimeException(String message, Throwable cause) {
        super(message, cause);
    }
}
