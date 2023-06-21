package softuni;

import javax.swing.*;
import javax.swing.border.Border;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.math.BigInteger;
import java.util.Collections;
import java.util.LinkedHashSet;


public class DemoPoli {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
//		String[] values = {"reporting", "na maika muuu", };
////
//		String str = "rac3ecar";
//		int length = str.length() - 1 ;
//		for(int i = 0, j = length ; i < length; i++, --j) {
//			if(str.charAt(i) != str.charAt(j)) {
//			  System.out.println("Not polindrome");
//			  return;
//			}
//		}
//		System.out.println("Is polindrome");
		swingTest();

//		new BigInteger();
//		int[] arr = {3,5,1,4,6,9,8,7,10};
// 		
//		int sum = (((arr.length + 1) * (arr.length + 2 )) / 2);
//		int sum2 = 0 ;
//		
//		for (int i = 0; i < arr.length; i++) {
//			sum2+= arr[i];
//		}
//		
////		String str = "ababaa";
//		
//		String[] arrStr = str.split("");
//		
//		for (int i = 0; i < arrStr.length; i++) {
//			System.out.println(arrStr[i]);
//		}
//		System.out.println(sum + "  " +sum2);
	}

	private static void swingTest(){

		JFrame jFrame = new JFrame ("Order your pizza");
		jFrame.setLayout (null);
		jFrame.setSize (500, 360);
		jFrame.setDefaultCloseOperation (JFrame.EXIT_ON_CLOSE);

		JTextArea orders = new JTextArea ("Your order: \n");
		Border ordersBorder = BorderFactory.createLineBorder (Color.RED);
		orders.setBorder (ordersBorder);
		orders.setPreferredSize (new Dimension (150, 500));
		orders.setBounds (320, 110, 150, 280);
		jFrame.add (orders);

		JLabel totalPrice = new JLabel ("Total price: " + 5 + "lv.");
		Border border = BorderFactory.createLineBorder (Color.BLACK);
		totalPrice.setBorder (border);
		totalPrice.setPreferredSize (new Dimension (150, 50));
		totalPrice.setBounds (320, 50, 150, 50);
		jFrame.add (totalPrice);

		JLabel margaritta = new JLabel ("Margaritta");
		margaritta.setPreferredSize (new Dimension(150, 100));
		margaritta.setHorizontalAlignment (JLabel.LEFT);
		margaritta.setText ("Margaritta");
		margaritta.setBounds (50, 30, 150, 100);
		margaritta.setVisible (true);
		jFrame.add (margaritta);

		JButton orderMargaritta = new JButton ("Add");
		orderMargaritta.setBounds (200, 50, 100, 50);
		orderMargaritta.addActionListener (new ActionListener() {
			public void actionPerformed(ActionEvent e) {
//				String text = orders.getText ();
//				text += margaritta.getText () + "\n";
//				orders.setText (text);
//				price += 7.5;
//				totalPrice.setText ("Total price: " + price + "lv.");
			}
		});
		jFrame.add (orderMargaritta);
	}


}
