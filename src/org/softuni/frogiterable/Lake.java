package org.softuni.frogiterable;

import java.util.*;

public class Lake<Integer> implements Iterable<Integer> {

	private List<Integer> steps;
	
	public Lake() {
		this.steps = new ArrayList<>();
	}

	@Override
	public Iterator<Integer> iterator() {
		return new Frog();
	}
	
	private final class Frog implements Iterator<Integer> {
		private int index;
		
		public Frog() {
			this.index = 0;
		}

		@Override
		public boolean hasNext() {
			return this.index < steps.size();
		}

		@Override
		public Integer next() {
			return steps.get(this.index++);
		}
	}
}
