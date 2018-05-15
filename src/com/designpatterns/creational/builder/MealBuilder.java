package com.designpatterns.creational.builder;

import com.designpatterns.creational.builder.impl.ChickenBurger;
import com.designpatterns.creational.builder.impl.Coke;
import com.designpatterns.creational.builder.impl.Pepsi;
import com.designpatterns.creational.builder.impl.VegBurger;

public class MealBuilder {
	
	public Meal prepareVegMeal() {
		Meal meal = new Meal();
		meal.addItem(new VegBurger());
		meal.addItem(new Coke());
		return meal;
	}
	
	public Meal prepareNonVegMeal() {
		Meal meal = new Meal();
		meal.addItem(new ChickenBurger());
		meal.addItem(new Pepsi());
		return meal;
	}
}
