package com.designpatterns.utilsdesignpattern.interceptingfilter;

public class FilterManager {
	private FilterChain filterChain;

	public FilterManager(Target	 target) {
		this.filterChain = new FilterChain();
		this.filterChain.setTarget(target);
	}
	
	public void setFilter(Filter filter) {
		filterChain.addFilter(filter);
	}
	
	public void filterRequest(String request) {
		filterChain.execute(request);
	}
}
