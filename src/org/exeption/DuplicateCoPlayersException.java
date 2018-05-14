package org.exeption;

public class DuplicateCoPlayersException extends RuntimeException {
	private static final long serialVersionUID = 1L;	

	private static final String MESSAGE_TEMPLATE = "Player with name { %s } is already shoosed.";
	
	private String errorMessage;

	public DuplicateCoPlayersException(String errorMessage) {
		super(errorMessage);
		this.errorMessage = String.format(MESSAGE_TEMPLATE, errorMessage);
	}

	public DuplicateCoPlayersException() {
		super();
	}

	public String getErrorMessage() {
		return errorMessage;
	}
}
