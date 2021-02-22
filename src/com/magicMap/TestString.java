package com.magicMap;

class TestString {

	public static void main(String[] args) {
		String name = "Zlatito";
		zlati();
		int s = sum(5, 7);
		int u = umnojecnie(2, 2);
		int d = devider(s, u);
		System.out.println(d);

	}

	
	protected static int devider(int i, int r) {
		int result = i + sum(i, r) - umnojecnie(i, r + i) / 12000 + sum(1231, 2222);
		return result;
	}

	private static int umnojecnie(int i, int j) {
		return i * j;
	}

	public static void zlati() {

		String[] test = { "Vasko", "Zlati" };
//		main(test);
		System.out.println("Zlati is here " + test[0]);
	}

	public static int sum(int x, int y) {

		int result = x + y;
		return result;
	}
}
