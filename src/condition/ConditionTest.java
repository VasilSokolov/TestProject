package condition;

public class ConditionTest {
	GearService gs = new GearServiceIml();
	

	public static void main(String[] args) {
		
		boolean first =true;
		boolean second = false;
		
		System.out.println("&& operator");
		AmpersandFirst(first, second);
		System.out.println("|| operator");
		ConditionAnd(first, second);
		
		if(AmpersandThird(first) && AmpersandSecond(second)){
			System.out.println("is TRue");
		}else{
			System.out.println("is Out");
		}
		
		ConditionTest ct = new ConditionTest();
		ct.chechIsBetween(70);
		ct.adding();
		ct.getting();
	}
	public String condition;
	public static void AmpersandFirst(boolean first, boolean second) {
		if (first && first ) {
			System.out.println("If first:"+first +", second: "+first);
		}
		if(first && second){
			System.out.println("If first:"+first +", second: "+second);
		}
		if(second && first){
			System.out.println("If first:"+second +", second: "+first);
		}
		if(second && second){
			System.out.println("If first:"+second +", second: "+second);
		}
	}
	
	public static boolean AmpersandSecond(boolean first){
		return first;
	}
	
	public static boolean AmpersandThird(boolean first){
		return first;
	}
	
	public static void ConditionAnd(boolean first, boolean second){
		if (first || first ) {
			System.out.println("If first:"+first +", second: "+first);
		}
		if(first || second){
			System.out.println("If first:"+first +", second: "+second);
		}
		if(second || first){
			System.out.println("If first:"+second +", second: "+first);
		}
		if(second || second){
			System.out.println("If first:"+second +", second: "+second);
		}
	}
	
	public void chechIsBetween(int age) {
		if( age > 18 && age < 71) {
			System.out.println("Its applicable for loan with age: " + age);			
		} else {
			System.out.println("Not applicable");
		}
	}
	
	public void adding() {
		GearML ml = new GearML();
		ml.setActive(true);
		
		GearCl g = new GearCl();
		g.setName("pesho");
		g.setId(5);
		gs.setGear(g);
		gs.createGearMl(ml);
		System.out.println("Addig gear " + gs.getGear() + " \nML: " + gs.getGearMl());
	}
	public void getting() {
		System.out.println("Getting gear" + gs.getGear());
	}

}
