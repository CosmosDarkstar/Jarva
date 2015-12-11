package skewll.ch10.snoipets;

import java.awt.GridLayout;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;

/**
 * This program demonstrates how to install an action listener.
 */
public class ButtonViewer {
	private static final int FRAME_WIDTH = 200;
	private static final int FRAME_HEIGHT = 120;

	public static void main(String[] args) {
		JFrame frame = new JFrame();

		frame.getContentPane().setLayout(new GridLayout(1, 2));

		JButton button1 = new JButton("A");
		frame.add(button1);
		ActionListener listener1 = new ClickListener();
		button1.addActionListener(listener1);

		JButton button2 = new JButton("B");
		frame.add(button2);
		ActionListener listener2 = new ClickListener2();
		button2.addActionListener(listener2);

		frame.pack();

		frame.setSize(FRAME_WIDTH, FRAME_HEIGHT);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setVisible(true);
	}
}
