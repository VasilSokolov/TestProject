package condition;

public class ConditionTest {

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
	

}
