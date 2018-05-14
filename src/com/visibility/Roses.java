/**
 * 
 */
package com.visibility;

/**
 * @author vsok
 *
 */
public class Roses extends Plant{
	private boolean haveAThorns;
	
	public Roses(String name, String color, int leaves, int height) {
		super(name, color, leaves, height);
	}

	public Roses(boolean haveAThorns) {
		this.haveAThorns = haveAThorns;
	}

	public Roses(String name, String color, int leaves, int height, boolean haveAThorns) {
		super(name, color, leaves, height);
		this.haveAThorns = haveAThorns;
	}

	/**
	 * @return the haveAThorns
	 */
	public boolean isHaveAThorns() {
		return haveAThorns;
	}

	/**
	 * @param haveAThorns the haveAThorns to set
	 */
	public void setHaveAThorns(boolean haveAThorns) {
		this.haveAThorns = haveAThorns;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = super.hashCode();
		result = prime * result + (haveAThorns ? 1231 : 1237);
		return result;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (!super.equals(obj))
			return false;
		if (getClass() != obj.getClass())
			return false;
		Roses other = (Roses) obj;
		if (haveAThorns != other.haveAThorns)
			return false;
		return true;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "Roses [haveAThorns=" + haveAThorns + "]";
	} 
	
	Eagle firstEagle = new Eagle("pesho");
	String myName = firstEagle.name;
	
}
